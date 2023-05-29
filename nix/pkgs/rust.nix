{ pkgs }:
let
  platform = pkgs.makeRustPlatform {
    rustc = pkgs.rust-bin.nightly.latest.minimal;
    cargo = pkgs.rust-bin.nightly.latest.minimal;
  };
in {
  trippy = platform.buildRustPackage rec {
    pname = "trippy";
    version = "623ff2c";

    src = pkgs.fetchFromGitHub {
      owner = "fujiapple852";
      repo = pname;
      rev = version;
      hash = "sha256-QZndvHKiATV+sa58tgkUTGsr9XAEMI/36dxqIG1CYds=";
    };

    cargoHash = "sha256-6TSMCxxQ1MZ1O6y9ZsdigVgLu9IWpyoEcPZd4AaH6bI=";

    # Taken from tools.networking.trippy, which I can’t seem to install.
    meta = with pkgs.lib; {
      description = "A network diagnostic tool";
      homepage = "https://trippy.cli.rs";
      changelog =
        "https://github.com/fujiapple852/trippy/blob/${src.rev}/CHANGELOG.md";
      license = licenses.asl20;
      maintainers = with maintainers; [ figsoda ];
      mainProgram = "trip";
    };
  };
}
