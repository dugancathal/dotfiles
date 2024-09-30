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

. "$(brew --prefix asdf)/libexec/asdf.sh"

[[ -f "$HOME/.zsh/client-config" ]] && source "$HOME/.zsh/client-config"
