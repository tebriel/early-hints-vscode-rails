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
  nginx1_1Conf = import ./devenv-extra/nginx-conf.nix { nginx = pkgs-unstable.nginx; http2 = false; };
  nginx2Conf = import ./devenv-extra/nginx-conf.nix { nginx = pkgs-unstable.nginx; http2 = true; };
  haproxyConf = ( import ./devenv-extra/haproxy-config.nix { pkgs = pkgs-haproxy; } );
in
{
  # https://devenv.sh/basics/
  # env.GREET = "devenv";

  # https://devenv.sh/packages/
  packages = [
    pkgs.bats
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
    httpConfig = nginx1_1Conf;
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
    # "bundle:install" = {
    #   exec = "bin/bundle; bin/rake assets:precompile";
    #   before = [ "devenv:enterShell" ];
    # };
    # "assets:precompile" = {
    #   exec = "bin/rake assets:precompile";
    #   before = [ "devenv:enterShell" ];
    # };
  };

  # https://devenv.sh/tests/
  # enterTest = ''
  #   wait_for_port 3000 30 # Puma
  #   wait_for_port 8080 30 # NGINX1.1->Puma
  #   wait_for_port 8081 30 # HAProxy1.1->Puma
  #   wait_for_port 8082 30 # HAProxy2->Puma
  #   wait_for_port 8091 30 # HAProxy1.1->NGINX->Puma
  #   wait_for_port 8092 30 # HAProxy2->NGINX->Puma

  #   echo "Running tests"
  #   bats script/test.bats
  # '';

  # https://devenv.sh/pre-commit-hooks/
  # pre-commit.hooks.shellcheck.enable = true;
  git-hooks.hooks = {
    prettier.enable = true;
  };

  # See full reference at https://devenv.sh/reference/options/
}
