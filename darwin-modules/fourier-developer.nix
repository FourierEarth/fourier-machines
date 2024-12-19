{ pkgs, ... }: {
  nix.settings = {
    keep-going = true;
    keep-derivations = true;
    keep-outputs = true;
  };

  environment.systemPackages = with pkgs; [ vim ];

  nix.linux-builder.enable = true;
}
