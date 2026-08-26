_: {
  projectRootFile = "flake.nix";

  programs = {
    alejandra.enable = true;
    deadnix.enable = true;
    statix.enable = true;

    ruff-check = {
      enable = true;
      extendSelect = ["I"];
    };
    ruff-format.enable = true;

    yamlfmt.enable = true;

    mdformat.enable = true;
  };
}
