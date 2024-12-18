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

      mkFourierDarwinSystem = hostname:
        {
        # This is named so because it will turn up as `nixpkgs.hostPlatform` in the module system.
        # Here it directly affects `_module.args.pkgs.stdenv.hostPlatform`,
        # since `_module.args.pkgs` is explicitly defined.
        hostPlatform ? "aarch64-darwin",
        # By default this is an empty set. You can use any module (set or function),
        # this is not treated specially but is explicitly named to encourage usage.
        hardwareModule ? { },
        # Any other modules specific to this host.
        modules ? [ ],
        # Any extra `pkgs` overlays specific to this host's configurations.
        # If you added a module to `modules` which requires a package,
        # list the overlay which provides said package here.
        overlays ? [ ],
        # Other attributes merged with the argument set of `nix-darwin.lib.darwinSystem`
        # which will pass them to `nix-darwin/eval-config.nix` and then `lib.evalModules`.
        ... }@args:
        let
          ownArgs =
            builtins.attrNames (builtins.functionArgs mkFourierDarwinSystem);
          passthruArgs = removeAttrs args ownArgs;
        in nix-darwin.lib.darwinSystem {
          pkgs = import nixpkgs {
            localSystem.system = hostPlatform;
            overlays = [ nix-darwin.overlays.default ] ++ overlays;
          };
          modules = [ hardwareModule ]
            ++ (with self.darwinModules; [ default-darwin ]) ++ modules;
          specialArgs = { inherit self inputs; };
        } // passthruArgs;
    in {
      darwinModules = importNixFlat ./darwin-modules // {
        hardware = importNixFlat ./darwin-modules/hardware;
      };

      # Build this generic configuration using:
      # $ darwin-rebuild build --flake .#fourier-default
      darwinConfigurations."fourier-default" = mkFourierDarwinSystem null { };

      # Jacob Birkett (SWE)
      darwinConfigurations."excelsior" = mkFourierDarwinSystem "excelsior" {
        hardwareModule = self.darwinModules.hardware.m2-macbook-air;
        modules = with self.darwinModules; [ default-darwin fourier-developer ];
      };

      # $ nix fmt
      formatter =
        eachSystem (system: nixpkgs.legacyPackages.${system}.nixfmt-classic);
    };
}
