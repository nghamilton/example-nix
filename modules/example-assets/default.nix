{ stdenv
, findutils
, haskellPackages
}:

stdenv.mkDerivation {
    name = "example-assets";
    buildInputs = [ findutils ];
    ekg = haskellPackages.ekg;
    builder = ./builder.sh;
}
