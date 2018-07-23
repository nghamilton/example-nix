# Main build file for managing all modules

let

    # Version of Nixpkgs to lock down to for our build
    #
    pkgsMakeArgs = {
        # git describe: 16.09-beta-11812-gfa03b8279f
        rev = "fa03b8279fa9b544c29c97eaa5263163b6716046";
        sha256 = "1n8mwwg14xhm4arxafzfmf0wbr8smkgdvaagirxpni77jci81ar3";
    };

    # Library for making our packages (local copy)
    #
    pkgsMake =
        let
	    nixpkgs = import <nixpkgs> {};
	    pinnedVersion = nixpkgs.lib.importJSON ./pkgs-make-version.json;

            pkgs-make-path =
                nixpkgs.fetchFromGitHub {
                    owner = "nghamilton";
                    repo = "pkgs-make";
	            inherit (pinnedVersion) rev sha256; 
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
