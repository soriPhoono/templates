{ inputs, lib, ... }: {
  flake-file = {
    outputs = "flake-parts";
    inputs = {
      flake-file.url = lib.mkDefault "github:denful/flake-file";
    };
  };

  systems = lib.systems.flakeExposed;

  imports = [
    (inputs.flake-file.lib.flakeModules.flake-parts-builder ../flake-system)
    inputs.flake-file.flakeModules.default
    inputs.flake-file.flakeModules.auto-follow

    ./inputs.nix
    ../templates
  ];
}
