{ flake, pkgs, ... }:

# This derivation builds the zsbl artifact from the Sophgo SG2042 bsp.
#
# For reference, see the upstream u-root repositories:
#   https://github.com/sophgo/bootloader-riscv
#   https://github.com/u-root/u-root
#
# For reference, see the `build_rv_zsbl` function in `scripts/envsetup. sh`:
#   https://github.com/sophgo/bootloader-riscv

flake.ccache.stdenv.mkDerivation rec {
  pname = "milkv-pioneer-bsp-uroot";
  version = "0.0.0";

  nativeBuildInputs = with pkgs; [
    # breakpointHook
    go
  ];

  src = pkgs.fetchFromGitHub {
    owner = "milkv-community";
    repo = "u-root";
    rev = "v0.14.0";
    hash = "";
  };

  phases = [ ];
}
