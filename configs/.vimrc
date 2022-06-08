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
