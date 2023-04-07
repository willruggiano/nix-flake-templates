{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    devenv.url = "github:cachix/devenv";
    flake-parts.url = "github:hercules-ci/flake-parts";
    pre-commit-nix.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = {flake-parts, ...} @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.devenv.flakeModule
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
            git init && git add -A && git commit -m 'chore: initial commit'
            echo 'use flake' > .envrc && direnv allow
            # shellcheck disable=SC2016
            echo '[nix-flake-templates] Template init done. You can remove `app.template-init` from flake.nix now.'
          '';
        };

        apps.generate-vimdoc.program = pkgs.writeShellApplication {
          name = "generate-vimdoc";
          runtimeInputs = with pkgs; [lemmy-help];
          text = ''
            lemmy-help -c lua/REPLACE_ME.lua > doc/REPLACE_ME.txt
          '';
        };

        devenv.shells.default = {
          name = "REPLACE_ME.nvim";
          packages = with pkgs; [lemmy-help luajit];
          pre-commit.hooks = {
            alejandra.enable = true;
            stylua.enable = true;
          };
        };

        formatter = pkgs.alejandra;

        packages.default = pkgs.vimUtils.buildVimPluginFrom2Nix {
          name = "REPLACE_ME.nvim";
          src = ./.;
        };
      };
    };
}
