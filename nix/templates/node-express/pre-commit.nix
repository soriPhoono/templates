{
  pkgs,
  pnpm,
  ...
}: let
  # Run a package.json script against the project's own pinned toolchain.
  pnpmHook = name: script: {
    enable = true;
    inherit name;
    entry = "${pkgs.writeShellScript "${name}-hook" ''
      exec ${pnpm}/bin/pnpm --silent run ${script}
    ''}";
    pass_filenames = false;
  };
in {
  # The pnpm hooks need node_modules, which the sandboxed `nix flake check`
  # does not have; the flake's `checks.default` covers them instead.
  check.enable = false;

  settings.hooks = {
    nil.enable = true;

    biome.enable = true;
    typecheck = pnpmHook "typecheck" "typecheck";
    vitest = pnpmHook "vitest" "test";

    treefmt.enable = true;

    gitleaks = {
      enable = true;
      name = "gitleaks";
      entry = "${pkgs.gitleaks}/bin/gitleaks protect --verbose --redact --staged";
      pass_filenames = false;
    };
  };
}
