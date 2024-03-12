{
  description = "A Nix flake for building the Milk-V Pioneer BSP";

  nixConfig = {
    accept-flake-config = true;
    # FIXME:
    extra-access-tokens = [
      "!include /home/silvanshade/.config/nix-access-tokens/github"
    ];
    extra-experimental-features = [
      "nix-command"
      "flakes"
    ];
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    flake-compat = {
      url = "github:inclyc/flake-compat";
      flake = false;
    };
    nixos-hardware = {
      url = "github:nixos/nixos-hardware";
      # inputs.nixpkgs.follows = "nixpkgs"; # NOTE: non-existent
    };
    nixos-riscv = {
      url = "github:NickCao/nixos-riscv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      eachSystem = inputs.nixpkgs.lib.genAttrs (import systems);
      eachSystemPkgs = overrides: f: eachSystem (system:
        let
          pkgs = import inputs.nixpkgs ({ inherit system; } // overrides);
        in
        f pkgs);
      recurseIntoAttrs = attrs: attrs // { recurseForDerivations = true; };
      treefmtEval = eachSystem (system: inputs.treefmt-nix.lib.evalModule inputs.nixpkgs.legacyPackages.${system} ./treefmt.nix);
    in
    rec {
      formatter = eachSystemPkgs { } (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);

      checks = eachSystemPkgs { } (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check inputs.self;
      });

      scopedPackages = eachSystemPkgs { } (pkgs: {
        milkv = recurseIntoAttrs (pkgs.callPackage ./packages/milkv { });
        toolchain = recurseIntoAttrs (pkgs.callPackage ./packages/toolchain { });
      });

      packages = eachSystemPkgs { } (pkgs: {
        milkv-pioneer-bsp-edk2 = scopedPackages.${pkgs.system}.milkv.pioneer.bsp.edk2;
        milkv-pioneer-bsp-linux = scopedPackages.${pkgs.system}.milkv.pioneer.bsp.linux;
        milkv-pioneer-bsp-opensbi = scopedPackages.${pkgs.system}.milkv.pioneer.bsp.opensbi;
        milkv-pioneer-bsp-zsbl = scopedPackages.${pkgs.system}.milkv.pioneer.bsp.zsbl;
        # TODO: move into separate flake
        toolchain-riscv-gnu = scopedPackages.${pkgs.system}.toolchain.riscv-gnu;
        # TODO: move into separate flake
        toolchain-riscv-xuantie = scopedPackages.${pkgs.system}.toolchain.riscv-xuantie;
      });

      devShells = eachSystemPkgs { } (pkgs:
        let
          bsp-src-edk2 = scopedPackages.${pkgs.system}.milkv.pioneer.bsp.edk2.src;
          bsp-src-linux = scopedPackages.${pkgs.system}.milkv.pioneer.bsp.linux.src;
          bsp-src-opensbi = scopedPackages.${pkgs.system}.milkv.pioneer.bsp.opensbi.src;
          bsp-src-zsbl = scopedPackages.${pkgs.system}.milkv.pioneer.bsp.zsbl.src;
          bsp-srcs = [
            bsp-src-edk2
            bsp-src-linux
            bsp-src-opensbi
            bsp-src-zsbl
          ];
          toolchain-riscv-gnu = scopedPackages.${pkgs.system}.toolchain.riscv-gnu.src;
          toolchain-riscv-xuantie = scopedPackages.${pkgs.system}.toolchain.riscv-xuantie.src;
          toolchains = [
            toolchain-riscv-gnu
            toolchain-riscv-xuantie
          ];
        in
        {
          default = pkgs.mkShell {
            BSP_SRC_EDK2 = bsp-src-edk2;
            BSP_SRC_LINUX = bsp-src-linux;
            BSP_SRC_OPENSBI = bsp-src-opensbi;
            BSP_SRC_ZSBL = bsp-src-zsbl;
            TOOLCHAIN_RISCV_GNU = toolchain-riscv-gnu;
            TOOLCHAIN_RISCV_XUANTIE = toolchain-riscv-xuantie;
            buildInputs = bsp-srcs ++ toolchains ++ [
              pkgs.go
            ];
          };
        });
    };
}
