{
  description = "A Nix flake for building the Milk-V Pioneer BSP";

  inputs = {
    # nixos-hardware = {
    #   url = "github:nixos/nixos-hardware";
    #   # inputs.nixpkgs.follows = "nixpkgs"; # NOTE: non-existent
    # };
    # nixos-riscv = {
    #   url = "github:NickCao/nixos-riscv";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ systems, ... }:
    let
      eachSystem = inputs.nixpkgs.lib.genAttrs (import systems ++ [ "riscv64-linux" ]);
      eachSystemPkgs = overrides: f: eachSystem (system:
        let
          pkgs = import inputs.nixpkgs ({ inherit system; } // overrides);
        in
        f pkgs);
      recurseIntoAttrs = attrs: attrs // { recurseForDerivations = true; };
      treefmtEval = eachSystem (system: inputs.treefmt-nix.lib.evalModule inputs.nixpkgs.legacyPackages.${system} ./treefmt.nix);
    in
    rec {
      flake = eachSystemPkgs { } (pkgs: {
        ccache = rec {
          extraConfig = ''
            export CCACHE_MAXSIZE=20G
            export CCACHE_COMPILERCHECK=content
            export CCACHE_NOHASHDIR=1
            export CCACHE_SLOPPINESS=include_file_ctime,include_file_mtime,locale,modules,pch_defines,random_seed,system_headers,time_macros
            export CCACHE_DIR="/var/cache/ccache"
            export CCACHE_UMASK=007
            if [ ! -d "$CCACHE_DIR" ]; then
              echo "====="
              echo "Directory '$CCACHE_DIR' does not exist"
              echo "Please create it with:"
              echo "  sudo mkdir -m0770 '$CCACHE_DIR'"
              echo "  sudo chown root:nixbld '$CCACHE_DIR'"
              echo "====="
              exit 1
            fi
            if [ ! -w "$CCACHE_DIR" ]; then
              echo "====="
              echo "Directory '$CCACHE_DIR' is not accessible for user $(whoami)"
              echo "Please verify its access permissions"
              echo "====="
              exit 1
            fi
          '';
          stdenv = pkgs.ccacheStdenv.override {
            inherit extraConfig;
          };
          stdenv-riscv64 = pkgs.pkgsCross.riscv64.ccacheStdenv.override {
            inherit extraConfig;
          };
          stdenv-riscv64-embedded = pkgs.pkgsCross.riscv64-embedded.ccacheStdenv.override {
            inherit extraConfig;
          };
        };
      });

      formatter = eachSystemPkgs { } (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);

      checks = eachSystemPkgs { } (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check inputs.self;
      });

      scopedPackages = eachSystemPkgs { } (pkgs:
        let systemFlake = flake.${pkgs.system}; in
        {
          milkv = recurseIntoAttrs (pkgs.callPackage ./packages/milkv { flake = systemFlake; });
          toolchain = recurseIntoAttrs (pkgs.callPackage ./packages/toolchain { flake = systemFlake; });
        });

      packages = eachSystemPkgs { } (pkgs: {
        milkv-pioneer-bsp-edk2 = scopedPackages.${pkgs.system}.milkv.pioneer.bsp.edk2;
        milkv-pioneer-bsp-linux = scopedPackages.${pkgs.system}.milkv.pioneer.bsp.linux;
        milkv-pioneer-bsp-opensbi = scopedPackages.${pkgs.system}.milkv.pioneer.bsp.opensbi;
        milkv-pioneer-bsp-uroot = scopedPackages.${pkgs.system}.milkv.pioneer.bsp.uroot;
        milkv-pioneer-bsp-zsbl = scopedPackages.${pkgs.system}.milkv.pioneer.bsp.zsbl;
      });

      devShells = eachSystemPkgs { } (pkgs:
        let
          bsp-edk2 = packages.${pkgs.system}.milkv-pioneer-bsp-edk2;
          bsp-linux = packages.${pkgs.system}.milkv-pioneer-bsp-linux;
          bsp-opensbi = packages.${pkgs.system}.milkv-pioneer-bsp-opensbi;
          bsp-uroot = packages.${pkgs.system}.milkv-pioneer-bsp-uroot;
          bsp-zsbl = packages.${pkgs.system}.milkv-pioneer-bsp-zsbl;
        in
        {
          default = pkgs.pkgsCross.riscv64.mkShell {
            BSP_EDK2 = bsp-edk2;
            BSP_LINUX = bsp-linux;
            BSP_OPENSBI = bsp-opensbi;
            BSP_UROOT = bsp-uroot;
            BSP_ZSBL = bsp-zsbl;
            nativeBuildInputs = [
              flake.${pkgs.system}.ccache.stdenv
              flake.${pkgs.system}.ccache.stdenv-riscv64
              flake.${pkgs.system}.ccache.stdenv-riscv64-embedded
            ]
            ++ bsp-edk2.nativeBuildInputs
            ++ bsp-linux.nativeBuildInputs
            ++ bsp-opensbi.nativeBuildInputs
            ++ bsp-uroot.nativeBuildInputs
            ++ bsp-zsbl.nativeBuildInputs;
          };
        });
    };
}
