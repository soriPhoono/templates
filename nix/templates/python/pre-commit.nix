{pkgs, ...}: {
  settings.hooks = {
    nil.enable = true;

    pyright.enable = true;

    pytest = {
      enable = true;
      name = "pytest";
      entry = "${pkgs.writeShellScript "pytest-hook" ''
        export PYTHONPATH="$PWD/src''${PYTHONPATH:+:$PYTHONPATH}"
        exec ${pkgs.python3Packages.pytest}/bin/pytest -q
      ''}";
      pass_filenames = false;
    };

    ruff.enable = true;
    ruff-format.enable = true;

    treefmt.enable = true;

    gitleaks = {
      enable = true;
      name = "gitleaks";
      entry = "${pkgs.gitleaks}/bin/gitleaks protect --verbose --redact --staged";
      pass_filenames = false;
    };
  };
}
