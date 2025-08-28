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
    install:#{OS_NAME}:neovim
    install:#{OS_NAME}:fzf
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

    desc "Install linux packages with apt"
    rule(/install:linux:.*/) do |t|
      sh "apt install -y #{t.name.split(':').last}"
    end
  end
end

