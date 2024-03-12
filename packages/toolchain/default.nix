{ pkgs, lib, ... }:

lib.makeScope pkgs.newScope (self: with self; {
  riscv-gnu = callPackage ./riscv-gnu.nix { };
  riscv-xuantie = callPackage ./riscv-xuantie.nix { };
})
