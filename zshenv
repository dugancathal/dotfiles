# Always sourced first by zsh, use this for setting vars, not calling functions

[[ -f "$HOME/.zsh/aliases" ]] && source "$HOME/.zsh/aliases"
[[ -f "$HOME/.zsh/client-config" ]] && source "$HOME/.zsh/client-config"

export EDITOR=vim
export ASDF_SHIM_DIR="${ASDF_DATA_DIR:-"$HOME"}/.asdf/shims"
export TMUXIFIER_BIN="${HOME}/.tmuxifier/bin"
export PYTHON3_BIN="$(python3 -m site --user-base)/bin"

