{
  description = "Python project template";

  inputs = {
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    flake-parts,
    nixpkgs,
    pyproject-build-systems,
    pyproject-nix,
    uv2nix,
    ...
  }: let
    systems = import inputs.systems;

    lib = nixpkgs.lib.extend (import ./nix/lib.nix);
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = with inputs; [
        treefmt-nix.flakeModule
        git-hooks-nix.flakeModule
      ];

      inherit systems;

      perSystem = {
        pkgs,
        config,
        system,
        ...
      }: let
        workspace = uv2nix.lib.workspace.loadWorkspace {
          workspaceRoot = ./.;
        };

        overlay = workspace.mkPyprojectOverlay {
          sourcePreference = "wheel";
        };

        python = pkgs.python3;

        pythonSet =
          (pkgs.callPackage pyproject-nix.build.packages {
            inherit python;
          }).overrideScope (
            lib.composeManyExtensions [
              pyproject-build-systems.overlays.wheel
              overlay
            ]
          );

        editableOverlay = workspace.mkEditablePyprojectOverlay {
          root = "$REPO_ROOT";
        };

        editablePythonSet = pythonSet.overrideScope editableOverlay;

        developmentEnvironment = editablePythonSet.mkVirtualEnv "python-app-dev-env" workspace.deps.all;

        application = pythonSet.mkVirtualEnv "python-app-env" workspace.deps.default;

        addMainProgram = drv:
          drv.overrideAttrs (old: {
            meta =
              (old.meta or {})
              // {
                mainProgram = "python-app";
              };
          });
      in {
        _module.args.pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        packages.default = addMainProgram application;

        # --- Configuration Builders --- #
        treefmt = import ./treefmt.nix {inherit lib pkgs;};
        pre-commit = import ./pre-commit.nix {inherit lib pkgs;};

        # --- Pure uv2nix Development Shell --- #
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            gh

            nixd
            nil
            alejandra

            uv

            developmentEnvironment
          ];

          env = {
            UV_NO_SYNC = "1";
            UV_PYTHON = editablePythonSet.python.interpreter;
            UV_PYTHON_DOWNLOADS = "never";
          };

          shellHook = ''
            ${config.pre-commit.shellHook}

            unset PYTHONPATH
            export REPO_ROOT=$(git rev-parse --show-toplevel)

            # Remove template.txt if it exists after first shell creation
            if [[ -f ./template.txt ]]; then
              echo "Removing template.txt..."
              rm ./template.txt
            fi
          '';
        };
      };
    };
}
