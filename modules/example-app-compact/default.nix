{ stdenv
, example-assets
, example-app-static
, haskellPackages
, replace
}:

stdenv.mkDerivation {

    name = "example-compact";

    buildInputs = [ replace ];

    service = example-app-static;
    assets = example-assets;
    ekg = haskellPackages.ekg;

    builder = ./builder.sh;

}
