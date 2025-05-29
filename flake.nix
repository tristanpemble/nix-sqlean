{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    sqlean = {
      url = "github:nalgeon/sqlean";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    sqlean,
  }: let
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    packages = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};

      # Version management
      version =
        if (sqlean ? rev)
        then sqlean.rev
        else "unstable-${sqlean.lastModifiedDate}";
      sqleanVersion =
        if (sqlean ? rev)
        then sqlean.rev
        else "main";

      # Common build inputs and flags
      commonBuildInputs = [pkgs.sqlite];
      commonFlags = [
        "-Isrc"
        "-DSQLEAN_VERSION='\"${sqleanVersion}\"'"
        "-fPIC"
        "-shared"
        "-Wall"
        "-Wsign-compare"
        "-Wno-unknown-pragmas"
      ];

      # Helper function to build an extension
      buildExtension = {
        name,
        description,
        extraFlags ? [],
        extraLinkFlags ? [],
      }:
        pkgs.stdenv.mkDerivation {
          pname = "sqlean-${name}";
          inherit version;

          src = sqlean;

          buildInputs = commonBuildInputs;

          buildPhase = ''
            mkdir -p dist
            ${pkgs.gcc}/bin/gcc -O3 ${builtins.concatStringsSep " " (commonFlags ++ extraFlags)} \
              src/sqlite3-${name}.c src/${name}/*.c ${
              if name == "text"
              then "src/${name}/*/*.c"
              else ""
            } \
              -o dist/${name}.so ${builtins.concatStringsSep " " extraLinkFlags}
          '';

          installPhase = ''
            mkdir -p $out/lib
            cp dist/${name}.so $out/lib/
          '';
        };
    in {
      # Individual extensions
      crypto = buildExtension {
        name = "crypto";
        description = "SQLite extension for hashing, encoding and decoding data";
        extraFlags = ["-O1"];
      };

      define = buildExtension {
        name = "define";
        description = "SQLite extension for user-defined functions and dynamic SQL";
      };

      fileio = buildExtension {
        name = "fileio";
        description = "SQLite extension for reading and writing files";
      };

      fuzzy = buildExtension {
        name = "fuzzy";
        description = "SQLite extension for fuzzy string matching and phonetics";
        extraFlags = ["-O1"];
      };

      ipaddr = buildExtension {
        name = "ipaddr";
        description = "SQLite extension for IP address manipulation";
      };

      math = buildExtension {
        name = "math";
        description = "SQLite extension for mathematical functions";
        extraLinkFlags = ["-lm"];
      };

      regexp = pkgs.stdenv.mkDerivation {
        pname = "sqlean-regexp";
        inherit version;

        src = sqlean;

        buildInputs = commonBuildInputs;

        buildPhase = ''
          mkdir -p dist
          ${pkgs.gcc}/bin/gcc -O3 ${builtins.concatStringsSep " " commonFlags} \
            -include src/regexp/constants.h \
            src/sqlite3-regexp.c \
            src/regexp/extension.c \
            src/regexp/regexp.c \
            src/regexp/pcre2/*.c \
            -o dist/regexp.so
        '';

        installPhase = ''
          mkdir -p $out/lib
          cp dist/regexp.so $out/lib/
        '';
      };

      stats = buildExtension {
        name = "stats";
        description = "SQLite extension for statistical functions";
        extraLinkFlags = ["-lm"];
      };

      text = buildExtension {
        name = "text";
        description = "SQLite extension for advanced string functions and Unicode";
      };

      time = buildExtension {
        name = "time";
        description = "SQLite extension for high-precision date/time functions";
      };

      unicode = buildExtension {
        name = "unicode";
        description = "SQLite extension for Unicode support";
      };

      uuid = buildExtension {
        name = "uuid";
        description = "SQLite extension for UUID generation and manipulation";
      };

      vsv = buildExtension {
        name = "vsv";
        description = "SQLite extension for CSV files as virtual tables";
        extraLinkFlags = ["-lm"];
      };

      # Combined bundle containing all extensions
      sqlean = pkgs.stdenv.mkDerivation {
        pname = "sqlean";
        inherit version;

        src = sqlean;

        buildInputs = commonBuildInputs;

        buildPhase = ''
          mkdir -p dist
          ${pkgs.gcc}/bin/gcc -O1 ${builtins.concatStringsSep " " commonFlags} \
            -include src/regexp/constants.h \
            src/sqlite3-sqlean.c \
            src/crypto/*.c \
            src/define/*.c \
            src/fileio/*.c \
            src/fuzzy/*.c \
            src/ipaddr/*.c \
            src/math/*.c \
            src/regexp/*.c \
            src/regexp/pcre2/*.c \
            src/stats/*.c \
            src/text/*.c \
            src/text/*/*.c \
            src/time/*.c \
            src/unicode/*.c \
            src/uuid/*.c \
            src/vsv/*.c \
            -o dist/sqlean.so \
            -lm
        '';

        installPhase = ''
          mkdir -p $out/lib
          cp dist/sqlean.so $out/lib/
        '';
      };

      default = pkgs.symlinkJoin {
        name = "sqlean-all";
        paths = [
          self.packages.${system}.crypto
          self.packages.${system}.define
          self.packages.${system}.fileio
          self.packages.${system}.fuzzy
          self.packages.${system}.ipaddr
          self.packages.${system}.math
          self.packages.${system}.regexp
          self.packages.${system}.stats
          self.packages.${system}.text
          self.packages.${system}.time
          self.packages.${system}.unicode
          self.packages.${system}.uuid
          self.packages.${system}.vsv
          self.packages.${system}.sqlean
        ];
      };
    });
  };
}
