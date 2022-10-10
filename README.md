# Dotfiles

My [dotfiles](https://wiki.archlinux.org/title/Dotfiles) for `macOS` and `Linux` (primarily Arch Linux).

Successor of my [dotfiles](https://github.com/allaman/dotfiles) repo

## Bootstrap

[bootstrap](./bootstrap.sh) is an all-in-one script to download [chezmoi](https://www.chezmoi.io/) and [age](https://github.com/FiloSottile/age) and initialize chezmoi with this repository.

It can be downloaded on a fresh system with `wget -q https://raw.githubusercontent.com/Allaman/dots/main/bootstrap.sh -O /tmp/bootstrap.sh` and automatically configure my dotfiles.

Tested with Arch Linux and macOS on Apple Silicone. Should work with most Linux variants.

**Regarding the included brewfile keep in mind that Brew on Linux only supports amd64 on Linux**

## Neovim

My Neovim setup is in its own [repo](https://github.com/Allaman/nvim)

## Karabiner

Karabiner is an exception for several reasons:

1. Karabiner modifies its content
2. Symlinking only works on the whole `.config/karabiner` folder as Karabiner creates new files as well

To solve this special case `.chezmoiscripts/run_once_link-karabiner.sh.tmpl` creates the symlink on macOS systems and `.config/karabiner` is in `.chezmoiignore`.

## TODOs

- check out [include external files](https://www.chezmoi.io/user-guide/include-files-from-elsewhere/#include-a-subdirectory-from-a-url) as replacement for Ansible git
- Whats included
- pictures
