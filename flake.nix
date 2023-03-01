{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { flake-utils, nixpkgs, ... }:
    let
      supportedSystems =
        [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
    in flake-utils.lib.eachSystem supportedSystems (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            permittedInsecurePackages =
              [ "python-2.7.18.6" "qtwebkit-5.212.0-alpha4" ];
          };
        };
        phantomjsDrv = pkgs.libsForQt5.callPackage ./phantomjs { };
      in {
        packages = {
          phantomjs = phantomjsDrv;
          default = phantomjsDrv;
        };
        apps = rec {
          phantomjs = flake-utils.lib.mkApp { drv = phantomjsDrv; };
          default = phantomjs;
        };
      });
}
