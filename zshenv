# ===dotfiles===
# Sourced for ALL zsh invocations (scripts, non-interactive shells, etc.)
# Only set environment variables here - no aliases, functions, or interactive config.

export EDITOR=vim
export TMUXIFIER_BIN="${HOME}/.tmuxifier/bin"

if which python3 >/dev/null 2>&1; then
  export PYTHON3_BIN="$(python3 -m site --user-base)/bin"
fi

