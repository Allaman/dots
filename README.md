# Dotfiles

My dotfiles for `macOS` and `Linux` (primarly Arch Linux).

## Neovim

My Neovim config is in its own [repo](https://github.com/Allaman/nvim)

## Karabiner

Karabiner is an exception for several reasons:

1. Karabiner modifies its content
2. Symlinking only works on the whole `.config/karabiner` folder as Karabiner creates new files as well

To solve this special case `.chezmoiscripts/run_once_link-karabiner.sh.tmpl` creates the symlink on macOS systems and `.config/karabiner` is in `.chezmoiignore`.

## TODOs

- check out [include external files](https://www.chezmoi.io/user-guide/include-files-from-elsewhere/#include-a-subdirectory-from-a-url) as replacement for Ansible git
