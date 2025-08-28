# ===dotfiles===

require "shellwords"
require "json"
require "csv"

def me = "dugancathal@gmail.com"

def pbcopy(content) = `echo #{Shellwords.escape(content)} | pbcopy`
def pbpaste = `pbpaste`
