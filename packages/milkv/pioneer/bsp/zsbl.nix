{ pkgs, ... }:

derivation rec {
  inherit (pkgs) system;
  name = "milkv-pioneer-bsp-zsbl";
  builder = "${pkgs.coreutils}/bin/true";
  passthrough = {
    src = pkgs.fetchFromGitHub {
      owner = "milkv-community";
      repo = "sophgo-zsbl";
      rev = "cc80627";
      hash = "sha256-zOlBM7mwz8FUM/BlzOxJmpI8LI/KcFOGXegvgiilbaM=";
      fetchSubmodules = true;
    };
  };
}
