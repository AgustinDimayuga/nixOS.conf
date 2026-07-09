{

  description = "My first flake!";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    terminaltexteffects.url = "github:ChrisBuilds/terminaltexteffects";
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      # IMPORTANT: we're using "libgbm" and is only available in unstable so ensure
      # to have it up-to-date or simply don't specify the nixpkgs input
      inputs.nixpkgs.follows = "nixpkgs";
    };
    helium = {
      url = "github:schembriaiden/helium-browser-nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, nixos-hardware, home-manager, zen-browser, helium, terminaltexteffects, ... }:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations = {
        laptop = lib.nixosSystem {
          inherit system;
          modules = [
            nixos-hardware.nixosModules.framework-amd-ai-300-series
            ./configuration.nix
            ./hosts/laptop/hardware-configuration.nix
            ./hosts/laptop/laptopConfig.nix

          ];
        };

        pc = lib.nixosSystem {
          inherit system;

          # make inputs available to modules (incl. home.nix)
          specialArgs = { inherit zen-browser helium; };

          modules = [
            ./configuration.nix
            ./hosts/pc/pc-hardware-configuration.nix
            ./hosts/pc/nvidia.nix
          ];
        };
        gamingPC = lib.nixosSystem {
          inherit system;

          # make inputs available to modules (incl. home.nix)
          specialArgs = { inherit zen-browser helium; };

          modules = [
            ./configuration.nix
            ./hosts/gamingPC/hardware-configuration.nix
            ./hosts/pc/nvidia.nix
            ./hosts/gamingPC/gamingConfig.nix
          ];
        };



      };
      homeConfigurations = {
        agustin = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit zen-browser helium terminaltexteffects; }; # <-- This passes inputs to home.nix
          modules = [ ./home.nix ];
        };
      };

    };
}
