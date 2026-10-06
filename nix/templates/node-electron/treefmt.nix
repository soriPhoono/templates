{lib, ...}: {
  projectRootFile = "flake.nix";

  programs = {
    alejandra.enable = true;
    deadnix.enable = true;
    statix.enable = true;

    # Formatting only, driven by biome.json; linting runs in the pre-commit hook.
    biome = {
      enable = true;
      formatCommand = "format";
      settings.formatter = (lib.importJSON ./biome.json).formatter;
    };

    yamlfmt.enable = true;

    mdformat.enable = true;
  };

  settings.global.excludes = ["pnpm-lock.yaml"];
}
