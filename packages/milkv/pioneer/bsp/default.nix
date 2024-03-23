{ flake, pkgs, lib, ... }:

lib.makeScope pkgs.newScope (bsp: {
  bootloader-raw-image = bsp.callPackage ./bootloader/raw-image.nix { inherit bsp flake; };
  bootloader-spi-flash = bsp.callPackage ./bootloader/spi-flash.nix { inherit bsp flake; };
  edk2 = bsp.callPackage ./edk2 { inherit bsp flake; };
  linux = bsp.callPackage ./linux { inherit bsp flake; };
  opensbi = bsp.callPackage ./opensbi { inherit bsp flake; };
  uroot-initrd = bsp.callPackage ./uroot/initrd.nix { inherit bsp flake; };
  zsbl = bsp.callPackage ./zsbl { inherit bsp flake; };
})
