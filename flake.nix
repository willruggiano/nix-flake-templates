{
  description = "A collection of Flake templates";

  outputs = _: {
    templates = {
      devshell = {
        path = ./devshell;
        description = "Simple devshell";
      };
      lua-plugin = {
        path = ./lua/plugin;
        description = "Lua Neovim plugin";
        welcomeText = ''
          Run `nix run .#template-init -- PLUGIN_NAME` to get started.
        '';
      };
      rust-bin = {
        path = ./rust/bin;
        description = "Ready to go Rust binary application";
        welcomeText = ''
          Run `nix run .#template-init -- NAME` to get started.
        '';
      };
      rust-shell = {
        path = ./rust/shell;
        description = "Latest nightly Rust in a devshell";
      };
    };
  };
}
