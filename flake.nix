{
  description = "A collection of Flake templates";

  outputs = _: {
    templates = {
      lua = {
        path = ./lua;
        description = "Lua Neovim plugin";
        welcomeText = ''
          Run `nix run .#template-init -- PLUGIN_NAME` to get started.
        '';
      };
      rust = {
        path = ./rust;
        description = "Ready to go Rust binary application";
        welcomeText = ''
          Run `nix run .#template-init -- NAME` to get started.
        '';
      };
    };
  };
}
