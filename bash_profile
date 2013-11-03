source ~/.bash/aliases
source ~/.bash/functions
source ~/.bash/completions
source ~/.bash/paths
source ~/.bash/config
source ~/.bash/history_config

if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

# Enable rbenv
export PATH=$HOME/.rbenv/bin:$PATH
eval "$(rbenv init -)"

# Customize PATH
export PATH=~/.functions:/usr/local/bin:$PATH:$HOME/.bin
