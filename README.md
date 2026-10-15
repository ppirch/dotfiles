# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).
Works on macOS and Linux.

## Quick start

One-liner (clones to `~/dotfiles`, installs everything):

```sh
curl -fsSL https://raw.githubusercontent.com/ppirch/dotfiles/master/bootstrap.sh | sh
```

With options — stow only `zsh`, or override the clone location:

```sh
curl -fsSL https://raw.githubusercontent.com/ppirch/dotfiles/master/bootstrap.sh | sh -s -- zsh
curl -fsSL https://raw.githubusercontent.com/ppirch/dotfiles/master/bootstrap.sh | DOTFILES_DIR=~/.dotfiles sh
```

On macOS, install the Xcode Command Line Tools first if prompted:
`xcode-select --install`. [Homebrew](https://brew.sh/) is used for
packages when present; `install.sh` otherwise falls back to
apt/dnf/pacman.

Each top-level directory is a Stow package that mirrors `$HOME`:

```
dotfiles/
├── bootstrap.sh             # curl|sh entrypoint (POSIX sh, macOS + Linux)
├── install.sh               # package installer (stow + per-package setup)
├── scripts/
│   ├── install-omz.sh       # zsh + oh-my-zsh (+plugins), standalone
│   └── install-nvim.sh      # neovim + ripgrep/fd/tree-sitter, standalone
├── nvim/                    # Stow package
│   └── .config/
│       └── nvim/            # -> ~/.config/nvim
│           ├── init.lua
│           └── lua/
├── zsh/                     # Stow package
│   └── .zshrc               # -> ~/.zshrc (oh-my-zsh based)
└── README.md
```

To add a new config (e.g. tmux, bash), create a package directory with
the same layout it has under `$HOME`:

```sh
mkdir -p tmux/.config/tmux
# move your config there, then:
stow -t "$HOME" tmux
```

## Requirements

Everything below is installed automatically by `bootstrap.sh`/`install.sh`
when missing, except where noted:

- `git`
- `stow`
- `zsh` + [oh-my-zsh](https://ohmyz.sh/) (via `scripts/install-omz.sh`)
- Neovim (latest `stable`) + `ripgrep`, `fd`, `tree-sitter-cli`
  (via `scripts/install-nvim.sh`)
- A C compiler + `make` for building `telescope-fzf-native.nvim`
  (not auto-installed — on macOS: `xcode-select --install`)
- A [Nerd Font](https://www.nerdfonts.com/) (optional, set `vim.g.have_nerd_font = true` in `nvim/.config/nvim/init.lua`)

## Install

```sh
git clone https://github.com/ppirch/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` installs Stow if missing, runs each package's setup script
(`scripts/install-*.sh`), then runs `stow -t "$HOME" <packages>`
(default: `nvim zsh`). To stow a single package manually:

```sh
cd ~/dotfiles
stow -t "$HOME" nvim        # link ~/.config/nvim
stow -D -t "$HOME" nvim     # unlink again
stow -R -t "$HOME" nvim     # relink (after adding files)
```

> Back up any existing `~/.config/nvim` first. Stow will refuse to
> overwrite real files — move them aside, then re-run.

## Zsh / oh-my-zsh

The `zsh` package symlinks `~/.zshrc`. When you run `./install.sh zsh`
(or the default `./install.sh`), it also:

1. Installs `zsh` itself if missing.
2. Clones [oh-my-zsh](https://ohmyz.sh/) to `~/.oh-my-zsh` if missing
   (plain `git clone`, so your stowed `.zshrc` is never overwritten).
3. Clones the extra plugins `zsh-autosuggestions` and
   `zsh-syntax-highlighting` into `~/.oh-my-zsh/custom/plugins/`.

The `.zshrc` enables the `git` and `nvm` oh-my-zsh plugins, picks up
Homebrew (`/opt/homebrew` on Apple Silicon, `/usr/local` on Intel Macs),
sets `nvim` as `$EDITOR` when available, and restores your tool paths
(`~/.local/bin`, cargo, nvm, opencode). Machine-specific overrides go in
`~/.zshrc.local` (sourced if present, never committed).

For just the shell without stowing, the oh-my-zsh setup also works standalone:

```sh
./scripts/install-omz.sh
```

To make zsh your login shell:

```sh
chsh -s "$(command -v zsh)"
```

## Neovim

The `nvim` package is based on
[kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) (single-file
`init.lua` + `lua/kickstart/*` examples + `lua/custom/*` for your own stuff).

Stowing it via `./install.sh nvim` first ensures `nvim`, `ripgrep`, `fd`
and `tree-sitter-cli` are installed (`scripts/install-nvim.sh` also works
standalone).

First run (installs plugins via built-in `vim.pack`):

```sh
nvim
```

Useful commands: `:checkhealth`, `:lua vim.pack.update(nil, { offline = true })`
(inspect plugin state), `:lua vim.pack.update()` (update plugins).

Search your config files with `<leader>sn`, Neovim help with `<leader>sh`.
Run `:Tutor` if you are new to Vim motions.

## Layout conventions

- One Stow package per tool (`nvim/`, later `bash/`, `git/`, ...).
- Inside a package, paths mirror `$HOME` (e.g. `nvim/.config/nvim/init.lua`).
- Repo-level tooling (this README, `install.sh`, `.github/`, `.gitignore`)
  stays at the root and is never stowed.
