{
  writeShellApplication,
  cargo,
  coreutils,
  findutils,
  gnused,
  ripgrep,
  ...
}:
writeShellApplication {
  name = "template-init";
  runtimeInputs = [cargo coreutils findutils gnused ripgrep];
  text = ''
    nix flake init -t github:willruggiano/nix-flake-templates#rust

    DIRNAME="$(basename "$(pwd)")"
    FLAKE_NAME="''${FLAKE_NAME:-"$DIRNAME"}"
    FLAKE_CRATE_NAME="''${FLAKE_CRATE_NAME:-$(basename -s .nix "$DIRNAME")}"
    rg -l FLAKE_NAME | xargs -I{} sed -i s/FLAKE_NAME/"$FLAKE_NAME"/g {}
    rg -l FLAKE_CRATE_NAME | xargs -I{} sed -i s/FLAKE_CRATE_NAME/"$(echo "$FLAKE_CRATE_NAME" | tr '-' '_')"/g {}

    nix flake lock
    cargo generate-lockfile

    git init && git add -A
    git commit -m 'chore: initial commit'
    echo 'use flake --impure' > .envrc && direnv allow
  '';
}
