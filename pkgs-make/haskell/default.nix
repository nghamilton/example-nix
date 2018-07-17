let

    defaults = nixpkgs:
        {
            ghcVersion = "ghc822";
            overrides = import ./overrides;
            extraOverrides = pkgs: self: super: {};
            srcFilter = p: t: baseNameOf p != ".stack-work";
            envMoreTools = nixpkgs:
                [
                    (nixpkgs.callPackage (import tools/nix-tags-haskell) {})
                    (nixpkgs.callPackage (import tools/cabal-new-watch) {})
                    nixpkgs.haskellPackages.cabal2nix
                    nixpkgs.haskellPackages.c2hs
                    nixpkgs.haskellPackages.cabal-install
                    nixpkgs.haskellPackages.ghcid
                ];
        };

in

{ nixpkgs
, pkgs
, ghcVersion ? (defaults nixpkgs).ghcVersion
, overrides ? (defaults nixpkgs).overrides
, extraOverrides ? (defaults nixpkgs).extraOverrides
, srcFilter ? (defaults nixpkgs).srcFilter
, envMoreTools ? (defaults nixpkgs).envMoreTools nixpkgs
}:

let

    lib = import ../lib nixpkgs;

    rawHsPkgs = builtins.getAttr ghcVersion nixpkgs.haskell.packages;

    finalOverrides =
        self: super:
            overrides nixpkgs self super // extraOverrides nixpkgs self super;

    haskellPackages =
        rawHsPkgs.override {
            overrides = self: super:
                (finalOverrides self super) // pkgs;
        };

    callHaskell = p:
        if builtins.pathExists (builtins.toPath (p + "/default.nix"))
        then p
        else
            let
                parent = dirOf p;
                base = baseNameOf p;
                type = (builtins.readDir parent).${base} or null;
                isDir = type == "directory";
                name = lib.nix.composed [
                    (lib.nix.removeSuffix ".cabal")
                    (lib.nix.findFirst
                        (lib.nix.hasSuffix ".cabal")
                        ("unknown"))
                    builtins.attrNames
                    builtins.readDir
                ] (if isDir then p else parent);
            in
            haskellPackages.callCabal2nix name p {};

    tagLocalPackages = p:
        lib.haskell.overrideCabal p (old: {
            passthru = old.passthru or {} // {
                _isLocalHaskellPackage =
                    lib.nix.sources.sourceLocal old.src;
            };
        });

    callHaskellLib = p:
        lib.nix.composed
            [ lib.haskell.dontHaddock
                (lib.haskell.cleanSource srcFilter)
                (lib.haskell.cleanSource lib.nix.sources.cleanSourceFilter)
                tagLocalPackages ]
            (callHaskell p);

    callHaskellApp = p: lib.haskell.justStaticExecutables (callHaskellLib p);

    envPkgs =
        builtins.filter
            (e: e._isLocalHaskellPackage or false)
            (builtins.attrValues pkgs);

    env =
        (haskellPackages.shellFor {
            packages = p: envPkgs;
        }).overrideAttrs (old1: {
            nativeBuildInputs = old1.nativeBuildInputs ++ envMoreTools;
            passthru.withEnvTools = f: env.overrideAttrs (old2: {
                nativeBuildInputs =
                    old2.nativeBuildInputs ++ f nixpkgs;
            });
        });

in

{
    inherit
        callHaskellApp
        callHaskellLib
        haskellPackages
        env;
}
