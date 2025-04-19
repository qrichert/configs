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

    -- Markdown preview.
    --
    --  Commands:
    --   - `:LivePreview start`
    {
      "brianhuster/live-preview.nvim",
      dependencies = {
        "ibhagwan/fzf-lua",
      },
    },

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

    -- TODO: Try: oil.nvim (edit your filesystem like a buffer)
    -- https://www.youtube.com/watch?v=-r1mMg-yVZE

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
            "html",
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
            "javadoc",
            "javascript",
            "typescript",
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
              local max_filesize = 100 * 1024 -- 100 KB
              local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
              if ok and stats and stats.size > max_filesize then
                return true
              end
            end,

            -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
            -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
            -- Using this option may slow down your editor, and you may see some duplicate highlights.
            -- Instead of true it can also be a list of languages
            additional_vim_regex_highlighting = false,
          },
        })
      end,
    },

    --- LSP ---

    -- TODO: https://github.com/neovim/nvim-lspconfig/issues/3494
    {
      "neovim/nvim-lspconfig",
      config = function()
        -- Setup language servers.
        local lspconfig = require("lspconfig")

        -- Rust.
        --
        -- ```
        -- rustup component add rust-analyzer
        -- ```
        --
        --  Commands:
        --   - `:CargoReload`
        lspconfig.rust_analyzer.setup({
          -- settings = {
          --   ["rust-analyzer"] = {
          --     cargo = {}
          --   }
          -- }
        })

        -- Python.
        --
        -- ```
        -- uv tool install ruff@latest
        -- pipx install jedi-language-server
        -- ```
        lspconfig.ruff.setup({
          -- init_options = {
          --   settings = {
          --     -- Server settings should go here.
          --   }
          -- }
        })
        lspconfig.jedi_language_server.setup({})

        vim.api.nvim_create_autocmd("LspAttach", {
          group = vim.api.nvim_create_augroup("UserLspConfig", {}),
          callback = function(ev)
            -- Buffer local mappings.
            local opts = { buffer = ev.buf }

            vim.keymap.set("n", "<Leader>d", function()
              vim.diagnostic.open_float()
            end, opts)

            -- TODO: Use the defaults and add the to `Vim.md`.
            -- https://neovim.io/doc/user/news-0.11.html#_defaults
            -- grn in Normal mode maps to vim.lsp.buf.rename()
            -- grr in Normal mode maps to vim.lsp.buf.references()
            -- gri in Normal mode maps to vim.lsp.buf.implementation()
            -- gO in Normal mode maps to vim.lsp.buf.document_symbol()
            -- gra in Normal and Visual mode maps to vim.lsp.buf.code_action()
            -- CTRL-S in Insert and Select mode maps to vim.lsp.buf.signature_help()
            -- Mouse popup-menu includes an "Open in web browser" item when you right-click on a URL.
            -- Mouse popup-menu includes a "Go to definition" item when LSP is active in the buffer.
            -- Mouse popup-menu includes "Show Diagnostics", "Show All Diagnostics" and "Configure Diagnostics" items when there are diagnostics in the buffer.
            vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
            vim.keymap.set("n", "<Leader>r", vim.lsp.buf.rename, opts)
            vim.keymap.set({ "n", "v" }, "<Leader>a", vim.lsp.buf.code_action, opts)
            vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
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
      end,
    },

    -- Auto-completion, inlay hints and method signatures.
    {
      "saghen/blink.cmp",

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

    -- TODO: Keep nvim-cmp config around for now, even tho we replaced it
    -- by blink.cmp. But i want the blink-cmp thing to be another commit
    -- to keep this in history. Rebases would be too painful if I did it
    -- now.
    -- {
    --   "hrsh7th/nvim-cmp",
    --   -- load cmp on InsertEnter
    --   event = "InsertEnter",
    --   -- these dependencies will only be loaded when cmp loads
    --   -- dependencies are always lazy-loaded unless specified otherwise
    --   dependencies = {
    --     "neovim/nvim-lspconfig",
    --     "hrsh7th/cmp-nvim-lsp",
    --     "hrsh7th/cmp-buffer",
    --     "hrsh7th/cmp-path",
    --   },
    --   config = function()
    --     local cmp = require("cmp")
    --
    --     cmp.setup({
    --       mapping = cmp.mapping.preset.insert({
    --         ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    --         ["<C-f>"] = cmp.mapping.scroll_docs(4),
    --         ["<C-w>"] = cmp.mapping.complete(), -- `<C-Space>` is taken by macOS.
    --         ["<C-e>"] = cmp.mapping.abort(),
    --         -- Accept currently selected item.
    --         ["<CR>"] = cmp.mapping.confirm({ select = true }),
    --       }),
    --
    --       sources = cmp.config.sources({
    --         { name = "nvim_lsp" },
    --       }, {
    --         { name = "path" },
    --       }),
    --
    --       experimental = {
    --         -- Greyed-out preview of the completion.
    --         ghost_text = true,
    --       },
    --     })
    --
    --     -- -- Enable completing paths in `:`.
    --     -- cmp.setup.cmdline(":", {
    --     --   sources = cmp.config.sources({
    --     --     { name = "path" }
    --     --   })
    --     -- })
    --
    --   end
    -- },

    -- TODO: blink.cmp does this too, same fate as nvim-cmp

    -- -- Inline function signatures.
    -- {
    --   "ray-x/lsp_signature.nvim",
    --   event = "VeryLazy",
    --   opts = {},
    --   config = function(_, opts)
    --     -- Get signatures (and _only_ signatures) when in argument lists.
    --     require "lsp_signature".setup({
    --       doc_lines = 0,
    --       handler_opts = {
    --         border = "none"
    --       },
    --     })
    --   end
    -- },

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

-- Disable all LSP semantic highlights (in favor of Treesitter).
for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
  vim.api.nvim_set_hl(0, group, {})
end
