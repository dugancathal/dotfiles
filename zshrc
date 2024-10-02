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

[[ -f "$HOME/.zsh/aliases" ]] && source "$HOME/.zsh/aliases"

if which brew >/dev/null 2>&1; then
  . "$(brew --prefix asdf)/libexec/asdf.sh"
fi

[[ -f "$HOME/.zsh/client-config" ]] && source "$HOME/.zsh/client-config"
