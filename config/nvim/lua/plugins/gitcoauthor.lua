-- ===dotfiles===
-- Find .git-coauthors file upward from current buffer directory
local team = require('lib.team')
local people = team.get_pairs()
if #people == 0 then return end

local function format_pairs(people)
  local authors = {}
  for _, person in ipairs(people) do
    local line = string.format("%s <%s>", person.name, person.email)
    table.insert(authors, line)
  end

  return authors
end

local authors = format_pairs(people)

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

