{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
  };

  outputs = { self, nixpkgs }:
    let
      systems = nixpkgs.legacyPackages;
      combine = fn: with builtins;
        let
          parts = mapAttrs (s: _: fn (nixpkgs.legacyPackages.${s})) systems;
          keys = foldl' (a: b: a // b) {} (attrValues parts);
        in
          mapAttrs (k: _: mapAttrs (s: _: parts.${s}.${k} or {}) systems) keys;
    in
      combine (pkgs: rec {
        packages = rec {
          nix-doc-munge = pkgs.callPackage ./default.nix {};
          report-failures = pkgs.writeShellApplication {
            name = "nix-doc-munge-report-failures";
            text = builtins.readFile ./report-failures.bash;
          };
          default = nix-doc-munge;
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [ packages.default ];
          packages = with pkgs; [ rustfmt rust-analyzer clippy ];
        };
      }) // {
        nixosModule = import ./module.nix { inherit self; };
      };
}
