{
  description = "Your new nix config";

  inputs = {
    systems.url = "github:nix-systems/x86_64-linux";

    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-wsl.url = "github:htngr/NixOS-WSL/main";
    # hardware.url = "github:nixos/nixos-hardware";

    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "systems";

    rust-overlay.url = "github:oxalica/rust-overlay";

    # Shameless plug: looking for a way to nixify your themes and make
    # everything match nicely? Try nix-colors!
    # nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs =
    { self, nixpkgs, home-manager, rust-overlay, flake-utils, ... }@inputs:
    let
      inherit (self) outputs;
      # See list at <https://github.com/NixOS/nixpkgs/blob/master/lib/systems/architectures.nix>.
      platform = { arch, ... }: {
        nixpkgs.hostPlatform = {
          arch = arch;
          tune = arch;

          system = "x86_64-linux";
        };
      };
      mkNixos = arch: modules:
        nixpkgs.lib.nixosSystem {
          inherit modules;
          specialArgs = { inherit inputs outputs arch; };
        };
      mkHome = modules: pkgs:
        home-manager.lib.homeManagerConfiguration {
          inherit modules pkgs;
          extraSpecialArgs = { inherit inputs outputs; };
        };
    in
    rec {
      packages = flake-utils.lib.eachDefaultSystem (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./pkgs { inherit pkgs; });
      # Devshell for bootstrapping
      # Acessible through 'nix develop' or 'nix-shell' (legacy)
      devShells = flake-utils.lib.eachDefaultSystem (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./shell.nix { inherit pkgs; });

      overlays = import ./overlays { inherit inputs; };
      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;

      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#your-hostname'
      nixosConfigurations = { A-PC = mkNixos "znver3" [ platform ./hosts/a-pc ]; };

      # Standalone home-manager configuration entrypoint
      # Available through 'home-manager --flake .#your-username@your-hostname'
      homeConfigurations =
        let
          pkgs = import nixpkgs {
            system = "x86_64-linux";
          };
        in
        {
          "a@A-PC" = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = { inherit inputs outputs packages; };
            modules = [
              ./home-manager/a
              (import ./home-manager/a/rclone.nix { inherit pkgs; })
            ];
          };

          "a@a-lap" = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = { inherit inputs outputs packages; };
            modules = [
              ./home-manager/a
              (import ./home-manager/a/rclone.nix { inherit pkgs; })
            ];
          };
        };
    };
}
