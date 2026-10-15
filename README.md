# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).
Works on macOS and Linux.

## Quick start

One-liner (clones to `~/dotfiles`, installs everything):

```sh
curl -fsSL https://raw.githubusercontent.com/ppirch/dotfiles/main/bootstrap.sh | sh
```

With options — stow only `zsh`, or override the clone location:

```sh
curl -fsSL https://raw.githubusercontent.com/ppirch/dotfiles/main/bootstrap.sh | sh -s -- zsh
curl -fsSL https://raw.githubusercontent.com/ppirch/dotfiles/main/bootstrap.sh | DOTFILES_DIR=~/.dotfiles sh
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
│   ├── install-nvim.sh      # neovim + ripgrep/fd/tree-sitter, standalone
│   ├── install-rust.sh      # rust toolchain (rustup + rustfmt + rust-analyzer), standalone
│   ├── install-docker.sh    # docker, standalone, opt-in only
│   ├── install-python.sh    # python via uv, standalone, opt-in only
│   ├── install-node.sh      # node via nvm (+pnpm), standalone, opt-in only
│   ├── install-tmux.sh      # tmux (+ ~/.tmux.conf package)
│   └── install-fonts.sh     # JetBrainsMono + FiraCode Nerd Fonts (required)
├── nvim/                    # Stow package
│   └── .config/
│       └── nvim/            # -> ~/.config/nvim
│           ├── init.lua
│           └── lua/
├── zsh/                     # Stow package
│   └── .zshrc               # -> ~/.zshrc (oh-my-zsh based)
├── tmux/                    # Stow package
│   └── .tmux.conf           # -> ~/.tmux.conf
├── ghostty/                 # Stow package (opt-in: ./install.sh ghostty)
│   └── .config/
│       └── ghostty/
│           └── config       # -> ~/.config/ghostty/config
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
- Rust toolchain (`rustc`/`cargo` via rustup, + `rustfmt`/`rust-analyzer`
  components) for the Neovim Rust setup (via `scripts/install-rust.sh`,
  included in the default `./install.sh` run)
- Docker (optional, opt-in only: `./install.sh docker` or
  `./scripts/install-docker.sh`)
- Python via [uv](https://docs.astral.sh/uv/) (optional, opt-in only:
  `./install.sh python` or `./scripts/install-python.sh`; installs a
  uv-managed Python without touching system Pythons)
- A C compiler + `make` for building `telescope-fzf-native.nvim`
  (not auto-installed — on macOS: `xcode-select --install`)
- JetBrainsMono + FiraCode [Nerd Fonts](https://www.nerdfonts.com/) (installed by
  default via `scripts/install-fonts.sh`; select one in your terminal.
  `vim.g.have_nerd_font` is `true` in `nvim/.config/nvim/init.lua`)

## Install

```sh
git clone https://github.com/ppirch/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` installs Stow if missing, runs each package's setup script
(`scripts/install-*.sh`), then runs `stow -t "$HOME" <packages>`
(default: `nvim zsh rust tmux fonts`; `docker`/`python`/`node` are opt-in
only and stow nothing). `tmux` installs tmux if missing
(`scripts/install-tmux.sh`) and stows `~/.tmux.conf`. To stow a single package manually:

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

The `.zshrc` enables the `git`, `nvm`, `node`, `npm`, `python`, `uv`,
`vscode` and `docker` oh-my-zsh plugins (+ `zsh-autosuggestions` and
`zsh-syntax-highlighting`); `pnpm` has no oh-my-zsh plugin and is
installed globally under the nvm-managed Node instead. It picks up
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

## Rust

Rust support is built on [rustaceanvim](https://github.com/mrcjkb/rustaceanvim)
(pinned to `^9` via `vim.pack`):

- `rust-analyzer` comes from the rustup toolchain (`./install.sh rust`),
  deliberately **not** Mason's copy, to avoid toolchain version mismatches.
- `rust`/`toml` Tree-sitter parsers install on first use, `rustfmt`
  runs via conform.nvim, Clippy is the default `check` command.
- No debug adapter configured. To debug Rust later, run
  `:MasonInstall codelldb` (auto-detected by rustaceanvim).

Verify with a scratch project:

```sh
cargo new /tmp/rust-nvim-test
nvim /tmp/rust-nvim-test/src/main.rs
```

`:checkhealth rustaceanvim` should be happy and exactly one
`rust-analyzer` client attached. Useful commands: `:RustLsp codeAction`,
`:RustLsp explainError`, `<leader>f` to format.

## Python

Python support is `pyright` (LSP, via Mason) + `ruff` (format +
import organization via conform.nvim, also via Mason) + the `python`
Tree-sitter parser. The interpreter itself comes from
`./install.sh python` (uv-managed). In projects, `uv venv` /
`uv sync` as usual — pyright picks up the local `.venv`
automatically.

## Layout conventions

- One Stow package per tool (`nvim/`, later `bash/`, `git/`, ...).
- Inside a package, paths mirror `$HOME` (e.g. `nvim/.config/nvim/init.lua`).
- Repo-level tooling (this README, `install.sh`, `.github/`, `.gitignore`)
  stays at the root and is never stowed.
