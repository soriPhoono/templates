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

      # Remove template.txt if it exists after first shell creation
      if [[ -f ./template.txt ]]; then
        echo "Removing template.txt..."
        rm ./template.txt
      fi

      echo "Node.js $(node --version)"
      echo "pnpm $(pnpm --version)"
    '';
  }
