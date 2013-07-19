syntax on filetype plugin on
let mapleader = ","

set hlsearch
set incsearch
set smartcase
nnoremap <Leader>h :nohlsearch<cr>

set number
set noswapfile
set ruler
set expandtab
set shiftwidth=2
set tabstop=2
set autoindent
set pastetoggle=<Leader>pa

highlight Pmenu ctermfg=black ctermbg=gray
highlight StatusLine ctermfg=blue ctermbg=yellow

execute pathogen#infect()

:command! -nargs=* -complete=shellcmd RIW bot new | setlocal buftype=nofile bufhidden=hide noswapfile | silent r !<args>

autocmd BufRead,BufNewFile *.md,*.markdown setlocal spell
autocmd BufRead,BufNewFile *.md,*.markdown setlocal textwidth=80

hi SpellBad term=reverse cterm=underline ctermbg=1 gui=undercurl guisp=Red

function! RunCurrentTestFile()
  if InTestFile()
    execute ":w"
    let  l:command = "~/.functions/rspec " . @%
    call SetLastTestCommand(l:command)
    call RunTests(l:command)
    execute ":0"
  endif
endfunction

function! InTestFile()
  return match(expand("%"), '_test.rb$\|_spec.rb$') != -1
endfunction

function! SetLastTestCommand(command)
  let t:last_test_command = a:command
endfunction

function! RunTests(command)
  execute ":RIW echo " . a:command . " && echo && " . a:command
endfunction

" Switch between last two files
nnoremap <leader><leader> <c-^>

" Open paste mode, paste in current line at proper level of indent, and close
" paste mode
map <Leader>p :set paste<CR>o<esc>:r !pbpaste<CR>:set nopaste<CR>

"comment (cc) and uncomment (cu) Ruby code
noremap   <silent> cc      :s,^\(\s*\)[^# \t]\@=,\1# ,e<CR>:nohls<CR>zvj
noremap   <silent> cu      :s,^\(\s*\)# \s\@!,\1,e<CR>:nohls<CR>zvj

map <Leader>e :Explore<CR>
map <Leader>q :q<CR>
map <Leader>t :call RunCurrentTestFile()<CR>
map <Leader>sn :set number<CR>
map <Leader>nn :set nonumber<CR>
map <Leader>srn :set relativenumber<CR>
map <Leader>nrn :set relativenumber<CR>

" Remove White Space from ends of lines
map <Leader>rws :%s/\s\+$//g<CR>

map <Leader>n :tabn<CR>
map <Leader>b :tabp<CR>

" Open up a vsplit of ~/.vimrc and then source it
nnoremap <Leader>ev :vsplit $MYVIMRC<cr>
nnoremap <Leader>sv :source $MYVIMRC<cr>

" Exit with jk
inoremap jk <esc>
vnoremap jk <esc>

" Ruby - Convert String To Symbol
nnoremap <Leader>cs m`bhr:wwx``

" Don't wait so long for the next keypress (particularly in ambigious Leader
" situations.
set timeoutlen=300

" Window split settings from Pat Brisdin ( @thoughtbot )
set winwidth=84
set winheight=5
set winminheight=5
set winheight=999

augroup secretarygroup
  autocmd!
  autocmd BufRead,BufNewFile ~/.secretary* set filetype=secretary
  autocmd BufWritePost ~/.secretary-* execute '! timesheet --parse'
augroup END

" Set statusline
set laststatus=2
set statusline=%F%m%r%h%w\
set statusline+=%{fugitive#statusline()}\
set statusline+=[%{strlen(&fenc)?&fenc:&enc}]
set statusline+=\ [line\ %l\/%L]
