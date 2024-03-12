{ pkgs, ... }:

let
  src = pkgs.fetchFromGitHub {
    owner = "milkv-community";
    repo = "sophgo-opensbi";
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
