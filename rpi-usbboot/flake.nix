{
  description = "temporary usbboot";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        usbboot = pkgs.stdenv.mkDerivation {
          pname = "usbboot";
          version = "unstable";

          src = pkgs.fetchFromGitHub {
            owner = "raspberrypi";
            repo = "usbboot";
            rev = "101f2d00d959855ca9acdfa9a6ee427f35d1700c";
            hash = "sha256-ceU+MjUel2vC8ddOXYYg2hmeSq0nmag3b/w+zxsqlKo=";
            fetchSubmodules = true;
          };

          nativeBuildInputs = with pkgs; [ pkg-config gnumake ];
          buildInputs = with pkgs; [ libusb1 ];

          buildPhase = "make INSTALL_PREFIX=$out";

          installPhase = ''
            mkdir -p $out/bin
            mkdir -p $out/share
            make install INSTALL_PREFIX=$out
          '';
        };

      in {
        apps.default = {
          type = "app";
          program = "${usbboot}/bin/rpiboot";
        };
        devShells.default = pkgs.mkShell {
          inputsFrom = [ usbboot ];
          packages = [ pkgs.git ];
        };
      });
}
