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

      importNixFlat = dir:
        lib.pipe (builtins.readDir dir) [
          (lib.filterAttrs
            (name: kind: kind == "regular" && lib.hasSuffix ".nix" name))
          (lib.mapAttrs' (name: _: {
            name = lib.removeSuffix ".nix" name;
            value = import "${dir}/${name}";
          }))
        ];
    in {
      darwinModules = importNixFlat ./darwin-modules // {
        hardware = importNixFlat ./darwin-modules/hardware;
      };

      # Build this generic configuration using:
      # $ darwin-rebuild build --flake .#fourier-default
      darwinConfigurations."fourier-default" = nix-darwin.lib.darwinSystem {
        pkgs = import nixpkgs {
          localSystem.system = "aarch64-darwin";
          overlays = [ nix-darwin.overlays.default ];
        };
        modules = with self.darwinModules; [ default-darwin ];
        specialArgs = { inherit self inputs; };
      };

      # Jacob Birkett (SWE)
      darwinConfigurations."excelsior" = nix-darwin.lib.darwinSystem {
        pkgs = import nixpkgs {
          localSystem.system = "aarch64-darwin";
          overlays = [ nix-darwin.overlays.default ];
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
