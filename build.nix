# Main build file for managing all modules

let

    # Version of Nixpkgs to lock down to for our build
    #
    nixpkgs = import <nixpkgs> {};
    nixVersion = nixpkgs.lib.importJSON ./nixpkgs-version.json;
    pkgsMakeArgs = {
        inherit (nixVersion) rev sha256;
      };

    # Library for making our packages
    #
    pkgsMake =
        let
            pkgsMakeVersion = nixpkgs.lib.importJSON ./pkgs-make-version.json;
            pkgs-make-path =
                nixpkgs.fetchFromGitHub {
                    owner = "nghamilton";
                    repo = "pkgs-make";
                    inherit (pkgsMakeVersion) rev sha256;
                };
        in
        import (pkgs-make-path);

in

pkgsMake pkgsMakeArgs ({ call, lib }:
    let
        modifiedHaskellCall = f:
            lib.nix.composed [
                lib.haskell.enableLibraryProfiling
                lib.haskell.doHaddock
                f
            ];
        haskellLib = modifiedHaskellCall call.haskell.lib;
        haskellApp = modifiedHaskellCall call.haskell.app;
    in
    rec {

        example-assets = call.package modules/example-assets;
        example-lib = haskellLib modules/example-lib;
        example-app-static = haskellApp modules/example-app;
        example-app-dynamic =
            lib.haskell.enableSharedExecutables example-app-static;
        example-app-compact = call.package modules/example-app-compact;
        example-tarball = lib.nix.tarball example-app-compact;
    })
