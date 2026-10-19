{ inputs, ... }: {
  imports = [
    (inputs.flake-file.lib.flakeModules.flake-parts-builder ../flake-system)
    inputs.flake-file.flakeModules.default
    inputs.flake-file.flakeModules.auto-follow

    ./inputs.nix
    ../templates
  ];
}
