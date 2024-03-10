{
  description = "A template that shows all standard flake outputs";


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
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
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
    in
    let
      treefmtEval = eachSystem (system: inputs.treefmt-nix.lib.evalModule inputs.nixpkgs.legacyPackages.${system} ./treefmt.nix);
    in
    rec {
      formatter = eachSystemPkgs { } (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);

      checks = eachSystemPkgs { } (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check inputs.self;
      });

      packages = eachSystemPkgs { } (pkgs: {
        sophgo-bootloader-riscv = pkgs.fetchFromGitHub {
          owner = "milkv-community";
          repo = "sophgo-bootloader-riscv";
          rev = "01dc52c";
          hash = "sha256-qho2HKgVXVN+s/QZQ15uPFgCpCwS91P4+T4cPZ/eLDc=";
          fetchSubmodules = true;
        };
        sophgo-edk2 = pkgs.fetchFromGitHub {
          owner = "milkv-community";
          repo = "sophgo-edk2";
          rev = "cc3706b";
          hash = "sha256-2LH41Mpk7E4Wkiel1ZqMwPiq5vcaB97NqzEJNkVe62k=";
          fetchSubmodules = true;
        };
        sophgo-opensbi = pkgs.fetchFromGitHub {
          owner = "milkv-community";
          repo = "sophgo-opensbi";
          rev = "3745939";
          hash = "sha256-UXsAKXO0fBjHkkanZlB0led9CiVeqa01dTM4r7D9dzs=";
          fetchSubmodules = true;
        };
        sophgo-zsbl = pkgs.fetchFromGitHub {
          owner = "milkv-community";
          repo = "sophgo-zsbl";
          rev = "cc80627";
          hash = "sha256-zOlBM7mwz8FUM/BlzOxJmpI8LI/KcFOGXegvgiilbaM=";
          fetchSubmodules = true;
        };
      });

      devShells = eachSystemPkgs { } (pkgs:
        let
          sophgo-bootloader-riscv = packages.${pkgs.system}.sophgo-bootloader-riscv;
          sophgo-edk2 = packages.${pkgs.system}.sophgo-edk2;
          sophgo-opensbi = packages.${pkgs.system}.sophgo-opensbi;
          sophgo-zsbl = packages.${pkgs.system}.sophgo-zsbl;
        in
        {
          default = pkgs.mkShell {
            REPO_SOPHGO_BOOTLOADER_RISCV = sophgo-bootloader-riscv;
            REPO_SOPHGO_EDK2 = sophgo-edk2;
            REPO_SOPHGO_OPENSBI = sophgo-opensbi;
            REPO_SOPHGO_ZSBL = sophgo-zsbl;
            buildInputs = [
              sophgo-bootloader-riscv
              sophgo-edk2
              sophgo-opensbi
              sophgo-zsbl
              pkgs.go
            ];
          };
        });
    };
}
