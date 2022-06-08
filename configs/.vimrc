set nocompatible
filetype off

" set Vim-specific sequences for RGB colors | enable true colors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
set termguicolors

" enable italics
set t_ZH=[3m
set t_ZR=[23m

filetype plugin indent on
syntax on
set tabstop=2
set shiftwidth=2
set expandtab
set relativenumber
set number
set autoindent
set ruler
set incsearch
set cursorline number
set laststatus=2
set noshowmode

" scrolloff defines how many lines above and below the active line
" should be shown. Setting this to a large value insures the active
" line is centered whenever possible
set scrolloff=999

"Let ctrl-j and ctrl-k move up and down like ctrl-u and ctrl-d
nnoremap <C-j> <C-d>
nnoremap <C-k> <C-u>
