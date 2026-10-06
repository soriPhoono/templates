{
  description = "Electron desktop application template";

  inputs = {
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

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
        # Keep in lockstep with the `electron` version in package.json.
        electron = pkgs.electron_43;
        nodejs = pkgs.nodejs_24;
        pnpm = pkgs.pnpm_11.override {nodejs-slim = pkgs.nodejs-slim_24;};

        application = pkgs.callPackage ./nix/package.nix {
          inherit electron nodejs pnpm;
        };
      in {
        _module.args.pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        packages.default = application;

        # Lint, typecheck and test inside the sandbox against the pinned deps.
        checks.default = application.overrideAttrs (old: {
          name = "${old.pname}-checks";
          src = lib.fileset.toSource {
            root = ./.;
            fileset = lib.fileset.unions [
              ./package.json
              ./pnpm-lock.yaml
              ./pnpm-workspace.yaml
              ./electron.vite.config.ts
              ./resources
              ./src
              ./biome.json
              ./tsconfig.node.json
              ./tsconfig.web.json
              ./tests
            ];
          };
          nativeBuildInputs = old.nativeBuildInputs ++ [pkgs.biome];
          desktopItems = [];
          buildPhase = ''
            runHook preBuild
            # No .git in the sandbox, so Biome cannot read .gitignore.
            biome check --vcs-enabled=false .
            pnpm run typecheck
            pnpm run test
            runHook postBuild
          '';
          installPhase = "touch $out";
        });

        # --- Configuration Builders --- #
        treefmt = import ./treefmt.nix {inherit lib pkgs;};
        pre-commit = import ./pre-commit.nix {inherit lib pkgs pnpm;};

        # --- Development Shell --- #
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            gh

            nixd
            nil
            alejandra

            nodejs
            pnpm
            biome
          ];

          env = {
            # `pnpm dev` runs the same nixpkgs Electron that the package ships.
            ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
            ELECTRON_OVERRIDE_DIST_PATH = "${electron}/libexec/electron";
          };

          shellHook = ''
            ${config.pre-commit.shellHook}

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
