{ lib, pkgs, ... }: {
  nix.settings = {
    keep-going = lib.mkDefault true;
    keep-derivations = lib.mkDefault true;
    keep-outputs = lib.mkDefault true;
  };

  environment.systemPackages = with pkgs; [ vim ];

  nix.linux-builder.enable = lib.mkDefault true;
}
