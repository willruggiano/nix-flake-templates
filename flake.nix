{
  description = "A collection of Flake templates";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs = {nixpkgs, ...}: {
    apps.x86_64-linux = let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
      };
    in {
      rust = {
        type = "app";
        program = "${pkgs.callPackage ./bin/rust.nix {}}/bin/template-init";
      };
    };

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
      };
    };
  };
}
