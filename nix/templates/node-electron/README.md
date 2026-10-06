# electron-app

Electron desktop application built with electron-vite, TypeScript and pnpm,
packaged with Nix against the nixpkgs Electron.

## Getting started

```sh
nix flake init -t github:soriPhoono/templates#node-electron
direnv allow   # or: nix develop
pnpm install
pnpm dev
```

Entering the shell for the first time deletes `template.txt` and installs the
pre-commit hooks.

## Rename the placeholder

The template uses `electron-app` as its name. Replace it everywhere before the
first commit:

```sh
grep -rl electron-app --exclude-dir=node_modules . | xargs sed -i 's/electron-app/my-app/g'
```

Then update the human-readable `desktopName = "Electron App"` in
`nix/package.nix`.

The Nix package reads `pname`, `version` and `description` from `package.json`.
`name` also becomes the binary name (`meta.mainProgram`), the `.desktop` entry,
the icon name and the window class.

## Commands

| Command | What it does |
| ---------------- | ---------------------------------------------- |
| `pnpm dev` | Run with hot reload against the nixpkgs Electron |
| `pnpm build` | Bundle main, preload and renderer into `out/` |
| `pnpm typecheck` | Typecheck the Node and web halves |
| `pnpm lint` | Biome lint and format check |
| `pnpm test` | Vitest unit tests in `tests/` |
| `nix build` | Build the package into `./result` |
| `nix run` | Build and launch the app |
| `nix flake check`| treefmt, Biome, typecheck and tests in the sandbox |

## Layout

```
src/main/       Electron main process
src/preload/    contextBridge API exposed to the renderer as `window.api`
src/renderer/   Plain TypeScript UI (index.html is the entry point)
src/shared/     IPC channel names and the typed API contract
tests/          Vitest tests
resources/      App icon
nix/package.nix Nix package
```

The window runs with `contextIsolation`, `sandbox` and no `nodeIntegration`,
under a strict CSP. Add new IPC channels to `src/shared/api.ts`, handle them in
`src/main/index.ts` and expose them in `src/preload/index.ts`.

## Updating dependencies

`nix/package.nix` pins the pnpm dependencies with a hash. After any change to
`pnpm-lock.yaml`:

1. Set `hash = lib.fakeHash;` in `nix/package.nix`.
1. Run `nix build`.
1. Copy the `got:` hash from the error back into `hash`.

`fetchPnpmDeps` fetches every platform's optional binaries so that the hash is
the same on every system. That makes the dependency store several hundred MB.

## Updating Electron

Electron is pinned in two places that must match:

- `flake.nix`: `electron = pkgs.electron_43;`
- `package.json`: `"electron": "43.4.1"` (types and the dev runner)

To upgrade, pick the `electron_N` attribute from the locked nixpkgs, set the
npm version to its exact `version`, then refresh the pnpm hash. In development,
`ELECTRON_OVERRIDE_DIST_PATH` points `pnpm dev` at the same nixpkgs Electron.
Npm never downloads an Electron binary.

## Tooling pins

- Node.js 24 (`nodejs_24`) and pnpm 11 (`pnpm_11`) come from nixpkgs.
- Biome comes from nixpkgs, not npm: the npm build is dynamically linked
  against `/lib64/ld-linux` and does not run in the Nix sandbox.

## Native modules

Native modules (for example `better-sqlite3`) must go under `dependencies` so
electron-vite leaves them out of the bundle. They then need to be built against
the nixpkgs Electron headers in `nix/package.nix`. The template ships none.
