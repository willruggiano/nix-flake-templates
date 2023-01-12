{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    pre-commit-nix.url = "github:cachix/pre-commit-hooks.nix";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = {flake-parts, ...} @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.pre-commit-nix.flakeModule
      ];

      systems = ["x86_64-linux" "aarch64-darwin"];
      perSystem = {
        config,
        system,
        ...
      }: let
        pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [inputs.rust-overlay.overlays.default];
        };
        toolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
      in {
        devShells.default = pkgs.mkShell {
          name = "rust-nightly";
          buildInputs = [toolchain];
          shellHook = ''
            ${config.pre-commit.installationScript}
          '';
        };

        formatter = pkgs.alejandra;

        pre-commit = {
          settings = {
            hooks.alejandra.enable = true;
            hooks.rustfmt.enable = true;
            hooks.clippy.enable = true;
            hooks.cargo-check.enable = true;
          };
        };
      };
    };
}
