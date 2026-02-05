require_relative "setup_lib/dotfiles"

IGNORED_FILES = Dotfiles::IGNORED_FILES
HOMEDIR = Dotfiles.dest
BIN_DIR = HOMEDIR.join(".local/bin")

OS_NAME = Dotfiles.os_name

directory BIN_DIR
directory HOMEDIR.join(".tmp")

namespace :install do
  desc 'Install everything'
  task :all => %I[
    install:dotfiles
    install:#{OS_NAME}:zsh
    install:#{OS_NAME}:mise
    install:ohmyzsh
    install:tmuxifier
    install:ruby
    install:#{OS_NAME}:direnv
    install:#{OS_NAME}:neovim
    install:#{OS_NAME}:fzf
    install:#{OS_NAME}:jira
    install:#{OS_NAME}:gh
    install:#{OS_NAME}:glow
  ]

  desc 'Install oh-my-zsh'
  task :ohmyzsh => [:"install:#{OS_NAME}:zsh"] do
    next if HOMEDIR.join('.oh-my-zsh').exist?

    sh 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
  end

  desc 'Install tmuxifier'
  task :tmuxifier do
    next if HOMEDIR.join('.tmuxifier').exist?

    sh 'git clone https://github.com/jimeh/tmuxifier.git "${HOME}/.tmuxifier"'
  end

  desc "Install mise"
  task :mise => [:"install:#{OS_NAME}:mise"]

  desc 'Install ruby via mise'
  task :ruby => [:"install:#{OS_NAME}:mise"] do
    sh 'mise install ruby@latest'
  end

  desc 'Install jrnl'
  task :jrnl do
    sh 'python3 -m pip install --user jrnl'
  end

  desc "install all dotfiles into the user's home directory, merging with existing as necessary"
  task :merge_install do
    Dotfiles.merge_install
  end

  task :dotfiles => [:merge_install]

  namespace :mac do
    desc "Install jira CLI"
    task :jira do
      sh <<~BASH
        brew tap ankitpokhrel/jira-cli
        brew install jira-cli
      BASH
    end

    desc "Install macos packages with homebrew"
    rule(/install:mac:.*/) do |t|
      sh "brew install #{t.name.split(':').last}"
    end
  end

  namespace :linux do
    desc "Install mise on linux"
    task :mise do
      sh 'curl -s https://mise.run | sh'
    end

    desc "Install github CLI (gh)"
    task :gh do
      is_ubuntu = !`cat /etc/debian_version 2>/dev/null`.empty?
      next unless is_ubuntu

      # Shamelessly stolen from https://github.com/cli/cli/blob/trunk/docs/install_linux.md#debian
      sh <<~BASH
        (type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) \
          && sudo mkdir -p -m 755 /etc/apt/keyrings \
          && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
          && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
          && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
          && sudo mkdir -p -m 755 /etc/apt/sources.list.d \
          && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
          && sudo apt update \
          && sudo apt install gh -y
      BASH
    end

    desc "Install glow/markdown render CLI"
    task :glow do
      # Taken from https://github.com/charmbracelet/glow?tab=readme-ov-file#package-manager
      sh <<~BASH
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
        echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
        sudo apt update && sudo apt install glow
      BASH
    end

    desc "Install jira CLI"
    task :jira do
      require 'json'
      releases = JSON.parse(`curl -sL -H 'accept: application/json' https://api.github.com/repos/ankitpokhrel/jira-cli/releases/latest | jq '.assets[] | select(.name | contains("linux"))'
`)
      arch = `uname -m`
      asset = releases["assets"].find { _1["name"] =~ /linux/ && _1 =~ /#{arch}/ }
      sh "curl -sL #{asset["browser_download_url"]} > /tmp/jira.tgz"

      # We assume the binary is in <something>/bin/jira
      sh "tar xzf /tmp/jira.tgz --wildcards '*/bin/jira' --strip-components=2"
    end

    desc "Install linux packages with apt"
    rule(/install:linux:.*/) do |t|
      sh "sudo apt install -y #{t.name.split(':').last}"
    end
  end
end

