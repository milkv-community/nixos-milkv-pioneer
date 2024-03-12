{ pkgs, lib, ... }:

lib.makeScope pkgs.newScope (self: with self; {
  edk2 = callPackage ./edk2.nix { };
  linux = callPackage ./linux.nix { };
  opensbi = callPackage ./opensbi.nix { };
  zsbl = callPackage ./zsbl.nix { };
})
