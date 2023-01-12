{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    pre-commit-nix.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = {flake-parts, ...} @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.pre-commit-nix.flakeModule
      ];

      systems = ["x86_64-linux" "aarch64-darwin"];
      perSystem = {
        config,
        pkgs,
        system,
        ...
      }: {
        apps.template-init.program = pkgs.writeShellApplication {
          name = "template-init";
          runtimeInputs = with pkgs; [gnused ripgrep];
          text = ''
            mv lua/plugin.lua "lua/$1.lua"
            rg -l REPLACE_ME | xargs -I{} sed -i s/REPLACE_ME/"$1"/g {}
            # shellcheck disable=SC2016
            echo '[nix-flake-templates] Template init done. You can remove `app.template-init` from flake.nix now.'
          '';
        };

        apps.update-docs.program = pkgs.writeShellApplication {
          name = "update-docs";
          runtimeInputs = with pkgs; [lemmy-help];
          text = ''
            lemmy-help lua/REPLACE_ME.lua > doc/REPLACE_ME.txt
          '';
        };

        devShells.default = pkgs.mkShell {
          name = "REPLACE_ME-nvim";
          buildInputs = with pkgs; [lemmy-help];
          shellHook = ''
            ${config.pre-commit.installationScript}
          '';
        };

        formatter = pkgs.alejandra;

        pre-commit = {
          settings = {
            hooks.alejandra.enable = true;
            hooks.stylua.enable = true;
          };
        };
      };
    };
}
