{ call, lib, ... }:

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

    example-haskell-lib = haskellLib ./library;

    example-haskell-app = haskellApp ./application;

    example-haskell-app-dynamic =
        lib.haskell.enableSharedExecutables example-haskell-app;

    example-haskell-tarball = lib.nix.tarball example-haskell-app;

    example-haskell-docker = lib.nix.dockerTools.buildImage {
        name = "example-docker";
        contents = example-haskell-app;
        config = {
            ExposedPorts = { "8081/tcp" = {}; };
            Entrypoint = [ "/bin/example-app" ];
        };
    };

    example-haskell-stack = call.package ./stack;

}
