IGNORED_FILES = %w[Rakefile Gemfile Gemfile.lock README.md LICENSE]
HOMEDIR = Pathname(ENV['HOME'])
BIN_DIR = HOMEDIR.join(".bin")

directory BIN_DIR

namespace :install do
  desc 'Install everything'
  task :all => %i[install:ohmyzsh install:tmuxifier install:ruby install:asdf install:dotfiles]

  desc 'Install oh-my-zsh'
  task :ohmyzsh do
    next if HOMEDIR.join('.oh-my-zsh').exist?

    sh 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
  end

  desc 'Install asdf'
  task :asdf => [BIN_DIR] do
    if RUBY_PLATFORM.match(/darwin/)
      sh "brew install asdf"
    else
      asdf_version = "v0.16.6"
      arch = "dpkg --print-architecture".match?("arm") ? "arm" : "amd"
      sh "curl -L https://github.com/asdf-vm/asdf/releases/download/#{asdf_version}/asdf-#{asdf_version}-linux-#{arch}64.tar.gz | tar xzf - > ~/.bin/asdf"
      chmod_R 0775, BIN_DIR
    end
  end

  desc 'Install tmuxifier'
  task :tmuxifier do
    next if HOMEDIR.join('.tmuxifier').exist?

    sh 'git clone https://github.com/jimeh/tmuxifier.git "${HOME}/.tmuxifier"'
  end

  desc 'Install ruby via asdf'
  task :ruby => [:asdf] do
    sh 'asdf plugin add ruby'
    sh 'asdf ruby install 3.3.1'
  end

  desc 'Install jrnl'
  task :jrnl do
    sh 'python3 -m pip install --user jrnl'
  end

  desc "install all dotfiles into the user's home directory, merging with existing as necessary"
  task :merge_install do
    Dir['*'].each do |file|
      next if IGNORED_FILES.include? file

      merge_file(file)
    end

    system %Q{mkdir ~/.tmp}
  end

  desc "install the dot files into user's home directory"
  task :dotfiles do
    Dir['*'].each do |file|
      next if IGNORED_FILES.include? file

      if File.exist?(File.join(ENV['HOME'], ".#{file}"))
        if ask "overwrite ~/.#{file}?"
          replace_file(file)
        else
          puts "skipping ~/.#{file}"
        end
      else
        link_file(file)
      end
    end

    system %Q{mkdir ~/.tmp}
  end
end

def replace_file(file)
  system %Q{rm "$HOME/.#{file}"}
  link_file(file)
end

def link_file(file)
  puts "linking ~/.#{file}"
  system %Q{ln -nsf "$PWD/#{file}" "$HOME/.#{file}"}
end

def merge_file(file)
  puts "merging ~/.#{file}"
  return if Dir.exist?(file)

  dest_dotfile = "#{ENV['HOME']}/.#{file}"
  if !File.exist?(dest_dotfile)
    link_file(file)
    return
  end

  if File.read(dest_dotfile).include?('===tjtjrb-dotfiles===')
    puts "already merged ~/.#{file}"
    return
  end

  system %Q{bash -c 'cat <(echo -ne "\n\n# ===tjtjrb-dotfiles===\n\n") "$PWD/#{file}" >> "$HOME/.#{file}"'}
end

def ask(query)
  return true if do_all_after_ask?
  print "#{query} [ynaq] "
  case $stdin.gets.chomp
  when /y/i then true
  when /n/i then false
  when /a/i then @do_all = true
  when /q/i then exit
  end
end

def do_all_after_ask?
  @do_all ||= false
end

