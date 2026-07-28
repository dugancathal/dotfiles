-- ftplugin/markdown.lua (or wherever)
local jrnl = require('jrnl.omnifunc')

function _G.JrnlOmnifunc(findstart, base)
  if findstart == 1 then
    return jrnl.find_bracket_start(vim.fn.getline('.'), vim.fn.col('.'))
  else
    return jrnl.filter_matches(jrnl.get_pairs(), base)
  end
end

vim.opt_local.omnifunc = 'v:lua.JrnlOmnifunc'
