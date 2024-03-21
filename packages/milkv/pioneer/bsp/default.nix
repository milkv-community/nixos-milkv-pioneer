{ flake, pkgs, lib, ... }:

lib.makeScope pkgs.newScope (bsp: {
  bootloader = bsp.callPackage ./bootloader.nix { inherit bsp flake; };
  edk2 = bsp.callPackage ./edk2.nix { inherit bsp flake; };
  linux = bsp.callPackage ./linux.nix { inherit bsp flake; };
  opensbi = bsp.callPackage ./opensbi.nix { inherit bsp flake; };
  uroot-initrd = bsp.callPackage ./uroot-initrd.nix { inherit bsp flake; };
  zsbl = bsp.callPackage ./zsbl.nix { inherit bsp flake; };
})
