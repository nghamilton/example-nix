nixpkgs:

nixpkgs.haskell.lib // {

    cleanSource = f: pkg:
        nixpkgs.haskell.lib.overrideCabal
            pkg
            (args: {
                src = nixpkgs.lib.sources.cleanSourceWith {
                    filter = f;
                    src = args.src;
                };
            });

}
