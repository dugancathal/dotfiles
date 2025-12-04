-- ===dotfiles===
-- Find .git-coauthors file upward from current buffer directory
local function find_coauthor_file()
  local dir = vim.fn.expand("%:p:h")
  local found = vim.fn.findfile(".git-coauthors", dir .. ";")
  return found ~= "" and found or nil
end

-- Pick local or fallback global file
local list_path = find_coauthor_file()
if not list_path then
  list_path = vim.fn.expand("~/.config/git/coauthors.txt")
end

-- Load authors into a table
local authors = {}
do
  local f = io.open(list_path, "r")
  if f then
    for line in f:lines() do
      line = vim.trim(line)
      if line ~= "" then
        table.insert(authors, line)
      end
    end
    f:close()
  else
    vim.notify("No co-author file found", vim.log.levels.WARN)
  end
end

-- Multi-select helper: toggle with <CR>, finish with <Esc>
local function pick_coauthors(cb)
  local chosen = {} -- [name] = true

  local function step()
    vim.ui.select(
      authors,
      {
        prompt = "Pick co-author(s): <Enter> toggles, <Esc> to finish",
        format_item = function(item)
          return (chosen[item] and "✓ " or "  ") .. item
        end,
      },
      function(item)
        if not item then
          -- User pressed <Esc> -> done
          local out = {}
          for name, sel in pairs(chosen) do
            if sel then table.insert(out, name) end
          end
          table.sort(out)
          cb(out)
          return
        end
        chosen[item] = not chosen[item]
        step() -- reopen picker
      end
    )
  end

  step()
end

-- Insert one "Co-authored-by" line per selected name
local function insert_coauthors()
  if #authors == 0 then
    vim.notify("No co-authors found", vim.log.levels.WARN)
    return
  end

  pick_coauthors(function(picked)
    if #picked == 0 then return end
    local lines = {}
    for _, name in ipairs(picked) do
      table.insert(lines, "Co-authored-by: " .. name)
    end
    vim.api.nvim_put(lines, "l", true, true)
  end)
end

vim.keymap.set("n", "<leader>ca", insert_coauthors, { buffer = true, desc = "Insert Co-authored-by trailer" })
vim.keymap.set("i", "<C-g>a", function()
  vim.schedule(function()
    vim.cmd("stopinsert")
    insert_coauthors()
  end)
end, { buffer = true })

