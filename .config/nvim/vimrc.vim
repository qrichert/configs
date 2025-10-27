" Set space as leader.
nnoremap <SPACE> <Nop>
let mapleader="\<Space>"
let maplocalleader="\\"

syntax on                   " Turn on syntax highlighting.

set mouse=a                 " Enable mouse usage (all modes).
set clipboard^=unnamedplus  " Share system clipboard.

set number                  " Precede each line with its line number.
set relativenumber          " Show line numbers relative to cursor.
set cursorline              " Highlight current line.

set nowrap                  " Do not wrap long lines (scroll instead).
set scrolloff=5             " Minimum number of rows to keep around cursor.
set sidescrolloff=5         " Minimum number of columns to keep around cursor.

set splitbelow              " Open new panes at the bottom (e.g., terminal).
set splitright              " Open new panes on the right.

set autowrite               " Auto-save files before commands like `:!` or `:make`.
set autoread                " Auto-reload files if changed on disk.
set undofile                " Persist undo history across sessions (`~/.local/state/nvim/undo/`).

" Remove trailing whitespace and multiple newlines.
autocmd BufWritePre * :%s/\s\+$//e
autocmd BufWritePre * %s/\n\+\%$//e

set incsearch               " Show matches while typing.
set ignorecase              " Make search case insensitive.
set smartcase               " Override `ignorecase` if pattern contains uppercase letters.
set gdefault                " Global (`/g`) substitution by default.

set termguicolors           " Enable 24-bit RGB colors.

set colorcolumn=73,81       " Show ruler at columns.

set smartindent             " Do smart autoindenting when starting a new line.
set tabstop=4               " Use 4 spaces per tab.
set expandtab               " Convert tabs to spaces.
set shiftwidth=4            " Shift (`<<`, `>>`, `=`) by 4 spaces (breaks `.editorconfig` support).
set softtabstop=-1          " Pressing `<Tab>` matches indentation width (`shiftwidth`).

autocmd FileType json setlocal colorcolumn=81
autocmd FileType markdown,text setlocal textwidth=72 colorcolumn=73 nosmartindent
autocmd FileType python setlocal colorcolumn=73,89
autocmd FileType rust setlocal colorcolumn=73,101
autocmd FileType vim setlocal colorcolumn=73

" For some reason, `BufEnter` is the only event that works (without reload).
autocmd BufEnter *.html,*.css setlocal tabstop=2 shiftwidth=2
autocmd BufEnter *.js,*.jsx,*.ts,*.tsx setlocal tabstop=2 shiftwidth=2
autocmd BufEnter *.json setlocal tabstop=2 shiftwidth=2
autocmd BufEnter *.lua setlocal tabstop=2 shiftwidth=2
autocmd BufEnter *.md setlocal tabstop=2 shiftwidth=2
autocmd BufEnter *.yaml,*.yml setlocal tabstop=2 shiftwidth=2

" Leader mappings.
nnoremap <Leader><Leader> <C-^>
nnoremap <Leader>w <Cmd>w<CR>
nnoremap <Leader>q <Cmd>bp<Bar>sp<Bar>bn<Bar>bd<CR>
nnoremap <Leader>b <Cmd>windo set scrollbind! cursorbind!<CR>

" Quickfix mappings.
nnoremap <C-j> <Cmd>cnext<CR>
nnoremap <C-k> <Cmd>cprevious<CR>

" Convenience remappings.
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz

" Force the use of `hjkl`.
noremap <Left> <Nop>
noremap <Down> <Nop>
noremap <Up> <Nop>
noremap <Right> <Nop>
" noremap! <Left> <Nop>
" noremap! <Down> <Nop>
" noremap! <Up> <Nop>
" noremap! <Right> <Nop>

" Use `Ctrl` to move around in Insert or Command mode.
noremap! <C-h> <Left>
noremap! <C-j> <Down>
noremap! <C-k> <Up>
noremap! <C-l> <Right>

" Use left and right arrows to navigate and open buffers.
nnoremap <Left> <Cmd>bnext<CR>
nnoremap <Right> <Cmd>bprevious<CR>
nnoremap <Leader><Left> <Cmd>buffers<CR>
nnoremap <Leader><Right> <Cmd>Oil<CR>
" Use up and down arrows to navigate and create tabs.
nnoremap <Up> <Cmd>tabnext<CR>
nnoremap <Down> <Cmd>tabprevious<CR>
nnoremap <Leader><Up> <Cmd>tabnew<CR>
nnoremap <Leader><Down> <Cmd>tabs<CR>
