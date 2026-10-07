{
  lib,
  stdenv,
  nodejs,
  pnpm,
  fetchPnpmDeps,
  pnpmConfigHook,
  makeWrapper,
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
        ../tsconfig.json
        ../tsconfig.build.json
        ../src
      ];
    };

    # After any dependency change: set `hash = lib.fakeHash;`, run `nix build`,
    # and copy the `got:` hash from the error back here.
    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      inherit pnpm;
      fetcherVersion = 4;
      hash = "sha256-JxUUtMFNojwlaJVLJePAu5IfigTrIYGcziPIdWvzC88=";
    };

    nativeBuildInputs = [
      nodejs
      pnpm
      pnpmConfigHook
      makeWrapper
    ];

    buildPhase = ''
      runHook preBuild
      pnpm run build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      # Runtime node_modules only: devDependencies are not needed to run dist/.
      rm -rf node_modules
      pnpm install --offline --prod --ignore-scripts --frozen-lockfile

      appDir=$out/lib/${finalAttrs.pname}
      mkdir -p $appDir
      cp -r package.json dist node_modules $appDir/

      # Same default as the Docker image: Express leaks stack traces to clients
      # in its error responses unless NODE_ENV is production.
      makeWrapper ${lib.getExe nodejs} $out/bin/${finalAttrs.pname} \
        --set-default NODE_ENV production \
        --add-flags $appDir/dist/index.js

      runHook postInstall
    '';

    meta = {
      inherit (packageJson) description;
      mainProgram = finalAttrs.pname;
      inherit (nodejs.meta) platforms;
    };
  })
