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
      };
    };

  };
}
