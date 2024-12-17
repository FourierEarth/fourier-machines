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
    in {
      darwinModules = {
        default-darwin = ./darwin-modules/default-darwin.nix;
        fourier-developer = ./darwin-modules/fourier-developer.nix;

        hardware.m2-macbook-air = ./darwin-modules/hardware/m2-macbook-air.nix;
      };

      # Build this generic configuration using:
      # $ darwin-rebuild build --flake .#fourier-default
      darwinConfigurations."fourier-default" = nix-darwin.lib.darwinSystem {
        pkgs = import nixpkgs {
          localSystem.system = "aarch64-darwin";
          overlays = [ ];
        };
        modules = with self.darwinModules; [
          { nixpkgs.hostPlatform = "aarch64-darwin"; }
          default-darwin
        ];
        specialArgs = { inherit self inputs; };
      };

      # Jacob Birkett (SWE)
      darwinConfigurations."excelsior" = nix-darwin.lib.darwinSystem {
        pkgs = import nixpkgs {
          localSystem.system = "aarch64-darwin";
          overlays = [ ];
        };
        modules = with self.darwinModules; [
          hardware.m2-macbook-air
          default-darwin
          fourier-developer
        ];
        specialArgs = { inherit self inputs; };
      };

      # $ nix fmt
      formatter =
        eachSystem (system: nixpkgs.legacyPackages.${system}.nixfmt-classic);
    };
}
