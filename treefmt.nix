{
  projectRootFile = "flake.nix";
  programs.deadnix.enable = true;
  programs.formatjson5.enable = true;
  programs.jsonfmt.enable = true;
  programs.mdformat.enable = true;
  # programs.mdsh.enable = true;
  # programs.mixformat.enable = true;
  # programs.muon.enable = true;
  # programs.mypy.enable = true;
  # programs.nickel.enable = true;
  # programs.nixfmt.enable = true;
  # programs.nixfmt-rfc-style.enable = true;
  programs.nixpkgs-fmt.enable = true;
  # programs.ocamlformat.enable = true;
  # programs.ormolu.enable = true;
  # programs.php-cs-fixer.enable = true;
  # programs.prettier.enable = true;
  # programs.protolint.enable = true;
  # programs.purs-tidy.enable = true;
  # programs.ruff.enable = true;
  # programs.rufo.enable = true;
  # programs.rustfmt.enable = true;
  # programs.scalafmt.enable = true;
  programs.shellcheck.enable = true;
  programs.shfmt.enable = true;
  programs.statix.enable = true;
  # programs.stylish-haskell.enable = true;
  programs.stylua.enable = true;
  # programs.swift-format.enable = true;
  programs.taplo.enable = true;
  # programs.templ.enable = true;
  # programs.terraform.enable = true;
  # programs.typstfmt.enable = true;
  programs.yamlfmt.enable = true;
  # programs.zig.enable = true;
  # programs.zprint.enable = true;
  settings.formatter.taplo = {
    excludes = [
      "**/gomod2nix.toml"
    ];
  };
}
