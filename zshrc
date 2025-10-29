# ===dotfiles===
# Lines configured by zsh-newuser-install
export ZSH_THEME=robbyrussell
source $HOME/.oh-my-zsh/oh-my-zsh.sh

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

export ZSH_THEME=robbyrussell
source $HOME/.oh-my-zsh/oh-my-zsh.sh
export PATH=$PATH:$HOME/.local/bin:$TMUXIFIER_BIN:$PYTHON3_BIN

if which direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi
if which fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi
if which mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi
