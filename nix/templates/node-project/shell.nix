{
  pkgs,
  config,
  ...
}:
with pkgs;
  mkShell {
    packages = [
      gh

      nixd
      nil
      alejandra

      # age

      nodejs
      pnpm
    ];

    shellHook = ''
      ${config.pre-commit.shellHook}

      echo "Node.js $(node --version)"
      echo "pnpm $(pnpm --version)"
    '';
  }
