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

  # NOTE: This is necessary for `GOROOT` to be set in the build environment when `./u-root` is
  # called in the installPhase below. Without it, the call to `./u-root` will fail with an error
  # about an empty `GOROOT`.
  allowGoReference = true;

  # NOTE: Several of the tests will fail without rewriting paths. Some others fail due to permission
  # issues in the sandbox. Overall it doesn't seem worth fixing these in `preBuild` and enabling
  # checks, especially since we don't use or even build most of the commands.
  doCheck = false;

  modules = ./gomod2nix.toml;

  # nativeBuildInputs = with pkgs; [
  #   breakpointHook
  # ];

  src = pkgs.fetchFromGitHub {
    owner = "milkv-community";
    repo = "u-root";
    rev = "v0.14.0";
    hash = "sha256-8zA3pHf45MdUcq/MA/mf0KCTxB1viHieU/oigYwIPgo=";
  };

  buildPhase = ''
    runHook preBuild

    go build
    GOOS=linux GOARCH=riscv64 ./u-root -build bb -uinitcmd="boot" -o initrd.img core boot

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp initrd.img $out/initrd.img

    runHook postInstall
  '';
}
