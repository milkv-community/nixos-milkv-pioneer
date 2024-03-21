{ flake, pkgs, lib, recurseIntoAttrs, ... }:

lib.makeScope pkgs.newScope (milkv: {
  pioneer = recurseIntoAttrs (milkv.callPackage ./pioneer { inherit flake; });
})
