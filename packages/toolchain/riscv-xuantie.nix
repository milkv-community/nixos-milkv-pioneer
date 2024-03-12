{ fetchzip, pkgs, ... }:

let
  src = fetchzip {
    url = "https://occ-oss-prod.oss-cn-hangzhou.aliyuncs.com/resource//1705395627867/Xuantie-900-gcc-linux-5.10.4-glibc-x86_64-V2.8.1-20240115.tar.gz";
    hash = "sha256-Pr9Kl25e/10V5qQ7Fi8Nsxpv+LyskNSjl+mZT4eQpLQ=";
  };
in
pkgs.stdenv.mkDerivation {
  inherit (pkgs) system;
  name = "toolchain-riscv-xuantie";
  builder = "${pkgs.coreutils}/bin/true";
  passthru = {
    src = "${src}";
  };
}
