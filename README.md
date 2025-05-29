# nix-sqlean

A Nix flake for the [sqlean](https://github.com/nalgeon/sqlean) suite of extensions.

## Building

For a symlink tree containing all individual packages:

```
nix build github:tristanpemble/nix-sqlean
```

For the bundled sqlean extension to load them all at once (`.load sqlean`):

```
nix build github:tristanpemble/nix-sqlean#sqlean
```

For the individual extensions (`.load [extension]`):

```
nix build github:tristanpemble/nix-sqlean#crypto
nix build github:tristanpemble/nix-sqlean#define
nix build github:tristanpemble/nix-sqlean#fileio
nix build github:tristanpemble/nix-sqlean#fuzzy
nix build github:tristanpemble/nix-sqlean#ipaddr
nix build github:tristanpemble/nix-sqlean#math
nix build github:tristanpemble/nix-sqlean#regexp
nix build github:tristanpemble/nix-sqlean#stats
nix build github:tristanpemble/nix-sqlean#text
nix build github:tristanpemble/nix-sqlean#time
nix build github:tristanpemble/nix-sqlean#unicode
nix build github:tristanpemble/nix-sqlean#uuid
nix build github:tristanpemble/nix-sqlean#vsv
```
