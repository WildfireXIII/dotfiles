{
  description = "System configuration flake. Mostly stolen from https://jdisaacs.com/blog/nixos-config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable"
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };


  # what's the @ again?
  outputs = { self, nixpkgs, home-manager, ...}@inputs: 
  let inherit (nixpkgs) lib;

  # custom local nix library (we have some useful functions there, like mkHMUser and mkHost)
  util = import ./lib {
    inherit system pkgs home-manager lib; overlays = (pkgs.overlays);
  };
  inherit (util) user;
  inherit (util) host;

  system = "x86_64-linux" # isn't there a way to get this from builtins? does that work in flakes?


  in {

    homeManagerConfigurations = {
      dwl = user.mkHMUser {
        # ...
      };
    };

    nixosConfigurations = {
      vm = host.mkHost {
	name = "test_vm";
	kernelPackage = pkgs.linuxPackages;
	initrdMods = [  "ata_piix" "ohci_pci" "sd_mod" "sr_mod" ];
	kernelMods = [];
	kernelParams = [];
	systemConfig = {}
      };
	users = [{
		name = "dwl";
		groups = [ "networkmanager" ];
		uid = 1000;
		shell = pkgs.bash;
	}];
	# how to put file system stuff/swap??
    };

  };
}
