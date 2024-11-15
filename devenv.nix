{ pkgs, lib, config, inputs, ... }:

let
  pkgs-unstable = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.system;
    config = {
      packageOverrides = pkgs: {
        nginx = pkgs.nginx.override {
          modules = lib.unique (pkgs.nginx.modules ++ [
            ( pkgs.callPackage ../devenv-extra/nginx-early-hints.nix { } )
          ]);
        };
      };
    };
  };
  pkgs-haproxy = import inputs.nixpkgs-haproxy { system = pkgs.stdenv.system; };
  nginxConf = import ./devenv-extra/nginx-conf.nix { nginx = pkgs-unstable.nginx; };
  haproxyConf = ( import ./devenv-extra/haproxy-config.nix { pkgs = pkgs-haproxy; } );
in
{
  # https://devenv.sh/basics/
  # env.GREET = "devenv";

  # https://devenv.sh/packages/
  packages = [
    pkgs.git
    pkgs.libyaml
    pkgs.sqlite
    pkgs-unstable.nginx
  ]
  # Add required dependencies for macOS. These packages are usually provided as
  # part of the Xcode command line developer tools, in which case they can be
  # removed.
  # For more information, see the `--install` flag in `man xcode-select`.
  ++ lib.optionals pkgs.stdenv.isDarwin [ pkgs.libllvm ];

  # https://devenv.sh/languages/
  # languages.rust.enable = true;
  languages.javascript = {
    enable = true;
    yarn = {
      enable = true;
    };
    npm = {
      enable = true;
    };
  };
  languages.ruby = {
    enable = true;
    versionFile = ./.ruby-version;
    bundler = {
      enable = false;
    };
  };

  enterShell = ''
    # Automatically run bundler upon enterting the shell.
    bin/bundle
  '';

  # Generates once but then replaces every time thereafter
  devcontainer.enable = false;

  # https://devenv.sh/processes/
  # To use overmind we gotta' figure out the port or set OVERMIND_PORT.
  # Puma seems to start at 5200 which maybe is because it's third? 5000/5100/5200?
  # process.manager.implementation = "overmind";

  processes.puma.exec = "bundle exec puma";
  processes.haproxy.exec = "${lib.getExe pkgs-haproxy.haproxy} -Ws -f ${haproxyConf}";

  # https://devenv.sh/services/
  # services.postgres.enable = true;
  services.nginx = {
    enable = true;
    httpConfig = nginxConf;
    package = pkgs-unstable.nginx;
  };

  # https://devenv.sh/scripts/
  # scripts.hello.exec = ''
  #   echo hello from $GREET
  # '';

  # https://devenv.sh/tasks/
  tasks = {
    # "myproj:setup".exec = "mytool build";
    # "devenv:enterShell".after = [ "myproj:setup" ];
    "assets:precompile" = {
      exec = "bin/rake assets:precompile";
      before = [ "devenv:enterShell" ];
    };
  };

  # https://devenv.sh/tests/
  # enterTest = ''
  #   echo "Running tests"
  #   git --version | grep --color=auto "${pkgs.git.version}"
  # '';

  # https://devenv.sh/pre-commit-hooks/
  # pre-commit.hooks.shellcheck.enable = true;
  git-hooks.hooks = {
    prettier.enable = true;
  };

  # See full reference at https://devenv.sh/reference/options/
}
