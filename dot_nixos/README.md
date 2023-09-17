# Fixing binaries

[Blog post](https://rootknecht.net/blog/patching-binaries-for-nixos/)

## Lua-language-server

```
patchelf --set-interpreter $(patchelf --print-interpreter `which find`) $HOME/.local/share/nvim/mason/packages/lua-language-server/libexec/bin/lua-language-server
```

## Stylua

```
patchelf --set-interpreter $(patchelf --print-interpreter `which find`) /home/michael/.local/share/nvim/mason/packages/stylua/stylua
```

## Marksman

libz.so.1 and glibc++6 additional dependecies

```
patchelf --set-rpath "$(nix eval nixpkgs#zlib.outPath --raw)/lib:$(nix eval nixpkgs#stdenv.cc.cc.lib.outPath --raw)/lib" .local/share/nvim/mason/bin/marksman
```
