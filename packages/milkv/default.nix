{ pkgs, lib, recurseIntoAttrs }:

# derivation {
#   name = "empty";
#   builder = "${pkgs.coreutils}/bin/true";
#   system = builtins.currentSystem;
# }

lib.makeScope pkgs.newScope (self: with self; {
  pioneer = recurseIntoAttrs (pkgs.callPackage ./pioneer { });
})
