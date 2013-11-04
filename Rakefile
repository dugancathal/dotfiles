require 'rake'

desc "install the dot files into user's home directory"
task :install do
  replace_all = false
  Dir['*'].each do |file|
    next if %w[Rakefile README LICENSE vim-plugins id_dsa.pub].include? file
    
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

desc 'Install my opinionated vim plugins'
task :vim_packages do
  puts "Installing pathogen"
  system <<-PATHOGEN
    mkdir -p ~/.vim/autoload ~/.vim/bundle; \
    curl -Sso ~/.vim/autoload/pathogen.vim \
        https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim
  PATHOGEN
  File.read('vim-plugins').split("\n").each do |repo|
    name = repo.split('/').last
    if ask "Install #{repo}?"
      system %Q{git clone git://github.com/#{repo}.git ~/.vim/bundle/#{name}}
    end
  end
end

desc 'Install rbenv and latest ruby'
task :ruby do
  system %Q{git clone https://github.com/sstephenson/rbenv.git ~/.rbenv}
  system %Q{git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build}
  shell_type = ENV['SHELL'].split('/').last
  system %Q{source ~/.#{shell_type}rc}
  system %Q{rbenv install 2.0.0-p247}
end

def replace_file(file)
  system %Q{rm "$HOME/.#{file}"}
  link_file(file)
end

def link_file(file)
  puts "linking ~/.#{file}"
  system %Q{ln -s "$PWD/#{file}" "$HOME/.#{file}"}
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
