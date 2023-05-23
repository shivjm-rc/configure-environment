{ inputs, outputs, lib, config, pkgs, modulesPath, ... }: {
  imports = [
    ./hardware-configuration.nix
    "${modulesPath}/profiles/minimal.nix"

    inputs.nixos-wsl.nixosModules.wsl
    ../common
  ];

  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    wslConf.interop = {
      enabled = false;
      appendWindowsPath = false;
    };
    defaultUser = "a";
    startMenuLaunchers = true;

    # Enable native Docker support
    docker-native.enable = true;

    # Enable integration with Docker Desktop (needs to be installed)
    docker-desktop.enable = true;

    # This requires htngr/NixOS-WSL to work. See the README.
    nativeSystemd = true;
  };

  networking.hostName = "A-PC";

  time.timeZone = "Asia/Calcutta";
}
