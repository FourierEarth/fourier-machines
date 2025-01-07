{ lib, pkgs, ... }: {
  nix.settings = {
    keep-going = lib.mkDefault true;
    keep-derivations = lib.mkDefault true;
    keep-outputs = lib.mkDefault true;
  };

  environment.systemPackages = with pkgs; [ vim ];

  nix.linux-builder.enable = lib.mkDefault true;

  # Only enabled for developers because normal users may not pay attention
  # to what is asking for authentication.
  security.pam.enableSudoTouchIdAuth = lib.mkDefault true;
}
