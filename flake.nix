{
  description = "Configurations for machines at Fourier";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, systems, nix-darwin }:
    let
      inherit (nixpkgs) lib;
      eachSystem = lib.genAttrs (import systems);

      fourier-default-configuration = { pkgs, ... }: {
        # List packages installed in system profile. To search by name, run:
        # $ nix-env -qaP | grep wget
        environment.systemPackages = [ pkgs.vim ];

        # Necessary for using flakes on this system.
        nix.settings.experimental-features = "nix-command flakes";

        # Enable alternative shell support in nix-darwin.
        # programs.fish.enable = true;

        # Set Git commit hash for darwin-version.
        system.configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        system.stateVersion = 5;

        # The platform the configuration will be used on.
        nixpkgs.hostPlatform = "aarch64-darwin";
      };
    in {
      # Build this generic configuration using:
      # $ darwin-rebuild build --flake .#fourier-default
      darwinConfigurations."fourier-default" = nix-darwin.lib.darwinSystem {
        modules = [ fourier-default-configuration ];
      };

      # Jacob Birkett (SWE)
      darwinConfigurations."excelsior" = nix-darwin.lib.darwinSystem {
        modules = [ fourier-default-configuration ];
      };

      # $ nix fmt
      formatter =
        eachSystem (system: nixpkgs.legacyPackages.${system}.nixfmt-classic);
    };
}
