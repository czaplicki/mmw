{
  description = "MMW - Multi-Monitor Wallpapers";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs }:
  let
    systems = [ "x86_64-linux" "aarch64-linux" ];
  in {
    packages = nixpkgs.lib.genAttrs systems (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        mmw = pkgs.stdenvNoCC.mkDerivation {
          pname = "mmw";
          version = "0.3.0";

          src = ./.;

          buildInputs = [ pkgs.scdoc ];

          installPhase = ''
            mkdir -p $out/bin $out/share/man/man1

            install -m755 mmw.nu $out/bin/mmw
            scdoc < mmw.1.scd > $out/share/man/man1/mmw.1
          '';

          propagatedBuildInputs = with pkgs; [
            nushell
            imagemagick
            wlr-randr
          ];
        };
        default = self.packages.${system}.mmw;
      }
    );

    devShells = nixpkgs.lib.genAttrs systems (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            scdoc
            nushell
            imagemagick
            wlr-randr
          ];
        };
      }
    );


  };
}