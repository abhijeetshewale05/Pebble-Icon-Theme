{
  description = "Pebble Icon Theme";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs   = nixpkgs.legacyPackages.${system};

    mkPebble = variant: pkgs.stdenvNoCC.mkDerivation {
      pname   = "pebble-icon-theme-${pkgs.lib.strings.toLower variant}";
      version = "unstable-2025";

      src = ./.;

      dontFixup = true;

      installPhase = ''
        mkdir -p $out/share/icons

        # always install base Pebble as the fallback
        cp -r Pebble $out/share/icons/

        # install the requested variant on top (skip if it IS the base)
        ${pkgs.lib.optionalString (variant != "Pebble") ''
          cp -r ${variant} $out/share/icons/
        ''}
      '';

      meta = {
        description = "Pebble ${variant} icon theme - squircle macOS-inspired icons";
        license     = pkgs.lib.licenses.gpl3;
        platforms   = pkgs.lib.platforms.linux;
      };
    };

    variants = [
      "Pebble"
      "Pebble-Blue"
      "Pebble-Green"
      "Pebble-Orange"
      "Pebble-Pink"
      "Pebble-Purple"
      "Pebble-Red"
      "Pebble-Slate"
      "Pebble-Teal"
      "Pebble-Yaru"
      "Pebble-Yellow"
    ];

    packages = builtins.listToAttrs (map (v: {
      name  = pkgs.lib.strings.toLower v;
      value = mkPebble v;
    }) variants);

  in {
    packages.${system} = packages // {
      default = packages.pebble;
      all     = pkgs.symlinkJoin {
        name  = "pebble-icon-theme-all";
        paths = builtins.attrValues packages;
      };
    };
  };
}