{ flake, pkgs, lib, ... }:

lib.makeScope pkgs.newScope (self: {
  edk2 = self.callPackage ./edk2.nix { inherit flake; };
  linux = self.callPackage ./linux.nix { inherit flake; };
  opensbi = self.callPackage ./opensbi.nix { inherit flake; };
  zsbl = self.callPackage ./zsbl.nix { inherit flake; };
})
