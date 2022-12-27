" sudo apt-get install -y vim vim-nox vim-gtk3
filetype plugin indent on
syntax on
set number
colorscheme desert
set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab
:set autoindent
:set cindent

" From https://opensource.com/article/20/2/how-install-vim-plugins
" curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
" https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
" :PlugInstall
call plug#begin()
Plug 'preservim/NERDTree'
Plug 'shougo/neocomplete.vim'
call plug#end()

" ctrl + n for nerdtree
nnoremap <C-n> :NERDTreeToggle<CR>

" tab for autocompletion
let g:neocomplete#enable_at_startup = 1
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
