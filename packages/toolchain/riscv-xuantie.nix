{ pkgs, ... }:

derivation {
  name = "toolchain-riscv-xuantie";
  builder = "${pkgs.coreutils}/bin/true";
  system = builtins.currentSystem;
}
