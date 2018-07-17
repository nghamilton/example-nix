let

    defaults = nixpkgs:
        {
            pyVersion = "36";
            overrides = import ./overrides;
            extraOverrides = pkgs: self: super: {};
            srcFilter = p: t: ! nixpkgs.lib.hasSuffix ".egg-info" p;
            envMoreTools = nixpkgs: [
                nixpkgs.pythonPackages.flake8
                nixpkgs.pythonPackages.ipython
                nixpkgs.pythonPackages.pylint
                nixpkgs.pythonPackages.yapf
            ];
            envPersists = true;
        };

in

{ nixpkgs
, pkgs
, pyVersion ? (defaults nixpkgs).pyVersion
, overrides ? (defaults nixpkgs).overrides
, extraOverrides ? (defaults nixpkgs).extraOverrides
, srcFilter ? (defaults nixpkgs).srcFilter
, envMoreTools ? (defaults nixpkgs).envMoreTools nixpkgs
, envPersists ? (defaults nixpkgs).envPersists
}:

let

    lib = import ../lib nixpkgs;

    rawPyPkgs = builtins.getAttr ("python" + pyVersion + "Packages") nixpkgs;

    finalOverrides =
        self: super:
            overrides nixpkgs self super // extraOverrides nixpkgs self super;

    pythonPackages =
        rawPyPkgs.override {
            overrides = self: super:
                (finalOverrides self super) // pkgs;
        };

    callPython = p:
        (pythonPackages.callPackage (import p) {}).overridePythonAttrs (old: {
            src = lib.nix.sources.cleanSourceWith {
                filter = srcFilter;
                src = lib.nix.sources.cleanSource old.src;
            };
            passthru = old.passthru or {} // {
                _isLocalPythonPackage =
                    lib.nix.sources.sourceLocal old.src;
            };
        });

    envPkgs =
        builtins.filter
            (e: e._isLocalPythonPackage or false)
            (builtins.attrValues pkgs);

    envFilter = pkg:
        pkg != null && ! builtins.elem pkg (builtins.attrValues pkgs);

    envArg = a:
        lib.nix.filter envFilter
            (lib.nix.unique
                (builtins.foldl'
                    (acc: s:
                        if builtins.hasAttr a s
                        then builtins.getAttr a s ++ acc
                        else acc)
                    []
                    envPkgs));

    findSetupPy = pkg:
        let
            unfilteredSrc = lib.nix.sources.unfilteredSource pkg.src;
            parent = dirOf unfilteredSrc;
            base = baseNameOf unfilteredSrc;
            type = (builtins.readDir parent).${base} or null;
            isDir = type == "directory";
            root = if isDir then unfilteredSrc else parent;
            setupPyType = (builtins.readDir root)."setup.py" or null;
            hasSetupPy = setupPyType == "regular";
            found = if hasSetupPy then [ "${toString root}/setup.py" ] else [];
        in
            if pkg ? src then found else [];

    setupPys =
        lib.nix.concatStringsSep "\n" (lib.nix.concatMap findSetupPy envPkgs);

    env =
        nixpkgs.stdenv.mkDerivation {
            name = "env-python";
            meta.license = lib.nix.licenses.bsd3;
            nativeBuildInputs = envMoreTools;
            propagatedBuildInputs = envArg "propagatedBuildInputs";
            nativePropagatedBuildInputs =
                envArg "nativePropagatedBuildInputs";
            passthru.withEnvTools = f: env.overrideAttrs (old: {
                nativeBuildInputs =
                    old.nativeBuildInputs ++ f nixpkgs;
            });
            shellHook = import ./shellHook.nix {
                inherit setupPys;
                bootstrappedPip = pythonPackages.bootstrapped-pip;
                envPersists = toString envPersists;
                sitePackages = pythonPackages.python.sitePackages;
            };
        };

in

{ inherit pythonPackages callPython env; }
