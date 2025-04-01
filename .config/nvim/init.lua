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

--- Plugins ---

-- Bootstrap lazy.nvim.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
-- vim.g.mapleader = " " -- Set in `vimrc.vim`.
-- vim.g.maplocalleader = "\\"

-- Setup lazy.nvim.
require("lazy").setup({
  spec = {
    -- add your plugins here

    -- Reopen files at last edit position.
    { "farmergreg/vim-lastplace", lazy = false },

    -- Support for TODO commends.
    {
      "folke/todo-comments.nvim",
      dependencies = { "nvim-lua/plenary.nvim" },
      opts = {},
    },

    -- Quick navigation.
    {
      "ggandor/leap.nvim",
      config = function()
        require("leap").create_default_mappings()
        -- -- Bidirectional `s`.
        -- vim.keymap.set({ "n", "x" }, "s", "<Plug>(leap)")
        -- --vim.keymap.set("n",        "S", "<Plug>(leap-from-window)")
        -- --vim.keymap.set("o",        "s", "<Plug>(leap-forward)")
        -- --vim.keymap.set("o",        "S", "<Plug>(leap-backward)")
      end,
    },

    -- -- Nice status bar.
    -- {
    --   "itchyny/lightline.vim",
    --   lazy = false,
    --   config = function()
    --     vim.o.showmode = false -- Redundant.
    --   end
    -- },

    -- `fzf` integration (`:Files`, `:Rg`).
    { "junegunn/fzf" },
    {
      "junegunn/fzf.vim",
      config = function()
        vim.keymap.set("", "<Leader>p", "<Cmd>Files<CR>")
        vim.keymap.set("", "<Leader>s", "<Cmd>Rg<CR>")
        -- When using :Files, pass the file list through
        --   https://github.com/jonhoo/proximity-sort
        -- to prefer files closer to the current file.
        function list_cmd()
          local base = vim.fn.fnamemodify(vim.fn.expand("%"), ":h:.:S")
          if base == "." then
            -- If there is no current file, proximity-sort can't do its thing.
            return "fd --hidden --type file --follow"
          else
            return vim.fn.printf(
              "fd --hidden --type file --follow | proximity-sort %s",
              vim.fn.shellescape(vim.fn.expand("%"))
            )
          end
        end
        vim.api.nvim_create_user_command("Files", function(arg)
          vim.fn["fzf#vim#files"](
            arg.qargs,
            { source = list_cmd(), options = "--scheme=path --tiebreak=index" },
            arg.bang
          )
        end, { bang = true, nargs = "?", complete = "dir" })
      end,
    },

    -- Git integration (`:Gitsigns`).
    {
      "lewis6991/gitsigns.nvim",
      config = function()
        require("gitsigns").setup({
          on_attach = function(bufnr)
            local gitsigns = require("gitsigns")

            local function map(mode, l, r, opts)
              opts = opts or {}
              opts.buffer = bufnr
              vim.keymap.set(mode, l, r, opts)
            end

            -- Hunks.
            map("n", "<Leader>gp", gitsigns.preview_hunk)
            map("n", "<Leader>gi", gitsigns.preview_hunk_inline)
            map("n", "<Leader>gs", gitsigns.stage_hunk)
            map("n", "<Leader>gS", gitsigns.stage_buffer)
            map("n", "<Leader>gr", gitsigns.reset_hunk)
            map("n", "<Leader>gR", gitsigns.reset_buffer)
            map("n", "<Leader>gN", gitsigns.prev_hunk)
            map("n", "<Leader>gn", gitsigns.next_hunk)

            -- Blame.
            map("n", "<Leader>gl", gitsigns.toggle_current_line_blame)
            map("n", "<Leader>gb", function()
              gitsigns.blame_line({ full = true })
            end)
            map("n", "<Leader>gB", gitsigns.blame)
          end,
        })
      end,
    },

    -- Indent guides.
    {
      "lukas-reineke/indent-blankline.nvim",
      lazy = false,
      main = "ibl",
      ---@module "ibl"
      ---@type ibl.config
      opts = {
        indent = { char = "│", highlight = "WhitespaceDimmed" },
        scope = { char = "│", highlight = "Whitespace", show_start = false, show_end = false },
      },
      config = function(_, opts)
        -- Custom colors (see `:highlight`).
        vim.api.nvim_set_hl(0, "WhitespaceDimmed", { fg = "#333333" })

        require("ibl").setup(opts)

        local hooks = require("ibl.hooks")
        hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
        hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_tab_indent_level)
      end,
    },

    -- More subtle column rulers.
    {
      "lukas-reineke/virt-column.nvim",
      lazy = false,
      opts = {
        char = "│",
        highlight = "WhitespaceDimmed",
      },
    },

    -- JetBrains theme.
    {
      "nickkadutskyi/jb.nvim",
      lazy = false,
      priority = 1000,
      opts = {},
      config = function()
        -- require("jb").setup({ transparent = true })
        vim.cmd("colorscheme jb")
      end,
    },

    -- Auto-`cd` to Git root.
    {
      "notjedi/nvim-rooter.lua",
      config = function()
        require("nvim-rooter").setup()
      end,
    },

    -- File tree.
    {
      "nvim-tree/nvim-tree.lua",
      config = function()
        vim.keymap.set("", "<Leader><Tab>", "<Cmd>NvimTreeToggle<CR>")
        require("nvim-tree").setup()
      end,
    },

    {
      "shortcuts/no-neck-pain.nvim",
      version = "*",
      config = function()
        vim.keymap.set("", "<Leader>z", "<Cmd>NoNeckPain<CR>")
        require("no-neck-pain").setup({
          width = 90,
          buffers = {
            right = {
              enabled = false,
            },
            scratchPad = {
              enabled = true,
              fileName = ".scratchpad",
              -- Set to `nil` to default to current working directory.
              location = "~/.config/nvim/",
            },
            bo = {
              filetype = "md",
            },
          },
        })
      end,
    },

    -- Wakatime time tracking (`:WakaTime[Today]`).
    { "wakatime/vim-wakatime", lazy = false },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "jb", "default" } },
  checker = {
    -- automatically check for plugin updates
    enabled = true,
    -- decrease the frequency of update-checking to once a week
    frequency = 3600 * 24 * 7,
  },
})
