#compdef ci.rb
# ===dotfiles===

local -a branches
branches=( ${(f)"$(git branch --format='%(refname:short)')"} )

_describe 'commands' branches

