-- Source Vim configuration file. By keeping the "generic" config in
-- Vim Script, we can re-use the same file for Vim and IdeaVim.
vim.cmd.source(vim.fs.joinpath(vim.fn.stdpath("config"), "vimrc.vim"))

-- Persist extra column before line numbers (for signs).
vim.opt.signcolumn = "yes:1"

-- Highlight-on-yank.
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Normal-looking terminal.
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    vim.opt.number = false
    vim.opt.relativenumber = false
  end,
})

-- Run formatters based on file type.
local function smart_format()
  local filetype = vim.bo.filetype
  local filepath = vim.fn.expand("%:p")

  local label
  local cmds

  if filetype == "rust" then
    label = "cargo fmt"
    cmds = { { "cargo", "fmt", "--", filepath } }
  elseif filetype == "python" then
    label = "ruff format"
    cmds = {
      { "ruff", "check", "--fix", "--select=I", filepath },
      { "ruff", "format", filepath },
    }
  elseif
    filetype == "javascript"
    or filetype == "typescript"
    or filetype == "html"
    or filetype == "css"
    or filetype == "markdown"
    or filetype == "yaml"
  then
    label = "prettier"
    cmds = { { "prettier", "--write", "--prose-wrap=always", "--print-width=72", filepath } }
  elseif filetype == "lua" then
    label = "stylua"
    cmds = { { "stylua", "--indent-type=spaces", "--indent-width=2", filepath } }
  else
    vim.notify("No formatter configured for filetype: " .. filetype, vim.log.levels.WARN)
    return
  end

  vim.cmd("write")

  for _, cmd in ipairs(cmds) do
    local obj = vim.system(cmd, { text = true }):wait()
    vim.schedule(function()
      if obj.code == 0 then
        vim.api.nvim_echo({ { '"' .. label .. '" OK', "Normal" } }, false, {})
      else
        vim.notify(obj.stderr, vim.log.levels.ERROR)
      end
    end)
  end

  vim.cmd("edit")
end

vim.keymap.set("n", "<Leader>xf", smart_format, { desc = "Smart formatter." })
