{ pkgs, lib, recurseIntoAttrs, ... }:

lib.makeScope pkgs.newScope (self: with self; {
  bsp = recurseIntoAttrs (pkgs.callPackage ./bsp { });
})
