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
      toolchain = pkgs.rust-bin.fromRustupToolchainFile ../../rust-toolchain.toml;
      craneLib = (inputs.crane.mkLib pkgs).overrideToolchain toolchain;

      commonArgs = {
        pname = "templates-cli";
        version = "0.1.0";
        src = craneLib.cleanCargoSource ../../.;
        strictDeps = true;
      };

      cargoArtifacts = craneLib.buildDepsOnly commonArgs;

      templates-cli = craneLib.buildPackage (
        commonArgs
        // {
          inherit cargoArtifacts;
          cargoExtraArgs = "--package templates-cli";
          meta.mainProgram = "templates-cli";
        }
      );
    in
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ inputs.rust-overlay.overlays.default ];
      };

      devShells = {
        default = config.devShells.dev;

        dev = pkgs.callPackage ./dev.nix {
          inherit lib toolchain;
          treefmt-wrapper = if (lib.hasAttr "treefmt" config) then config.treefmt.build.wrapper else null;
          dev-process = if (lib.hasAttr "process-compose" config) then config.packages.dev-process else null;
          pre-commit = if (lib.hasAttr "pre-commit" config) then config.pre-commit else null;
        };
      };

      packages.default = templates-cli;

      apps.default = {
        type = "app";
        program = lib.getExe templates-cli;
      };

      checks = {
        inherit templates-cli;

        clippy = craneLib.cargoClippy (
          commonArgs
          // {
            inherit cargoArtifacts;
            cargoClippyExtraArgs = "--all-targets -- --deny warnings";
          }
        );

        test = craneLib.cargoTest (commonArgs // { inherit cargoArtifacts; });
      };
    };
}
