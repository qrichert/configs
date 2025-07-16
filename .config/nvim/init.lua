-- Source Vim configuration file. By keeping the "generic" config in
-- Vim Script, we can re-use the same file for Vim and IdeaVim.
vim.cmd.source(vim.fs.joinpath(vim.fn.stdpath("config"), "vimrc.vim"))

-- Faster startup times (experimental).
vim.loader.enable(true)

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
    or filetype == "yaml"
  then
    label = "prettier"
    cmds = { { "prettier", "--write", "--prose-wrap=always", "--print-width=72", filepath } }
  elseif filetype == "markdown" then
    label = "prettier + normalize-punctuation"
    cmds = {
      { "prettier", "--write", "--prose-wrap=always", "--print-width=72", filepath },
      { "normalize-punctuation", filepath },
    }
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

    -- Better `%`.
    --
    -- Detects blocks more accurately, and:
    -- - `%` Cycle through blocks.
    -- - `g%`/`z%` Go up/down a level.
    -- - `[%`/`]%` Go to previous/next block open/close.
    { "andymass/vim-matchup", event = { "BufReadPre" } },

    -- Reopen files at last edit position.
    { "farmergreg/vim-lastplace", lazy = false },

    -- Support for TODO comments.
    {
      "folke/todo-comments.nvim",
      dependencies = { "nvim-lua/plenary.nvim" },
      opts = {},
      config = function(_, opts)
        vim.keymap.set("n", "<Leader>t", "<Cmd>TodoFzfLua<CR>")
        require("todo-comments").setup(opts)
      end,
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

    -- `fzf` integration (`:FzfLua`).
    --
    -- Dependencies:
    --  - fd-find
    --  - proximity-sort
    --  - ripgrep
    {
      "ibhagwan/fzf-lua",
      event = "VeryLazy",
      -- optional for icon support
      dependencies = { "nvim-tree/nvim-web-devicons" },
      opts = {
        keymap = {
          -- Targets `fzf-lua`'s UI (preview windows, etc.).
          builtin = {
            ["<C-f>"] = "preview-page-down",
            ["<C-b>"] = "preview-page-up",
          },
          -- Targets `fzf`'s binary (the list of files).
          fzf = {
            ["ctrl-y"] = "select-all+accept",
            ["ctrl-u"] = "half-page-up",
            ["ctrl-d"] = "half-page-down",
            ["ctrl-x"] = "jump",
            -- Conflicts with `builtin`.
            -- ["ctrl-f"] = "preview-page-down",
            -- ["ctrl-b"] = "preview-page-up",
          },
        },
      },
      config = function(_, opts)
        local fzf = require("fzf-lua")
        fzf.setup(opts)

        vim.keymap.set("n", "<Leader>s", function()
          fzf.grep_project()
        end, { desc = "fzf-lua: grep project (rg)" })

        vim.keymap.set("n", "<Leader>p", function()
          -- `proximity-sort` needs relative paths because we output
          -- relative paths with `fd`.
          local current_file = vim.fn.expand("%:.")
          local fd_cmd = "fd --hidden --type file --follow --exclude .git/"
          if current_file == "" then
            fzf.files({ cmd = fd_cmd })
          else
            -- Pass the file list through
            --   https://github.com/jonhoo/proximity-sort
            -- to prefer files closer to the current file.
            fzf.files({
              cmd = ("%s | proximity-sort %s"):format(fd_cmd, vim.fn.shellescape(current_file)),
              -- Let `fzf` apply fuzzy scoring, but prefer the original
              -- `proximity-sort` order when scores are equal. Without
              -- this, `fzf` may reorder matches based purely on fuzzy
              -- score, ignoring proximity entirely.
              fzf_opts = {
                ["--tiebreak"] = "index",
              },
            })
          end
        end, { desc = "fzf-lua: find file (fd + proximity-sort)" })
      end,
    },

    -- Nice status bar.
    {
      "itchyny/lightline.vim",
      lazy = false,
      config = function()
        vim.o.showmode = false -- Redundant.
      end,
    },

    -- Database client.
    {
      "kndndrj/nvim-dbee",
      dependencies = {
        "MunifTanjim/nui.nvim",
        "MattiasMTS/cmp-dbee",
      },
      build = function()
        -- Install tries to automatically detect the install method.
        -- if it fails, try calling it with one of these parameters:
        --    "curl", "wget", "bitsadmin", "go"
        require("dbee").install()
      end,
      config = function()
        -- `persistence.json` is in `~/.local/state/nvim/dbee/`:
        --     require("dbee.sources").FileSource:new(vim.fn.stdpath("state") .. "/dbee/persistence.json"),
        require("dbee").setup(--[[optional config]])
      end,
    },
    {
      "MattiasMTS/cmp-dbee",
      ft = "sql", -- optional but good to have
      opts = {}, -- needed
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

        -- Make inlays less intrusive.
        vim.api.nvim_set_hl(0, "LspInlayHint", { fg = "Gray" })
      end,
    },

    -- Auto-`cd` to Git root.
    {
      "notjedi/nvim-rooter.lua",
      config = function()
        require("nvim-rooter").setup()
      end,
    },

    -- Restore last session's open files for the current directory.
    {
      "rmagatti/auto-session",
      lazy = false,

      ---enables autocomplete for opts
      ---@module "auto-session"
      ---@type AutoSession.Config
      opts = {
        -- suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
        -- log_level = 'debug',
      },
    },

    -- Edit your filesystem like a buffer.
    --
    -- Commands:
    --  - `:Oil`
    --  - `g?` Help.
    {
      "stevearc/oil.nvim",
      ---@module 'oil'
      ---@type oil.SetupOpts
      opts = {
        -- Skip the confirmation popup for simple operations (:help oil.skip_confirm_for_simple_edits)
        skip_confirm_for_simple_edits = true,
        view_options = {
          -- Show files and directories that start with "."
          show_hidden = true,
        },
      },
      -- Optional dependencies
      -- dependencies = { { "echasnovski/mini.icons", opts = {} } },
      dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
      -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
      lazy = false,
      config = function(_, opts)
        local oil = require("oil")
        oil.setup(opts)

        vim.keymap.set("n", "-", "<Cmd>Oil<CR>", { desc = "Open parent directory" })
        vim.keymap.set("n", "<Leader><Tab>", function()
          -- Look for an existing Oil buffer in a vertical split.
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
            if ft == "oil" then
              vim.api.nvim_win_close(win, true)
              return
            end
          end

          -- Otherwise, open a vertical Oil split on the left.
          -- Adjust width as needed.
          vim.cmd("topleft vsplit | vertical resize 30")
          oil.open()
        end, { desc = "Toggle Oil file explorer" })
      end,
    },

    -- Wakatime time tracking (`:WakaTime[Today]`).
    { "wakatime/vim-wakatime", lazy = false },

    -- Auto-pairing.
    {
      "windwp/nvim-autopairs",
      event = "InsertEnter",
      config = true,
      -- use opts = {} for passing setup options
      -- this is equivalent to setup({}) function
    },

    --- Mason ---

    -- Mason is a package manager, like `brew` for Neovim. It doesn't
    -- install packages on its own by default.
    {
      "mason-org/mason.nvim",
      opts = {},
    },

    -- For the LSPs, refer to the 'LSP' section.

    --- Treesitter ---

    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = function()
        require("nvim-treesitter.configs").setup({
          -- A list of parser names, or "all" (the listed parsers MUST always be installed)
          ensure_installed = {
            "bash",
            "c",
            "caddy",
            "cpp",
            "css",
            "csv",
            "dockerfile",
            "editorconfig",
            "fish",
            "git_config",
            "git_rebase",
            "gitattributes",
            "gitcommit",
            "gitignore",
            "html",
            "javadoc",
            "javascript",
            "json",
            -- "latex", -- Requires Treesitter CLI.
            "lua",
            "luadoc",
            "make",
            "markdown",
            "markdown_inline",
            "mermaid",
            "nginx",
            "po",
            "python",
            "query",
            "regex",
            "rust",
            "sql",
            "ssh_config",
            "toml",
            "typescript",
            "vim",
            "vimdoc",
            "xml",
            "yaml",
          },

          -- Install parsers synchronously (only applied to `ensure_installed`)
          sync_install = false,

          -- Automatically install missing parsers when entering buffer
          -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
          auto_install = false,

          -- List of parsers to ignore installing (or "all")
          -- ignore_install = { "javascript" },

          -- If you need to change the installation directory of the parsers (see -> Advanced Setup)
          -- Default: ~/.local/share/nvim/site/parser/
          -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

          highlight = {
            enable = true,

            -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
            -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
            -- the name of the parser)
            -- list of language that will be disabled

            -- disable = { "c", "rust" },

            -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
            disable = function(lang, buf)
              local max_filesize = 512 * 1024 -- 512 KB
              local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
              if ok and stats and stats.size > max_filesize then
                vim.schedule(function()
                  vim.notify("Treesitter disabled for large file: " .. stats.size .. " bytes", vim.log.levels.WARN)
                end)
                return true
              end
            end,

            -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
            -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
            -- Using this option may slow down your editor, and you may see some duplicate highlights.
            -- Instead of true it can also be a list of languages
            additional_vim_regex_highlighting = false,
          },

          matchup = {
            -- Required for vim-matchup to work with Treesitter.
            enable = true,
            -- Do not use virtual text to highlight the end of a block.
            disable_virtual_text = true,
          },
        })
      end,
    },

    --- LSP, Completions, et al. ---

    -- Mason will not install dependencies by default. This installs
    -- language servers automatically.
    {
      "mason-org/mason-lspconfig.nvim",
      opts = {
        -- For configuration, see `vim.lsp.config("...")`.
        ensure_installed = {
          "bashls",
          "biome",
          "docker_compose_language_service",
          "dockerls",
          "fish_lsp",
          "gh_actions_ls",
          -- TODO: See: https://github.com/LaBatata101/sith-language-server
          "jedi_language_server",
          "lua_ls",
          "postgres_lsp",
          "ruff",
          "rust_analyzer",
        },
        -- Automatically call `vim.lsp.enable("...")` on the LSPs.
        -- See the LSP section for configuration.
        automatic_enable = true,
      },
      dependencies = {
        { "mason-org/mason.nvim", opts = {} },
        "neovim/nvim-lspconfig",
      },
    },

    -- Still needed for LSP linkage wizardry. LSPs don't work without
    -- as of Neovim 0.11.1.
    { "neovim/nvim-lspconfig" },

    -- Auto-completion, inlay hints and method signatures.
    {
      "saghen/blink.cmp",

      dependencies = { "saghen/blink.compat" },

      -- use a release tag to download pre-built binaries
      version = "1.*",

      ---@module "blink.cmp"
      ---@type blink.cmp.Config
      opts = {
        -- "default" (recommended) for mappings similar to built-in completions (C-y to accept)
        -- "super-tab" for mappings similar to vscode (tab to accept)
        -- "enter" for enter to accept
        -- "none" for no mappings
        --
        -- All presets have the following mappings (vim.keymap.set):
        -- C-space: Open menu or open docs if already open
        -- C-n/C-p or Up/Down: Select next/previous item
        -- C-f/C-b: Scroll documentation down/up.
        -- C-e: Hide menu
        -- C-k: Toggle signature help (if signature.enabled = true)
        --
        -- See :h blink-cmp-config-keymap for defining your own keymap
        keymap = {
          preset = "default",
          -- With `Enter` to accept completions you can't add a
          -- line-break without accepting a completion.
          -- ["<CR>"] = { "accept", "fallback" },
          ["<Tab>"] = { "accept", "fallback" },
          ["<C-w>"] = { "show", "show_documentation", "hide_documentation", "fallback" }, -- Remap `<C-Space>`, taken by macOS.
        },

        appearance = {
          -- "mono" (default) for "Nerd Font Mono" or "normal" for "Nerd Font"
          -- Adjusts spacing to ensure icons are aligned
          nerd_font_variant = "mono",
        },

        completion = {
          -- (Default) Only show the documentation popup when manually triggered
          documentation = { auto_show = false },
          -- Greyed-out preview of the completion.
          ghost_text = { enabled = true },
        },

        -- Default list of enabled providers defined so that you can extend it
        -- elsewhere in your config, without redefining it, due to `opts_extend`
        sources = {
          default = { "lsp", "path", "snippets", "buffer" },

          -- For Dbee, see https://github.com/MattiasMTS/cmp-dbee/issues/29
          per_filetype = {
            -- Dbee
            sql = { "dbee", "buffer" }, -- Add any other source to include here
          },
          providers = {
            dbee = { name = "cmp-dbee", module = "blink.compat.source" },
          },
        },

        -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
        -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
        -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
        --
        -- See the fuzzy documentation for more information
        fuzzy = { implementation = "prefer_rust_with_warning" },
      },
      opts_extend = { "sources.default" },
    },
    -- Compatibility with `nvim-cmp` plugins.
    {
      "saghen/blink.compat",
      -- use v2.* for blink.cmp v1.*
      version = "2.*",
      -- lazy.nvim will automatically load the plugin when it's required by blink.cmp
      lazy = true,
      -- make sure to set opts so that lazy.nvim calls blink.compat's setup
      opts = {},
    },

    -- Rust.
    --
    -- Features:
    --  - Auto-integration with the Cargo syntax checker.
    --
    -- Commands:
    --  - `:RustTest` Run test under cursor.
    {
      "rust-lang/rust.vim",
      ft = { "rust" },
      config = function()
        -- Explicitly disable format-on-save.
        vim.g.rustfmt_autosave = 0
      end,
    },
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

