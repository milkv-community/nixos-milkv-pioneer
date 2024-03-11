{ pkgs, lib }:

derivation {
  name = "pioneer";
  builder = "${pkgs.coreutils}/bin/true";
  system = builtins.currentSystem;
}

# lib.makeScope pkgs.newScope (self: with self; {
#   # bsp = callPackage ./bsp { };
# })
