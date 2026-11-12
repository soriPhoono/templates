{
  perSystem =
    { pkgs, ... }:
    {
      checks.gdlint = pkgs.runCommand "gdlint" { nativeBuildInputs = [ pkgs.gdtoolkit_4 ]; } ''
        # gdlint caches its parser under $HOME, which is read-only in the sandbox
        export HOME=$TMPDIR
        gdlint ${../scripts}
        touch $out
      '';
    };
}
