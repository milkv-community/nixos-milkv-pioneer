{ pkgs, ... }:

derivation {
  name = "milkv-pioneer-bsp-zsbl";
  builder = "${pkgs.coreutils}/bin/true";
  system = builtins.currentSystem;
}
