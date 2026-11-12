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
    python-project = {
      path = ./python-project;
      description = "Python project template with src/ layout, uv, ruff, pyright and pytest";
    };
    rust-tauri-app = {
      path = ./rust-tauri-app;
      description = "Tauri 2 desktop app template with a Nuxt UI frontend and pnpm";
    };
    godot-project-2d = {
      path = ./godot-project-2d;
      description = "Godot 4 GDScript 2D project template with gdtoolkit lint and format";
    };
    godot-project-3d = {
      path = ./godot-project-3d;
      description = "Godot 4 GDScript 3D project template with gdtoolkit lint and format";
    };
  };
}
