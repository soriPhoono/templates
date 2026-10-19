{
  flake.templates = rec {
    default = empty;
    empty = {
      path = ./empty;
      description = "Empty project template based on flake-file using flake-parts";
    };
    rust-project = {
      path = ./rust-project;
      description = "Rust workspace template with crane, rust-overlay and clippy checks";
    };
    rust-tauri-app = {
      path = ./rust-tauri-app;
      description = "Tauri 2 desktop app template with a Nuxt UI frontend and pnpm";
    };
  };
}
