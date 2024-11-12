{ pkgs, lib, config, inputs, ... }:

{
  # https://devenv.sh/basics/
  # env.GREET = "devenv";

  # https://devenv.sh/packages/
  packages = [
    pkgs.git
    pkgs.libyaml
    pkgs.sqlite
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
    bundle
  '';

  # Generates once but then replaces every time thereafter
  devcontainer.enable = false;

  # https://devenv.sh/processes/
  # processes.cargo-watch.exec = "cargo-watch";

  # https://devenv.sh/services/
  # services.postgres.enable = true;

  # https://devenv.sh/scripts/
  # scripts.hello.exec = ''
  #   echo hello from $GREET
  # '';

  # https://devenv.sh/tasks/
  # tasks = {
  #   "myproj:setup".exec = "mytool build";
  #   "devenv:enterShell".after = [ "myproj:setup" ];
  # };

  # https://devenv.sh/tests/
  enterTest = ''
    echo "Running tests"
    git --version | grep --color=auto "${pkgs.git.version}"
  '';

  # https://devenv.sh/pre-commit-hooks/
  # pre-commit.hooks.shellcheck.enable = true;
  git-hooks.hooks = {
    prettier.enable = true;
  };

  # See full reference at https://devenv.sh/reference/options/
}
