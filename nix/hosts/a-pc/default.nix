{ inputs, outputs, lib, config, pkgs, modulesPath, ... }: {
  imports = [
    ./hardware-configuration.nix
    "${modulesPath}/profiles/minimal.nix"

    inputs.nixos-wsl.nixosModules.wsl
    ../common
  ];

  wsl = {
    enable = true;
    automountPath = "/mnt";
    defaultUser = "a";
    startMenuLaunchers = true;

    # Enable native Docker support
    docker-native.enable = true;

    # Enable integration with Docker Desktop (needs to be installed)
    docker-desktop.enable = true;

    # TODO: Enable this with newer version of NixOS-WSL.
    # nativeSystemd = true;
  };

  networking.hostName = "A-PC";

  time.timeZone = "Asia/Calcutta";
}