--- LSP ---

-- Configure language servers.

-- Those LSPs are installed via Mason. We use the `mason-lspconfig`
-- plugin to install and enable them automatically.

-- Lua + Neovim API integration.
vim.lsp.config("lua_ls", {
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if
        path ~= vim.fn.stdpath("config")
        and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
      then
        return
      end
    end

    client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
      runtime = {
        -- Tell the language server which version of Lua you're using (most
        -- likely LuaJIT in the case of Neovim)
        version = "LuaJIT",
        -- Tell the language server how to find Lua modules same way as Neovim
        -- (see `:h lua-module-load`)
        path = {
          "lua/?.lua",
          "lua/?/init.lua",
        },
      },
      -- Make the server aware of Neovim runtime files
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
          -- Depending on the usage, you might want to add additional paths
          -- here.
          -- '${3rd}/luv/library'
          -- '${3rd}/busted/library'
        },
        -- Or pull in all of 'runtimepath'.
        -- Note: this is a lot slower and will cause issues when working on
        -- your own configuration.
        -- See https://github.com/neovim/nvim-lspconfig/issues/3189
        -- library = {
        --   vim.api.nvim_get_runtime_file('', true),
        -- }
      },
    })
  end,
  settings = {
    Lua = {},
  },
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    -- Buffer local mappings.
    local opts = { buffer = ev.buf }

    vim.keymap.set("n", "<Leader>d", function()
      vim.diagnostic.open_float()
    end, opts)

    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<Leader>f", function()
      vim.lsp.buf.format({ async = true })
    end, opts)

    local client = vim.lsp.get_client_by_id(ev.data.client_id)

    -- Inlay type and parameter hints.
    vim.lsp.inlay_hint.enable(false) -- Disabled by default, they're noisy.
    vim.keymap.set("n", "<Leader>h", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
    end)
  end,
})

-- Disable all LSP semantic highlights (in favor of Treesitter).
for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
  vim.api.nvim_set_hl(0, group, {})
end
