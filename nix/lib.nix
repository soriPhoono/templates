_final: prev: {
  homelab = {
    core = {
      discover = dir:
        prev.mapAttrs
        (name: _: {
          value = dir + "/${name}";
        })
        (
          prev.filterAttrs (
            name: type: (type == "directory" && builtins.pathExists (dir + "/${name}/nix/"))
          ) (builtins.readDir dir)
        );
    };
  };
}
