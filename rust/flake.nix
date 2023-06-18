{
  description = "FLAKE_NAME";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    devenv.url = "github:cachix/devenv";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-cargo-integration.url = "github:yusdacra/nix-cargo-integration";
    nix-cargo-integration.inputs.rust-overlay.follows = "rust-overlay";
    pre-commit-nix.url = "github:cachix/pre-commit-hooks.nix";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = {flake-parts, ...} @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.devenv.flakeModule
        inputs.nix-cargo-integration.flakeModule
        inputs.pre-commit-nix.flakeModule
      ];

      systems = ["x86_64-linux"];
      perSystem = {
        config,
        pkgs,
        ...
      }: let
        crateName = "FLAKE_CRATE_NAME";
        crateOutputs = config.nci.outputs."${crateName}";
      in {
        devenv.shells.default = let
          inherit (crateOutputs) devShell;
        in {
          name = "FLAKE_NAME";

          packages =
            devShell.nativeBuildInputs
            ++ (with pkgs; [
              cargo-expand
            ]);

          pre-commit.hooks = {
            alejandra.enable = true;
            cargo-check.enable = true;
            rustfmt.enable = true;
          };
        };

        formatter = pkgs.alejandra;

        nci = {
          projects."${crateName}".relPath = "";
          crates."${crateName}" = {
            overrides = {
              add-inputs.overrideAttrs = prev: {
                nativeBuildInputs = prev.nativeBuildInputs ++ [pkgs.clangStdenv.cc];
              };
            };
          };
        };

        packages.default = crateOutputs.packages.release;
      };
    };
}
