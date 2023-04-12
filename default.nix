/*
Save this file to ~/default.nix or your preferred path (make sure to
change the location in the update-profile script if you choose a
different place).

Install using `nix-env -f ~ --set`, from then on use `update-profile`.
*/
{ pkgs ? import <nixpkgs> {}
, name ? "user-env"
}: with pkgs;
buildEnv {
  inherit name;
  extraOutputsToInstall = ["out" "bin" "lib"];
  paths = [
    nix # If not on NixOS, this is important!
    
    
      
    (writeScriptBin "update-profile" ''
      #!${stdenv.shell}
      nix-env --set -f ~ --argstr name "$(whoami)-user-env-$(date -I)"
    '')

    # Manifest to make sure imperative nix-env doesn't work (otherwise it will overwrite the profile, removing all packages other than the newly-installed one).
    (writeTextFile {
      name = "break-nix-env-manifest";
      destination = "/manifest.nix";
      text = ''
        throw ''\''
          Your user environment is a buildEnv which is incompatible with
          nix-env's built-in env builder. Edit your home expression and run
          update-profile instead!
        ''\''
      '';
    })
    # To allow easily seeing which nixpkgs version the profile was built from, place the version string in ~/.nix-profile/nixpkgs-version
    (writeTextFile {
      name = "nixpkgs-version";
      destination = "/nixpkgs-version";
      text = lib.version;
    })
  ];
}
