{ pkgs, lib, ... }:

lib.makeScope pkgs.newScope (self: {
  edk2 = self.callPackage ./edk2.nix { };
  linux = self.callPackage ./linux.nix { };
  opensbi = self.callPackage ./opensbi.nix { };
  zsbl = self.callPackage ./zsbl.nix { };
})
