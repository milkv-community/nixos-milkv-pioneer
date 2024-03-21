{ flake, pkgs, lib, recurseIntoAttrs, ... }:

lib.makeScope pkgs.newScope (pioneer: {
  bsp = recurseIntoAttrs (pioneer.callPackage ./bsp { inherit flake; });
})
