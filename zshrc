# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/tjtjrb/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

if which brew >/dev/null 2>&1; then
  . "$(brew --prefix asdf)/libexec/asdf.sh"
fi
[[ -f "$HOME/.asdf/asdf.sh" ]] && . "$HOME/.asdf/asdf.sh"

if which direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi
if which fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

export PATH=$PATH:$HOME/.bin:${ASDF_SHIM_DIR}:$TMUXIFIER_BIN:$PYTHON3_BIN
