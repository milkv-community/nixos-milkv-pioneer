{ pkgs, ... }:

let
  src = pkgs.fetchFromGitHub {
    owner = "milkv-community";
    repo = "sophgo-edk2";
    rev = "cc3706b";
    hash = "sha256-2LH41Mpk7E4Wkiel1ZqMwPiq5vcaB97NqzEJNkVe62k=";
    fetchSubmodules = true;
  };
in
pkgs.stdenv.mkDerivation rec {
  inherit (pkgs) system;
  name = "milkv-pioneer-bsp-edk2";
  builder = "${pkgs.coreutils}/bin/true";
  passthru = {
    src = "${src}";
  };
}
