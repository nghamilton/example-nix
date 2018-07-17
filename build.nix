# Main build file for managing all modules

let

    # Version of Nixpkgs to lock down to for our build
    #
    pkgsMakeArgs = {

        # No attribute is actually required.  You can used the default Nixpkgs
        # version pinned by the library.  This version is also tested to build
        # the overrides built-in.

        # git describe: 18.03-beta-12822-g5ac6ab091a4
        rev = "14a9ca27e69e33ac8ffb708de08883f8079f954a";
        sha256 = "1grsq8mcpl88v6kz8dp0vsybr0wzfg4pvhamj42dpd3vgr93l2ib";
    };

    # Library for making our packages (local copy)
    #
    pkgsMake = import ./pkgs-make;

    # Alternatively, we can use the default Nixpkgs to pull a remote copy.
    # A remote copy allows us to share this Nix library with other projects.
    # Below we use `fetchFromGitHub`, but Nixpkgs has many other "fetch"
    # functions if you store your copy somewhere other than GitHub [FETCH].
    #
    # [FETCH] https://github.com/NixOS/nixpkgs/tree/master/pkgs/build-support
    #
    #pkgsMake =
    #    let
    #        pkgs-make-path =
    #            (import <nixpkgs> {}).fetchFromGitHub {
    #                owner = "shajra";
    #                repo = "example-nix";
    #                rev = "67affc85332894bb8892c9fe98bc9f378d663b90";
    #                sha256 = "1aps3bppzwg9vs9nq3brmxvn6dccwlrwbwq0i37m8k0a1g4446j6";
    #            };
    #    in
    #    import (pkgs-make-path + "/pkgs-make");

    # `pkgs-make` doesn't have a lot of code, but it does hide away enough
    # complexity to make this usage site simple and compact.
    #
    # If `pkgs-make` doesn't meet your all of your needs, you should be able
    # to modify it with some understanding of both Nix [NIX] and Nixpkgs
    # [NIXPKG], and the "call package" technique of calling functions in Nix
    # [CALLPKG].
    #
    # [NIX] http://nixos.org/nix/manual
    # [NIXPKGS] http://nixos.org/nixpkgs/manual
    # [CALLPKG] http://lethalman.blogspot.com/2014/09/nix-pill-13-callpackage-design-pattern.html

in

pkgsMake pkgsMakeArgs (args: 
    (import examples/haskell args)
        // (import examples/python args))
