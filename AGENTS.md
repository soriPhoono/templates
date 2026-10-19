# AGENTS.md

## Project Overview

`soriPhoono/templates` is a collection of Nix flake templates. Consumers run:

```sh
nix flake init -t github:soriPhoono/templates#<name>
```

- **Stack:** flake-parts + [flake-file](https://github.com/denful/flake-file) (generates `flake.nix` from modules) + treefmt-nix + pre-commit-hooks.
- **The repo root is itself a flake** using the same skeleton as the templates, so root and templates share structure.
- **Templates** live in `templates/<name>/`:
  - `empty`: bare flake + devShell. Registered as `default`.
  - `rust-project`: Cargo workspace (`templates-core` lib, `templates-cli` bin), toolchain pinned in `rust-toolchain.toml` via rust-overlay, crane build with clippy and test checks. Registered.
  - `python-uv-project`: `src/` layout, uv, ruff, pyright, pytest (`pyproject.toml`, `uv.lock`).
  - `rust-tauri-app`: Tauri 2 shell (`src-tauri/`) with a Nuxt UI frontend (`app/`), pnpm. Registered.

## Repository Layout

- `flake.nix`: **auto-generated, do not edit.** Regenerate with `nix run .#write-flake`.
- `modules/default.nix`: flake-parts entrypoint; imports `flake-system/` parts, flake-file modules, `modules/inputs.nix` and `templates/`.
- `modules/inputs.nix`: input declarations (`flake-file.inputs`). Edit here, then run `nix run .#write-flake`.
- `flake-system/`: reusable flake-parts parts (`shells/`, `treefmt.nix`, `pre-commit-hooks.nix`, `systems.nix`, `flake-root.nix`). `_meta/` holds the part manifests used by the flake-parts builder.
- `templates/default.nix`: **the template registry.** Each template needs an entry in `flake.templates`.
- `.github/workflows/`: `flake-check.yml` (CI gate) and `update-flake-lock.yml` (weekly lock update PR).

Each template directory is a full standalone project: its own `flake.nix`, `flake.lock`, `modules/`, `flake-system/`, `.github/`, `.envrc`.

## Setup Commands

- Enter the dev environment: `direnv allow` (`.envrc` runs `use flake`) or `nix develop`.
- The devShell installs the pre-commit hooks (symlinks `.pre-commit-config.yaml`; it is gitignored) and provides `nil`, `statix`, `deadnix`, `nixfmt-rfc-style`, `markdownlint-cli`, `treefmt`.
- Regenerate `flake.nix`: `nix run .#write-flake`
- Update inputs: `nix flake update`, then `nix run .#write-lock` if flake-file requires it.

## Testing and Validation

- Evaluate and check everything: `nix flake check` (fast, no builds: `nix flake check --no-build`). CI runs `nix-fast-build` on checks, packages and devShells.
- Format: `nix fmt` (treefmt: nixfmt, statix, deadnix, prettier, yamlfmt, jsonfmt, shellcheck, shfmt, actionlint).
- Verify a template: copy it out and check it standalone.

  ```sh
  nix flake init -t .#<name>   # run inside an empty temp directory
  nix flake check
  ```

- Rust template: `nix flake check` runs clippy (`--deny warnings`) and `cargo test` through crane; `nix run` inside `templates/rust-project` runs the CLI. `Cargo.lock` is part of the template.
- Python template tests: inside `templates/python-uv-project`, `uv run pytest`, `uv run ruff check`, `uv run pyright`.

## Code Style

- **Nix:** formatted by `nixfmt` (RFC style); `statix` and `deadnix` must pass. Prefer upstream nixpkgs and existing flake-parts modules over custom code.
- **Markdown:** `markdownlint` runs in pre-commit.
- **Files:** no trailing whitespace, newline at EOF, LF endings (pre-commit enforces). `gitleaks` scans commits.
- Keep `flake-system/` identical between the root and each template unless a template needs a deliberate difference. `diff -r flake-system templates/<name>/flake-system` shows drift.

## Adding or Changing a Template

1. Create `templates/<name>/` from `templates/empty/` (copy the whole directory).
2. Add the language-specific inputs in the template's `modules/inputs.nix` and modules in its `modules/default.nix`, then run `nix run .#write-flake` inside the template.
3. **Register it** in `templates/default.nix` with `path` and `description`. An unregistered template cannot be used with `nix flake init -t`.
4. Run `nix flake check` at the root and inside the instantiated template.

## Git and PR Guidelines

- Conventional commits: `feat:`, `fix:`, `chore:`, `refactor:`, `docs:`, `test:`. One logical change per commit (commitizen hook enforces).
- **Branching:** this repo has only `main` (no `dev` branch). Branch off `main` (`feat/<name>`), merge via PR.
- Before a PR: `nix flake check` passes and `nix fmt` leaves no diff.
- Do not run deployment commands (`nixos-rebuild`, `home-manager switch`, `nh`). Hand off to the maintainer.

## Gotchas

- `flake.lock` files are excluded from pre-commit formatting. Do not hand-edit them.
- Lockfiles of a template (`uv.lock`, `flake.lock`) are part of the template; refresh them with the tool, not by hand.
- `.github/workflows/update-flake-lock.yml` opens weekly PRs against the root; template lockfiles are not updated by it.
- `templates/default.nix` currently registers `empty`, `rust-project` and `rust-tauri-app`. `python-uv-project` exists on disk but is not yet exported.
- The root `rename-project` devShell script (`rename-project <dir> <name>`) seds `templates` to the new name across a directory.
- Notion project page "Nix templates repo" describes an older layout (`nix/lib.nix`, `template.txt`, node templates). The current flake-file layout above is authoritative.
