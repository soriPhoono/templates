# --- flake-parts/shells/default.nix
{ inputs, lib, ... }:
{
  perSystem =
    {
      pkgs,
      config,
      system,
      ...
    }:
    let
      workspace = inputs.uv2nix.lib.workspace.loadWorkspace {
        workspaceRoot = ../../.;
      };

      overlay = workspace.mkPyprojectOverlay {
        sourcePreference = "wheel";
      };

      python = pkgs.python3;

      pythonSet =
        (pkgs.callPackage inputs.pyproject-nix.build.packages {
          inherit python;
        }).overrideScope
          (
            lib.composeManyExtensions [
              inputs.pyproject-build-systems.overlays.wheel
              overlay
            ]
          );

      editableOverlay = workspace.mkEditablePyprojectOverlay {
        root = "$REPO_ROOT";
      };

      editablePythonSet = pythonSet.overrideScope editableOverlay;

      developmentEnvironment = editablePythonSet.mkVirtualEnv "python-app-dev-env" workspace.deps.all;

      productionEnvironment = pythonSet.mkVirtualEnv "python-app-env" workspace.deps.default;

      addMainProgram =
        drv:
        drv.overrideAttrs (old: {
          meta = (old.meta or { }) // {
            mainProgram = "python-app";
          };
        });
    in
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      devShells = {
        default = config.devShells.dev;

        dev = pkgs.callPackage ./dev.nix {
          inherit lib editablePythonSet developmentEnvironment;
          treefmt-wrapper = if (lib.hasAttr "treefmt" config) then config.treefmt.build.wrapper else null;
          dev-process = if (lib.hasAttr "process-compose" config) then config.packages.dev-process else null;
          pre-commit = if (lib.hasAttr "pre-commit" config) then config.pre-commit else null;
        };
      };

      packages.default = addMainProgram productionEnvironment;
    };
}
