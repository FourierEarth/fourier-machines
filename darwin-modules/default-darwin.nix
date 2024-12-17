{ self, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    darwin-option
    darwin-rebuild
    darwin-version
    darwin-uninstaller
  ];

  nix.optimise.automatic = true;
  nix.settings = {
    sandbox = true;
    experimental-features = "nix-command flakes";
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;
}
