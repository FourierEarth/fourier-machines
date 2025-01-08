{ lib, ... }: {
  nix.settings = {
    cores = lib.mkDefault 6;
    max-jobs = lib.mkDefault 4;
  };
}
