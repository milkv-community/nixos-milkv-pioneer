{ pkgs, ... }:

derivation {
  name = "milkv-pioneer-bsp-edk2";
  builder = "${pkgs.coreutils}/bin/true";
  system = builtins.currentSystem;
}
