{ inputs, outputs, lib, config, pkgs, modulesPath, arch, ... }: {
  imports = [
    ./hardware-configuration.nix
    "${modulesPath}/profiles/minimal.nix"

    inputs.nixos-wsl.nixosModules.wsl
    ../common
  ];

  environment.noXlibs = false;

  nix.settings.system-features = [
    "benchmark"
    "big-parallel"
    "kvm"
    "nixos-test"
    "gccarch-x86_64"
    "gccarch-x86_64-v3"
    "gccarch-x86_64-v4"
    "gccarch-znver2"
  ]
  # https://github.com/NixOS/nixpkgs/blob/6607cf789e541e7873d40d3a8f7815ea92204f32/nixos/modules/config/nix.nix#L54-L59
  ++ map
    (x: "gccarch-${x}")
    ((lib.systems.architectures.inferiors.${arch} or [ ]) ++ [ arch ]);

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
