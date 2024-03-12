{ fetchzip, pkgs, ... }:

let
  src = fetchzip {
    url = "https://github.com/riscv-collab/riscv-gnu-toolchain/releases/download/2024.03.01/riscv64-glibc-ubuntu-22.04-gcc-nightly-2024.03.01-nightly.tar.gz";
    hash = "sha256-XbiRy6gzSa6evbXIHPdXIfwFeAonq/9VLp65oEhYy6U=";
  };
in
pkgs.stdenv.mkDerivation {
  inherit (pkgs) system;
  name = "toolchain-riscv-gnu";
  builder = "${pkgs.coreutils}/bin/true";
  passthru = {
    src = "${src}";
  };
}
