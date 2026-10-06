{
  lib,
  stdenv,
  nodejs,
  pnpm,
  fetchPnpmDeps,
  pnpmConfigHook,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  electron,
}: let
  packageJson = lib.importJSON ../package.json;
in
  stdenv.mkDerivation (finalAttrs: {
    pname = packageJson.name;
    inherit (packageJson) version;

    src = lib.fileset.toSource {
      root = ../.;
      fileset = lib.fileset.unions [
        ../package.json
        ../pnpm-lock.yaml
        ../pnpm-workspace.yaml
        ../electron.vite.config.ts
        ../resources
        ../src
      ];
    };

    # After any dependency change: set `hash = "sha256-KZOhZBt4RiAaAaACzlHhMhIF1T3id7Szo3vxAzgqBkI=";`, run `nix build`,
    # and copy the `got:` hash from the error back here.
    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      inherit pnpm;
      fetcherVersion = 4;
      hash = "sha256-KZOhZBt4RiAaAaACzlHhMhIF1T3id7Szo3vxAzgqBkI=";
    };

    nativeBuildInputs = [
      nodejs
      pnpm
      pnpmConfigHook
      makeWrapper
      copyDesktopItems
    ];

    # Use the nixpkgs Electron; never download a prebuilt one.
    env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

    buildPhase = ''
      runHook preBuild
      pnpm run build
      runHook postBuild
    '';

    desktopItems = [
      (makeDesktopItem {
        name = finalAttrs.pname;
        desktopName = "Electron App";
        comment = packageJson.description;
        exec = "${finalAttrs.pname} %U";
        icon = finalAttrs.pname;
        startupWMClass = finalAttrs.pname;
        categories = ["Utility"];
      })
    ];

    installPhase = ''
      runHook preInstall

      # Runtime node_modules only: everything in devDependencies is bundled.
      rm -rf node_modules
      pnpm install --offline --prod --ignore-scripts --frozen-lockfile

      appDir=$out/share/${finalAttrs.pname}
      mkdir -p $appDir
      cp -r package.json out node_modules $appDir/

      install -Dm644 resources/icon.svg \
        $out/share/icons/hicolor/scalable/apps/${finalAttrs.pname}.svg

      makeWrapper ${lib.getExe electron} $out/bin/${finalAttrs.pname} \
        --add-flags $appDir \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"

      runHook postInstall
    '';

    meta = {
      inherit (packageJson) description;
      mainProgram = finalAttrs.pname;
      inherit (electron.meta) platforms;
    };
  })
