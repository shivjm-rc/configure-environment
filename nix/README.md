# configure-environment

A Nix-based reproducible configuration. Mostly a bad adaptation of [Misterio77’s starter configs](https://github.com/Misterio77/nix-starter-configs/tree/main) and [~misterio/nix-config](https://git.sr.ht/~misterio/nix-config).

## Usage

Git and Nix must be available. If Nix is installed, <kbd>nix-shell</kbd> can provide Git:

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
