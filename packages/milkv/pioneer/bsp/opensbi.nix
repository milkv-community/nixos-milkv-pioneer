{ pkgs, ... }:

# This derivation builds the opensbi artifact from the Sophgo SG2042 bsp.
#
# For reference, see the upstream opensbi repositories:
#   https://github.com/sophgo/opensbi
#   https://github.com/riscv-software-src/opensbi
#
# For reference, see the `build_rv_sbi` function in `scripts/envsetup.sh`:
#   https://github.com/sophgo/bootloader-riscv

let
  src = pkgs.fetchFromGitHub {
    owner = "milkv-community";
    repo = "opensbi";
    rev = "3745939";
    hash = "sha256-UXsAKXO0fBjHkkanZlB0led9CiVeqa01dTM4r7D9dzs=";
    fetchSubmodules = true;
  };
in
pkgs.stdenv.mkDerivation {
  inherit (pkgs) system;
  name = "milkv-pioneer-bsp-opensbi";
  builder = "${pkgs.coreutils}/bin/true";
  passthru = {
    src = "${src}";
  };
}
