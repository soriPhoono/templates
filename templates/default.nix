{
  outputs.templates = rec {
    default = empty;
    empty = {
      path = ./empty;
      description = "Empty project template based on flake-file using flake-parts";
    };
  };
}
