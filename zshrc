# ===dotfiles===
export ZSH_THEME=robbyrussell
export OHMYZSH_PATH="$HOME/.oh-my-zsh/oh-my-zsh.sh"
[[ -f "$OHMYZSH_PATH" ]] && source $OHMYZSH_PATH

HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
bindkey -e

zstyle :compinstall filename "$HOME/.zshrc"
autoload -Uz compinit
compinit

# Load shared POSIX aliases/functions, then zsh-specific
[[ -f "$HOME/.shell/env" ]] && source "$HOME/.shell/env"
[[ -f "$HOME/.shell/aliases" ]] && source "$HOME/.shell/aliases"
[[ -f "$HOME/.zsh/aliases" ]] && source "$HOME/.zsh/aliases"
[[ -f "$HOME/.zsh/client-config" ]] && source "$HOME/.zsh/client-config"

if which direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi
if which fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi
if which mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi
