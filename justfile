set shell := ["nu", "-c"]

[linux]
[working-directory: "nix"]
build-builder debug="":
  nix build ".#docker.builder"{{ if debug == "1" { " --show-trace -L" } else { "" } }}; \
    cp -f result/tarball/*.tar.xz kehkashan-builder.tar.xz; \
    rm -rf result
