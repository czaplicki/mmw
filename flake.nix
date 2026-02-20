{
  description = "MMW - Multi-Monitor Wallpapers";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nu-lint.url = "git+https://codeberg.org/wvhulle/nu-lint";
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];

      perSystem = { config, self', inputs', pkgs, system, ... }: {
      
        packages.mmw = pkgs.stdenvNoCC.mkDerivation {
          pname = "mmw";
          version = "0.3.0";
          src = ./.;

          nativeBuildInputs = [ pkgs.scdoc ];

          installPhase = ''
            mkdir -p $out/bin $out/share/man/man1
            install -m755 mmw.nu $out/bin/mmw
            scdoc < mmw.1.scd > $out/share/man/man1/mmw.1
          '';

          propagatedBuildInputs = with pkgs; [
            nushell
            imagemagick
            wlr-randr
            xrandr
          ];

          meta = {
            description = "Multi-Monitor Wallpapers script";
            mainProgram = "mmw";
            platforms = [ system ];
          };
        };

        packages.default = self'.packages.mmw;

        apps.default = {
          type = "app";
          program = pkgs.lib.getExe self'.packages.mmw;
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            scdoc
            nushell
            inputs'.nu-lint.packages.default
            imagemagick
            wlr-randr
            xrandr
          ];
        };
      };
    };
}
