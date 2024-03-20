{ flake, pkgs, lib, recurseIntoAttrs, ... }:

lib.makeScope pkgs.newScope (self: {
  pioneer = recurseIntoAttrs (self.callPackage ./pioneer { inherit flake; });
})
