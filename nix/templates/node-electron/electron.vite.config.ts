import { resolve } from "node:path";
import { defineConfig } from "electron-vite";

// Native modules (e.g. better-sqlite3) must stay out of the bundle: list them
// under `dependencies` and electron-vite externalizes them for main/preload.
// They then also need rebuilding against the nixpkgs Electron headers.
export default defineConfig({
  main: {},
  preload: {},
  renderer: {
    root: resolve(__dirname, "src/renderer"),
    build: {
      rollupOptions: {
        input: resolve(__dirname, "src/renderer/index.html"),
      },
    },
  },
});
