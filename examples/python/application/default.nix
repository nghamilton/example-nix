{ buildPythonPackage
, flask
, waitress
, example-python-lib
}:

buildPythonPackage {
    name = "example-python-app";
    src = ./.;
    propagatedBuildInputs = [
        flask
        waitress
        example-python-lib
    ];
}
