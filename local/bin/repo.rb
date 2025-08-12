class Repo
  def self.current = self.new

  def initialize(cwd = Dir.pwd)
    @cwd = cwd
  end

  def slug
    git_remote = remote

    case remote
    when /\Ahttp/ then URI.parse(git_remote).path[1..] # remove leading '/' (http://github.com/...)
    when /\Agit@/ then git_remote.split(':').last # everything after the host (git@github.com:....)
    end.gsub(/\.git\z/, "")
  end

  def remote(named: "origin")
    Dir.chdir(@cwd) do
      `git remote get-url origin`.strip 
    end
  end
end
