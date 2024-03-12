{ pkgs, ... }:

derivation {
  inherit (pkgs) system;
  name = "toolchain-riscv-edk2";
  builder = "${pkgs.coreutils}/bin/true";
}
