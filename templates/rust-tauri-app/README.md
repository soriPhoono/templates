# Rust Tauri App

Tauri 2 desktop app with a Nuxt UI frontend, packaged as a Nix flake template.

## Quick Start

```bash
nix flake init -t github:soriPhoono/templates#rust-tauri-app
nix develop
pnpm install
pnpm tauri dev
```

## Commands

- `pnpm dev`: Nuxt dev server on `http://localhost:3000` (browser only)
- `pnpm tauri dev`: Tauri window pointing at the dev server
- `pnpm tauri build`: production bundle
- `pnpm lint`: ESLint
- `pnpm typecheck`: Nuxt type check

## Layout

- `app/`: Nuxt frontend
- `src-tauri/`: Rust backend and Tauri config
- `flake-system/`: flake-parts modules (devShell, treefmt, pre-commit)

## License

See `LICENSE`.
