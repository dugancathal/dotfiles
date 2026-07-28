local M = {}

function M.find_path()
  local dir = vim.fn.getcwd()
  local found = vim.fn.findfile(".team.json", dir .. ";")

  if found ~= "" then
    return found
  end

  local fallback = vim.fn.expand("~/.config/tjtaylor/team.json")
  if vim.fn.filereadable(fallback) == 1 then
    return fallback
  end

  return nil
end

function M.get_pairs()
  local team_file = M.find_path()
  if not team_file then return {} end

  local f = io.open(team_file, "r")
  if not f then return {} end

  local content = f:read("*a")
  f:close()

  local ok, data = pcall(vim.json.decode, content)
  if not ok or not data or not data.people then return {} end

  local pairs = data.people
  table.sort(pairs, function (a, b) return a.name < b.name end)
  return pairs
end

return M
