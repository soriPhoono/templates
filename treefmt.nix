_: {
  projectRootFile = "flake.nix";

  programs = {
    alejandra.enable = true;
    deadnix.enable = true;
    statix.enable = true;

    yamlfmt.enable = true;

    mdformat.enable = true;
  };

  # Generated lockfiles inside templates must stay byte-for-byte as emitted.
  settings.global.excludes = ["**/pnpm-lock.yaml"];
}
