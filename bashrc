# ===dotfiles===
# Non-interactive bash sessions should bail early.
[[ $- != *i* ]] && return

# Load shared POSIX env vars and aliases, then bash-specific
[[ -f "$HOME/.shell/env" ]] && . "$HOME/.shell/env"
[[ -f "$HOME/.shell/aliases" ]] && . "$HOME/.shell/aliases"
[[ -f "$HOME/.bash/aliases" ]] && . "$HOME/.bash/aliases"
[[ -f "$HOME/.bash/client-config" ]] && . "$HOME/.bash/client-config"

export PATH="$PATH:$HOME/.local/bin:${TMUXIFIER_BIN}:${PYTHON3_BIN}"

# History
HISTFILE="$HOME/.bash_history"
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoredups:erasedups
shopt -s histappend

# Tool integrations
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook bash)"
fi
if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --bash)"
fi
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate bash)"
fi
