# ===dotfiles===

begin
  require "shellwords"
  require "json"
  require "csv"
rescue LoadError
  # noop
end

def me = "dugancathal@gmail.com"

def pbcopy(content) = `echo #{Shellwords.escape(content)} | pbcopy`
def pbpaste = `pbpaste`
