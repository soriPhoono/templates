# Tauri desktop app, built with nixpkgs' cargo-tauri hook (https://nixos.org/manual/nixpkgs/stable/#tauri)
{
  lib,
  rustPlatform,
  cargo-tauri,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm,
  nodejs,
  tauriNativeBuildInputs,
  tauriBuildInputs,
}:
let
  cargoToml = lib.importTOML ../../src-tauri/Cargo.toml;
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = cargoToml.package.name;
  inherit (cargoToml.package) version;

  src = ../../.;
  cargoLock.lockFile = ../../Cargo.lock;

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-/KkYzwIGb7GqsVkdDUwU3Sp+q0komTANq7q2Ht6QT54=";
  };

  nativeBuildInputs = [
    cargo-tauri.hook
    nodejs
    pnpm
    pnpmConfigHook
  ]
  ++ tauriNativeBuildInputs;
  buildInputs = tauriBuildInputs;

  # No TTY in the sandbox for Nuxt's telemetry consent prompt
  env.NUXT_TELEMETRY_DISABLED = "1";

  # The workspace test suite is covered by the crane checks.
  doCheck = false;

  meta = {
    description = "Tauri desktop app with a Nuxt UI frontend";
    mainProgram = cargoToml.package.name;
  };
})
