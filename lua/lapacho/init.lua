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

local function git_branch_shada()
  local base_dir = vim.fn.stdpath("data") .. "/shadas/"
  local git_dir = vim.fn.system("git rev-parse --show-toplevel")
  local git_dir_split = vim.fn.split(git_dir, "/")
  local git_dir_name = git_dir_split[#git_dir_split]
  git_dir_name = string.gsub(git_dir_name, "\n", "")
  local branch_name = vim.fn.system("git rev-parse --abbrev-ref HEAD")
  branch_name = string.gsub(branch_name, "\n", "")
  create_directory(base_dir)
  create_directory(base_dir .. git_dir_name)
  local file_name = base_dir .. git_dir_name .. "/" .. branch_name .. ".shada"
  return file_name
end

-- Events
local function set_autocmds()
  local group = api.nvim_create_augroup("LapachoEvents", { clear = true })
  -- AutoSave
  api.nvim_create_autocmd("BufLeave", {
    pattern = "*",
    group = group,
    callback = function()
      vim.cmd("silent! LapachoSave")
    end,
  })
  -- AutoLoad
  api.nvim_create_autocmd("BufEnter", {
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

M.LapachoSave = function()
  local filename = git_branch_shada()
  vim.cmd("wshada " .. filename)
  print("Branch shada file saved to " .. filename)
end

M.LapachoLoad = function()
  vim.cmd("delmark A-Z")
  local filename = git_branch_shada()
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
