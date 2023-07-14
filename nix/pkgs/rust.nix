{ pkgs }:
let
  platform = pkgs.makeRustPlatform {
    rustc = pkgs.rust-bin.nightly.latest.minimal;
    cargo = pkgs.rust-bin.nightly.latest.minimal;
  };
in
{
}
