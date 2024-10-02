IGNORED_FILES = %w[Rakefile README LICENSE]

desc "install the dot files into user's home directory"
task :install do
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

desc "install all dotfiles into the user's home directory, merging with existing as necessary"
task :merge_install do
  Dir['*'].each do |file|
    next if IGNORED_FILES.include? file
    
    merge_file(file)
  end

  system %Q{mkdir ~/.tmp}
end

desc 'Install oh-my-zsh'
task :ohmyzsh do
  sh 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
end

desc 'Install asdf'
task :asdf do
  sh 'git clone https://github.com/asdf-vm/asdf $HOME/.asdf'
end

desc 'Install ruby via asdf'
task :ruby => [:asdf] do
  sh 'asdf plugin add ruby'
  sh 'asdf ruby install 3.3.1'
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
  if File.read("#{ENV['HOME']}/.#{file}").includes?('===tjtjrb-dotfiles===')
    puts "already merged ~/.#{file}"
    return
  end

  system %Q{cat <(echo "===tjtjrb-dotfiles===") "$PWD/#{file}" >> "$HOME/.#{file}"}
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

