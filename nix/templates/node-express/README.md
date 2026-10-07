# express-app

Express 5 API built with TypeScript and pnpm. It ships as a Nix package for
NixOS users and as a Docker image on GitHub Container Registry for everyone
else.

## Getting started

```sh
nix flake init -t github:soriPhoono/templates#node-express
direnv allow   # or: nix develop
pnpm install
pnpm dev
```

Entering the shell for the first time deletes `template.txt` and installs the
pre-commit hooks.

## Rename the placeholder

The template uses `express-app` as its name. Replace it everywhere before the
first commit:

```sh
grep -rl express-app --exclude-dir=node_modules . | xargs sed -i 's/express-app/my-app/g'
```

The Nix package reads `pname`, `version` and `description` from
`package.json`. `name` also becomes the binary name (`meta.mainProgram`).

## Commands

| Command | What it does |
| ---------------- | ------------------------------------------------ |
| `pnpm dev` | Run `src/index.ts` with Node's type stripping and `--watch` |
| `pnpm build` | Compile `src/` to `dist/` with `tsc` |
| `pnpm start` | Run the compiled app from `dist/` |
| `pnpm typecheck` | Typecheck `src/` and `tests/` |
| `pnpm lint` | Biome lint and format check |
| `pnpm test` | Vitest and supertest tests in `tests/` |
| `nix build` | Build the package into `./result` |
| `nix run` | Build and start the API |
| `nix flake check`| treefmt, Biome, typecheck and tests in the sandbox |

## Configuration

| Variable | Default | Notes |
| -------- | ----------- | -------------------------------------------- |
| `PORT` | `3000` | Plain digits, 1 to 65535. Anything else exits 1. |
| `HOST` | `127.0.0.1` | The Docker image sets `0.0.0.0`. |

An empty value counts as unset. The app shuts down gracefully on `SIGTERM` and
`SIGINT` and forces exit 1 if shutdown takes longer than 10 seconds.

## Endpoints

| Route | Response |
| ---------------- | ----------------------------- |
| `GET /healthz` | `200 {"status":"ok"}` |
| `GET /api/hello` | `200 {"message":"Hello, world"}` |

Add routes in `src/app.ts`. `createApp()` never opens a port, so tests use it
directly through supertest.

## Layout

```
src/config.ts   Parse and validate PORT and HOST
src/app.ts      createApp(): the Express routes
src/server.ts   startServer(): listen, and a handle to close it
src/index.ts    Entry point: config, start, signal handling
tests/          Vitest tests
nix/package.nix Nix package
Dockerfile      Container image
```

## Docker image

```sh
docker run -p 3000:3000 ghcr.io/<owner>/<repo>:<version>
```

The image runs as the non-root `node` user and has a healthcheck on
`/healthz`.

### Publishing

`.github/workflows/publish.yml` checks the code, then builds a
`linux/amd64` and `linux/arm64` image and pushes it to
`ghcr.io/<owner>/<repo>` with the built-in `GITHUB_TOKEN`; there are no
secrets to set up.

```sh
git tag v0.1.0 && git push origin v0.1.0
```

- A `v*` tag pushes the tags `0.1.0`, `0.1` and `latest`.
- `workflow_dispatch` builds the image without pushing it.
- GitHub creates the package as private. Open the package settings and set
  the visibility to public once so that anyone can pull the image.

## Updating dependencies

`nix/package.nix` pins the pnpm dependencies with a hash. After any change to
`pnpm-lock.yaml`:

1. Set `hash = lib.fakeHash;` in `nix/package.nix`.
1. Run `nix build`.
1. Copy the `got:` hash from the error back into `hash`.

## Tooling pins

- Node.js 24 (`nodejs_24`) and pnpm 11 (`pnpm_11`) come from nixpkgs. The
  Dockerfile and CI read the pnpm version from `packageManager`.
- Biome comes from nixpkgs, not npm: the npm build is dynamically linked
  against `/lib64/ld-linux` and does not run in the Nix sandbox. CI installs
  it with `biomejs/setup-biome`.
