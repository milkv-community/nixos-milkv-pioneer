{ pkgs, lib, recurseIntoAttrs, ... }:

lib.makeScope pkgs.newScope (self: {
  bsp = recurseIntoAttrs (self.callPackage ./bsp { });
})
