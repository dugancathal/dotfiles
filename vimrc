:source $VIMRUNTIME/defaults.vim

" Open a notes file (in `tmp/notes.md`) with 'no+ENTER' - will return to the
" tab if it already exists
nmap no<CR> :tab drop tmp/notes.md<CR>
nmap n<CR> :tab drop $HOME/workspace/bujo/today/notes.md<CR>

autocmd FileType markdown setlocal ts=2 sts=2 sw=2 expandtab
