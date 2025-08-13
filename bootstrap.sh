#!/usr/bin/env bash

if which mise >/dev/null 2>&1; then
  echo 'mise already installed'
else
  echo "Installing mise"
  curl -s https://mise.run | sh

  export PATH="$PATH:$HOME/.local/bin"
fi

if which rake >/dev/null 2>&1; then
  echo 'rake already installed'
else
  echo "Installing ruby@latest and rake"
  mise install ruby@latest
  mise exec ruby@latest -- gem install rake
fi


mise exec ruby@latest -- rake install:all
