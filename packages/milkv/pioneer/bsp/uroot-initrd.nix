{ pkgs, ... }:

# This derivation builds the zsbl artifact from the Sophgo SG2042 bsp.
#
# For reference, see the upstream u-root repositories:
#   https://github.com/sophgo/bootloader-riscv
#   https://github.com/u-root/u-root
#
# For reference, see the `build_rv_zsbl` function in `scripts/envsetup. sh`:
#   https://github.com/sophgo/bootloader-riscv

pkgs.buildGoApplication {
  pname = "milkv-pioneer-bsp-uroot";
  version = "0.0.0";

  # nativeBuildInputs = with pkgs; [
  #   breakpointHook
  # ];

  modules = ./uroot/gomod2nix.toml;

  src = pkgs.fetchFromGitHub {
    owner = "milkv-community";
    repo = "u-root";
    rev = "v0.14.0";
    hash = "sha256-8zA3pHf45MdUcq/MA/mf0KCTxB1viHieU/oigYwIPgo=";
  };

  # NOTE: This is necessary for `GOROOT` to be set in the build environment when `./u-root` is
  # called in the installPhase below. Without it, the call to `./u-root` will fail with an error
  # about an empty `GOROOT`.
  allowGoReference = true;

  doCheck = false;

  buildPhase = ''
    go build
  '';

  installPhase = ''
    mkdir -p $out
    GOOS=linux GOARCH=riscv64 ./u-root -build bb -uinitcmd="boot" -o $out/initrd.img core boot
  '';
}
