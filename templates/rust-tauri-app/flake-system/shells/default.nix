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

      # Tauri v2 system libraries (https://v2.tauri.app/start/prerequisites/#linux)
      tauriNativeBuildInputs = with pkgs; [
        pkg-config
        wrapGAppsHook3
      ];

      tauriBuildInputs = with pkgs; [
        dbus
        glib
        gtk3
        libayatana-appindicator
        librsvg
        libsoup_3
        openssl
        webkitgtk_4_1
        xdg-utils
      ];

      commonArgs = {
        pname = "app";
        version = "0.1.0";
        # tauri::generate_context! reads tauri.conf.json, capabilities and icons at compile time.
        src = lib.cleanSourceWith {
          src = ../../.;
          filter =
            path: type:
            (craneLib.filterCargoSources path type)
            || (builtins.match ".*/src-tauri/(tauri\\.conf\\.json|capabilities/.*|icons/.*)" path != null);
          name = "source";
        };
        strictDeps = true;
        nativeBuildInputs = tauriNativeBuildInputs;
        buildInputs = tauriBuildInputs;
      };

      cargoArtifacts = craneLib.buildDepsOnly commonArgs;
    in
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ inputs.rust-overlay.overlays.default ];
      };

      devShells = {
        default = config.devShells.dev;

        dev = pkgs.callPackage ./dev.nix {
          inherit
            lib
            pkgs
            toolchain
            tauriNativeBuildInputs
            tauriBuildInputs
            ;
          treefmt-wrapper = if (lib.hasAttr "treefmt" config) then config.treefmt.build.wrapper else null;
          dev-process = if (lib.hasAttr "process-compose" config) then config.packages.dev-process else null;
          pre-commit = if (lib.hasAttr "pre-commit" config) then config.pre-commit else null;
        };
      };

      checks = {
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
