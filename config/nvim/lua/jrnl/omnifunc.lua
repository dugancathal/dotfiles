local team = require('lib.team')

local M = {}

function M.split_first(str, sep)
  local s, e = str:find(sep, 1, true)
  if not s then return str, nil end
  return str:sub(1, s - 1), str:sub(e + 1)
end

function M.parse_team_line(line)
  local term = M.split_first(line, '<')
  return vim.trim(term)
end

function format_candidates(people)
  local candidates = {}
  for _, person in ipairs(people) do
    if person.name and person.company then
      table.insert(candidates, person.company .. "/" .. person.name)
    end
  end
  return candidates
end

function M.filter_matches(candidates, base)
  local matches = {}
  for _, name in ipairs(candidates) do
    if name:lower():find(base:lower(), 1, true) then
      table.insert(matches, {
	word = name .. ']]',
	abbr = name
      })
    end
  end
  table.sort(matches, function (a,b) return a.word < b.word end)
  return matches
end

function M.find_bracket_start(line, col)
  local before = line:sub(1, col - 1)
  local s = before:find('%[%[[^%[%]]*$')
  if not s then return -3 end
  return s + 1
end

function M.get_pairs()
  return format_candidates(team.get_pairs())
end

return M
