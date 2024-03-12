{ pkgs, ... }:

derivation {
  name = "milkv-pioneer-bsp-opensbi";
  builder = "${pkgs.coreutils}/bin/true";
  system = builtins.currentSystem;
}
