{ pkgs, ... }:

derivation {
  inherit (pkgs) system;
  name = "toolchain-riscv-xuantie";
  builder = "${pkgs.coreutils}/bin/true";
}
