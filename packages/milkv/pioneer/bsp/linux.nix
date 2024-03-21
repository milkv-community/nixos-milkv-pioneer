{ flake, pkgs, ... }:
{ }

# # let
# #   src = pkgs.fetchFromGitHub {
# #     owner = "milkv-community";
# #     repo = "linux";
# #     rev = "dfe9dcc";
# #     hash = "sha256-zCrQwjFn09gyal511xLCxVP2+Uvlp1gsVta42PL8+zQ=";
# #     fetchSubmodules = true;
# #   };
# # in
# # pkgs.stdenv.mkDerivation {
# #   inherit (pkgs) system;
# #   name = "milkv-pioneer-bsp-linux";
# #   builder = "${pkgs.coreutils}/bin/true";
# #   passthru = {
# #     src = "${src}";
# #   };
# # }

# pkgs.stdenv.mkDerivation {
#   pname = "";
#   version = "";
# }
