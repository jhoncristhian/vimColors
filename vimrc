" ~/.vimrc

set nocompatible
filetype plugin indent on
syntax enable

" Interfaz
set number
set cursorline
set ruler
set showcmd
set laststatus=2
set showmode
set title

" Búsqueda
set hlsearch
set incsearch
set ignorecase
set smartcase

" Indentación
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set autoindent
set smartindent

" Apariencia
set background=dark
set termguicolors
set t_Co=256

" Tema integrado similar al de la imagen
colorscheme desert

" Colores personalizados
highlight Normal       guifg=#d0d0d0 guibg=#202020
highlight CursorLine   guibg=#292929
highlight LineNr       guifg=#666666 guibg=#202020
highlight CursorLineNr guifg=#ffff00 guibg=#303030
highlight StatusLine   guifg=#ffffff guibg=#b91c1c
highlight StatusLineNC guifg=#aaaaaa guibg=#3a3a3a
highlight VertSplit    guifg=#555555 guibg=#202020

" Barra de estado
set statusline=
set statusline+=\ %f
set statusline+=\ %m
set statusline+=%=
set statusline+=\ %y
set statusline+=\ %l:%c
set statusline+=\ 

" Mostrar espacios y tabs de forma discreta
set list
set listchars=tab:▸\ ,trail:·

" Cargar automáticamente archivos C/C++
autocmd FileType c,cpp setlocal tabstop=4 shiftwidth=4 expandtab
autocmd FileType c,cpp setlocal commentstring=//\ %s

" Eliminar espacios al final de línea al guardar
autocmd BufWritePre *.c,*.h,*.cpp,*.hpp
      \ silent! %s/\s\+$//e
