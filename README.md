# templates

Repository of practical and actively used nix templates for software development and devops

## Templates

- `node-electron`: Electron desktop app (electron-vite, TypeScript, pnpm) packaged against the nixpkgs Electron. `nix flake init -t github:soriPhoono/templates#node-electron`. See [its README](nix/templates/node-electron/README.md).
- `node-express`: Express 5 API (TypeScript, pnpm) with a Nix package and a Docker image published to GHCR. `nix flake init -t github:soriPhoono/templates#node-express`. See [its README](nix/templates/node-express/README.md).
