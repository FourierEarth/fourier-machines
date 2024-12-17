{
  nixpkgs.hostPlatform = "aarch64-darwin";

  nix.settings = {
    cores = 6;
    max-jobs = 4;
  };
}
