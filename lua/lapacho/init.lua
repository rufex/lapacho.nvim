local uv = vim.loop
local api = vim.api

local function create_directory(directory_path)
  local stat = uv.fs_stat(directory_path)
  if stat then
    return
  end
  print("Creating directory... " .. directory_path)
  uv.fs_mkdir(directory_path, 511, function(err)
    if err then
      print("Error creating directory: " .. err)
      return
    end
  end)
end

local function git_directory_name()
  local git_dir = vim.fn.system("git rev-parse --show-toplevel")
  local git_dir_split = vim.fn.split(git_dir, "/")
  local name = git_dir_split[#git_dir_split]
  name = string.gsub(name, "\n", "")
  return name
end

local function git_current_branch_name()
  local branch_name = vim.fn.system("git rev-parse --abbrev-ref HEAD")
  return string.gsub(branch_name, "\n", "")
end

local function lapacho_base_path()
  local path = vim.fn.stdpath("data") .. "/shadas/"
  create_directory(path)
  return path
end

local function git_directory_path()
  local path = lapacho_base_path() .. git_directory_name()
  create_directory(path)
  return path
end

local function head_file_path()
  return git_directory_path() .. "/" .. "head"
end

local function git_branch_shada_path()
  local git_dir_path = git_directory_path()
  local branch_name = git_current_branch_name()
  local file_name = git_dir_path .. "/" .. branch_name .. ".shada"
  return file_name
end

local function save_git_head()
  local branch_name = git_current_branch_name()
  local head_path = head_file_path()
  local file = io.open(head_path, "w")
  if not file then
    print("Error writing to head file")
  end
  file:write(branch_name)
  file:close()
end

local function read_git_head()
  local head_path = head_file_path()
  local file = io.open(head_path, "r")
  if not file then
    save_git_head()
    file = io.open(head_path, "r")
  end
  local branch_name = file:read()
  file:close()
  return branch_name
end

local function head_changed()
  local current_branch = git_current_branch_name()
  local head_branch = read_git_head()
  if current_branch ~= head_branch then
    save_git_head()
    return true
  end
  return false
end

-- Events
local function set_autocmds()
  local group = api.nvim_create_augroup("LapachoEvents", { clear = true })
  -- AutoSave
  api.nvim_create_autocmd({ "BufLeave", "TermLeave" }, {
    pattern = "*",
    group = group,
    callback = function()
      vim.cmd("silent! LapachoSave")
    end,
  })
  -- AutoLoad
  api.nvim_create_autocmd({ "BufEnter", "TermEnter" }, {
    pattern = "*",
    group = group,
    callback = function()
      vim.cmd("silent! LapachoLoad")
    end,
  })
end

local set_commands = function()
  vim.cmd([[
    command! LapachoSave lua require('lapacho').LapachoSave()
    command! LapachoLoad lua require('lapacho').LapachoLoad()
    command! LapachoPrintDir lua require('lapacho').PrintDir()
  ]])
end

local M = {}

-- Initialize
-- @param opts? table
-- @param opts.disable_autocmds? boolean
M.setup = function(opts)
  opts = opts or {}

  set_commands()

  if not opts.disable_autocmds then
    set_autocmds()
  end
end

M.PrintDir = function()
  local base_dir = vim.fn.stdpath("data") .. "/shadas/"
  print(base_dir)
end

M.PrintDir = function()
  print(lapacho_base_path())
end

M.LapachoSave = function()
  if head_changed() then
    return
  end
  local filename = git_branch_shada_path()
  vim.cmd("wshada " .. filename)
  print("Branch shada file saved to " .. filename)
end

M.LapachoLoad = function()
  vim.cmd("delmark A-Z")
  local filename = git_branch_shada_path()
  local stat = uv.fs_stat(filename)
  if not stat then
    print("Branch shada file not found: " .. filename)
    M.LapachoSave()
    return
  end
  vim.cmd("rshada! " .. filename)
  print("Branch shada file loaded from " .. filename)
end

return M
