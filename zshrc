# Path to your oh-my-zsh configuration.
ZSH=$HOME/.dotfiles/oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="steeef"

# Never know when you're gonna need to popd!
setopt AUTO_PUSHD

# Allow completing of the remainder of a command
bindkey "^N" insert-last-word

# Show contents of directory after cd-ing into it
chpwd() {
  ls -lrthG
}

# Save a ton of history
HISTSIZE=20000
HISTFILE=~/.zsh_history
SAVEHIST=20000

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Update OH MY ZSH every X days
export UPDATE_ZSH_DAYS=7

# Disable flow control commands (keeps C-s from freezing everything)
stty start undef
stty stop undef

# rbenv 
export PATH=$HOME/.rbenv/bin:$PATH
eval "$(rbenv init -)"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git rvm ruby bundler rake zeus go golang)

source $ZSH/oh-my-zsh.sh

# Source my custom files after oh-my-zsh so I can override things.
source $HOME/.dotfiles/zsh/aliases
source $HOME/.dotfiles/zsh/functions


# Completions
autoload -U compinit
compinit

# Enter directories without cd
setopt auto_cd

export EDITOR=vim

# Expand functions in prompt
setopt prompt_subst

# Ignore duplicates in history
setopt histignoredups

# Enable extended globbing
setopt EXTENDED_GLOB

# Customize to your needs...
export PATH=$HOME/.functions:/usr/local/bin:$PATH:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11/bin:$HOME/.bin:/usr/local/share/npm/bin

# Shaves about 0.5s off Rails boot time (when using perf patch). Taken from https://gist.github.com/1688857
export RUBY_GC_HEAP_INIT_SLOTS=1000000
export RUBY_HEAP_SLOTS_INCREMENT=1000000
export RUBY_HEAP_SLOTS_GROWTH_FACTOR=1
export RUBY_GC_MALLOC_LIMIT=1000000000
export RUBY_HEAP_FREE_MIN=500000
export GOPATH=$HOME/Documents/godev

# Add GOPATH/bin to PATH
export PATH=$PATH:$GOPATH/bin
