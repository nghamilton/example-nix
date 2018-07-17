{ call, lib, ... }:

rec {

    example-python-lib = call.python ./library;

    example-python-app = call.python ./application;

    example-python-tarball = lib.nix.tarball example-python-app;

    example-python-docker = lib.nix.dockerTools.buildImage {
        name = "example-docker";
        contents = example-python-app;
        config = {
            ExposedPorts = { "8081/tcp" = {}; };
            Entrypoint = [ "/bin/example-app" ];
        };
    };

}
