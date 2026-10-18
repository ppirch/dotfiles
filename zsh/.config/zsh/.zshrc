# ~/.config/zsh/.zshrc — the shared base, managed by dotfiles (zsh/ package,
# GNU Stow). Its local copy is a symlink into this repo, so edit it here and
# re-stow: `stow -R -t "$HOME" zsh`.
# Machine-specific overrides go in ~/.zshrc, the real (untracked) entry file.

# Powerlevel10k instant prompt (must stay at the very top of this file).
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --- oh-my-zsh ---------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Uncomment to update oh-my-zsh automatically without prompting:
# zstyle ':omz:update' mode auto

plugins=(
  git
  nvm
  node
  npm
  python
  uv
  vscode
  zsh-autosuggestions
  zsh-syntax-highlighting
  docker
)

if [ -d "$ZSH" ]; then
  # shellcheck disable=SC1091
  source "$ZSH/oh-my-zsh.sh"
else
  echo "oh-my-zsh not found at $ZSH — run ./install.sh zsh to install it." >&2
fi

# --- editor ------------------------------------------------------------------
if command -v nvim >/dev/null 2>&1; then
  export EDITOR="nvim"
  export VISUAL="nvim"
  alias vim="nvim"
  alias vi="nvim"
fi

# --- Homebrew (macOS; harmless elsewhere) ---------------------------------------
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# --- PATH / tool environments ----------------------
[ -d "$HOME/bin" ] && export PATH="$HOME/bin:$PATH"
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Fallback if the oh-my-zsh nvm plugin is unavailable:
if ! command -v nvm >/dev/null 2>&1; then
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
fi

# Powerlevel10k config (tracked in this repo; regenerate with `p10k configure`).
[ -f "$HOME/.p10k.zsh" ] && . "$HOME/.p10k.zsh"
