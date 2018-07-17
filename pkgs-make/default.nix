let

    default =
        {
            # git describe: 18.03-beta-12822-g5ac6ab091a4
            rev = "14a9ca27e69e33ac8ffb708de08883f8079f954a";
            sha256 = "1grsq8mcpl88v6kz8dp0vsybr0wzfg4pvhamj42dpd3vgr93l2ib";

            nixpkgsArgs.config = {
                allowUnfree = true;
                cudaSupport = true;
            };

            bootPkgs = import <nixpkgs> {};
            overlay = import base/overrides;
            srcFilter = p: t: true;
            haskellArgs = {};
            pythonArgs = {};
        };

in

{ rev ? default.rev
, sha256 ? default.sha256
, bootPkgs ? default.bootPkgs
, nixpkgsArgs ? default.nixpkgsArgs
, srcFilter ? default.srcFilter
, nixpkgsOverlay ? default.overlay
, haskellArgs ? default.haskellArgs
, pythonArgs ? default.pythonArgs
}:

generator:

let

    nixpkgsPath =
        bootPkgs.fetchFromGitHub {
            owner = "NixOS";
            repo = "nixpkgs";
            inherit rev sha256;
        };

    origNixpkgs = import nixpkgsPath { config = {}; };

    morePkgs = self: super:
        let
            commonArgs = { nixpkgs = self; inherit pkgs; };
            hs = import ./haskell (commonArgs // haskellArgs);
            py = import ./python (commonArgs // pythonArgs);
            lib = import ./lib self;
            tools = import ./tools.nix self.callPackage;
            cleanSource = src:
                lib.nix.sources.cleanSourceWith {
                    filter = srcFilter;
                    src = lib.nix.sources.cleanSource src;
                };
            callPackage = p:
                let pkg = self.callPackage (import p) {};
                in
                    if pkg ? overrideAttrs
                    then
                        pkg.overrideAttrs (attrs:
                            if attrs ? src
                            then { src = cleanSource attrs.src; }
                            else {})
                    else pkg;
        in
            {
                haskellPackages = hs.haskellPackages;
                pythonPackages = py.pythonPackages;
                pkgsMake = {
                    inherit lib;
                    call = {
                        package = callPackage;
                        haskell = {
                            lib = hs.callHaskellLib;
                            app = hs.callHaskellApp;
                        };
                        python = py.callPython;
                    };
                    env = { haskell = hs.env; python = py.env; };
                };
            } // tools // pkgs;

    overlays = [ nixpkgsOverlay morePkgs ];

    nixpkgs = import origNixpkgs.path (nixpkgsArgs // { inherit overlays; });

    args = {
        lib = nixpkgs.pkgsMake.lib;
        call = nixpkgs.pkgsMake.call;
    };

    pkgs = generator args;

in

pkgs // { inherit nixpkgs; env = nixpkgs.pkgsMake.env; }
