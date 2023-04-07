{
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
        crateName = "REPLACE_ME";
        crateOutputs = config.nci.outputs."${crateName}";
      in {
        apps.template-init.program = pkgs.writeShellApplication {
          name = "template-init";
          runtimeInputs = with pkgs; [cargo coreutils findutils gnused ripgrep];
          text = ''
            rg -l REPLACE_ME | xargs -I{} sed -i s/REPLACE_ME/"$1"/g {}
            rg -l CRATE_NAME | xargs -I{} sed -i s/CRATE_NAME/"$(echo "$1" | tr '-' '_')"/g {}
            cargo generate-lockfile
            git init && git add -A
            git commit -m 'chore: initial commit'
            echo 'use flake' > .envrc && direnv allow
            # shellcheck disable=SC2016
            echo '[nix-flake-templates] Template init done. You can remove `app.template-init` from flake.nix now.'
          '';
        };

        devenv.shells.default = let
          inherit (crateOutputs) devShell;
        in {
          name = "REPLACE_ME";

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
