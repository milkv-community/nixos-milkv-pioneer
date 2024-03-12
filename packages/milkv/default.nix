{ pkgs, lib, recurseIntoAttrs, ... }:

lib.makeScope pkgs.newScope (self: with self; {
  pioneer = recurseIntoAttrs (pkgs.callPackage ./pioneer { });
})
