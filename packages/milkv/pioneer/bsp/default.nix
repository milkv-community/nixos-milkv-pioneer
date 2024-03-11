{ pkgs, lib }:

lib.makeScope pkgs.newScope (self: with self; {
  # edk2 = callPackage ./edk2 { };
  # opensbi = callPackage ./opensbi { };
  # zsbl = callPackage ./zsbl { };
})
