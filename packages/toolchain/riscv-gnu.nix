{ pkgs, ... }:

derivation {
  name = "toolchain-riscv-edk2";
  builder = "${pkgs.coreutils}/bin/true";
  system = builtins.currentSystem;
}
