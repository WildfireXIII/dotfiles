{ pkgs, home-manager, lib, system, overlays, ... }:
with builtins;
{
	mkHMUser = { };

	mkSystemUser = { name, groups, uid, shell, ... }:
	{
		users.users."${name}" = {
			name = name;
			isNormalUser = true;
			isSystemUser = false;
			extraGroups = groups;
			uid = uid;
			initialPassword = "helloworld"
			shell = shell;
		};
	};
}
