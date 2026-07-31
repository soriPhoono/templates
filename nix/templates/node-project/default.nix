{pkgs, ...}:
pkgs.buildNpmPackage {
  pname = "starter";
  version = "0.1.0";

  src = ./src;
  npmDepsHash = "sha256-M6gFH0DuXoghcUMWkoi7iSanJEqRcVotx+Iq/wUtebY=";

  forceEmptyCache = true; # REMOVE THIS
}
