nixpkgs:

let

    composed = builtins.foldl' (a: acc: b: a (acc b)) (a: a);

    applying = composed [ composed nixpkgs.lib.reverseList ];

    unfilteredSource = src:
        let ifFiltered = src ? _isLibCleanSourceWith;
        in if ifFiltered then src.origSrc else src;

    sourceLocal = src:
        ! nixpkgs.lib.hasPrefix builtins.storeDir
            (toString (unfilteredSource src));

    libExtn = {
        inherit composed applying;
        sources = { inherit sourceLocal unfilteredSource; };
        dockerTools = nixpkgs.dockerTools;
        tarball = nixpkgs.callPackage ./tarball {};
        license-report = nixpkgs.callPackage ./license-report {} nixpkgs;
    };

in

    {
        nix = nixpkgs.lib.recursiveUpdate nixpkgs.lib libExtn;
        haskell = import ./haskell.nix nixpkgs;
    }
