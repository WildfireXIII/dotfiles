{ system, pkgs, home-manager, lib, user, ... }:
with builtins;
{
	# I'm pretty sure we need an additional parameter for "extra" stuff or something
	mkhost = { name, NICs, initrdMods, kernelMods, kernelParams, kernelPackage,
		systemConfig, cpuCores, users, wifi ? [],
		gpuTempSensor ? null, cpuTempSensor ? null
	}:
	let
		# turns list of strings into list of dictionaries
		networkCfg = listToAttrs (map (n: {
			name = "${n}"; value = { useDHCP = true; };
		}) NICs);

		userCfg = {
			inherit name NICs systemConfig cpuCores gpuTempSensor cpuTempSensor;
		};

		# wait, is this making everyone root?
		sys_users = (map (u: user.mkSystemUser u) users);

	in lib.nixosSystem {
		inherit system;
		
		modules = [
			{
				imports = [ ../modules/system ] ++ sys_users;
				
				# no idea what this is for, in original it's "jd"
				# these are custom options in a special attribute set?
				dwl = systemConfig;

				environment.etc = {
					"hmsystemdata.json".text = toJSON userCfg;
				};

				networking.hostName = "${name}";
				networking.interfaces = networkCfg;
				networking.wireless.interfaces = wifi;

				networking.networkmanager.enable = true;
				networking.useDHCP = false;
			
				boot.initrd.availableKernelModules = initrdMods;
				boot.kernelModules = kernelMods;
				boot.kernelParams = kernelParams;
				boot.kernelPackages = kernelPackage;

				nixpkgs.pkgs = pkgs;
				nix.maxJobs = lib.mkDefault cpuCores;

				system.stateVersion = "21.05"
			}
		];
	};
}
