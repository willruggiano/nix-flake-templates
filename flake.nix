{
  description = "A collection of Flake templates";

  outputs = _: {
    templates = {
      devshell = {
        path = ./devshell;
        description = "Simple devshell";
        welcomeText = ''
          Run `echo 'use flake' > .envrc && direnv allow` to get started.
        '';
      };
      rust-shell = {
        path = ./rust/shell;
        description = "Latest nightly Rust in a devshell";
        welcomeText = ''
          Run `echo 'use flake' > .envrc && direnv allow` to get started.
        '';
      };
    };
  };
}
