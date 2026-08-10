{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  modulesPath,
  arch,
  ...
}:
{
  imports = [
    # ./hardware-configuration.nix
    "${modulesPath}/profiles/minimal.nix"

    ../common
  ];

  nix.gc = {
    automatic = true;
    dates = "Sat *-*-* 16:21:00";
    options = "--delete-older-than 30d";
  };
}
