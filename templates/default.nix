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
  };
}
