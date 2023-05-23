# configure-environment

A Nix-based reproducible configuration.

## Usage

Git and Nix must be available. In a fresh NixOS installation, <kbd>nix-shell</kbd> will do the job:

```bash
nix-shell -p git
```

Assuming both are available, run this command in this directory to update a NixOS installation:

```bash
sudo nixos-rebuild switch --flake .#a-pc
```

Or, to use a standalone home-manager installation:

```bash
home-manager switch --flake .
```

## WSL

Newer versions of WSL support systemd natively, but the NixOS-WSL installer hasn’t yet been updated. A new version can be built using Nix. For example, run `docker run -it --rm -v "$(pwd):/app" nixos/nix` in PowerShell and these commands within the new container:

```bash
echo 'extra-experimental-features = flakes nix-command' >> /etc/nix/nix.conf
nix build github:htngr/NixOS-WSL#nixosConfigurations.mysystem.config.system.build.installer
cp /nix/store/*-tarball/tarball/nixos-wsl-installer.tar.gz . # `result` is only a symlink
```

And import it into WSL:

```powershell
wsl --import NixOS C:\path\to\store\data\in C:\path\to\nixos-wsl-installer.tar.gz --version 2
```
