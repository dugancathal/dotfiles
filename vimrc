syntax on
filetype indent plugin on
let mapleader = ","

set hlsearch
set incsearch
set smartcase
set nocompatible
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
runtime macros/matchit.vim

:command! -nargs=* -complete=shellcmd RIW bot new | setlocal buftype=nofile bufhidden=hide noswapfile | silent r !<args>

autocmd BufRead,BufNewFile *.md,*.markdown setlocal spell
autocmd BufRead,BufNewFile *.md,*.markdown setlocal textwidth=80
autocmd BufRead,BufNewFile *.go set filetype=go

hi SpellBad term=reverse cterm=underline ctermbg=1 gui=undercurl guisp=Red

function! RunCurrentTestFile()
  if InTestFile()
    execute ":w"

    if glob('test/test_helper.rb') > "\n"
      let l:command = 'rake TEST=' . @%
    elseif glob('spec/spec_helper.rb') > "\n"
      let  l:command = "rspec " . @%
    else
      let l:command = "ruby " . @%
    end

    if glob('.zeus.sock') > "\n"
      let l:command = "zeus " . l:command
    endif

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
map <Leader>so :w<CR>:so %<CR>
map <Leader>x :exec getline(".")<CR>

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

" Turn some lines into a single line, separated by spaces
vmap <Leader>toc :s/,.*//g<cr>
vmap <Leader>ac :s/,\?$/,/<cr>
vmap <Leader>aoc :Tabularize / :/l0r0l0<cr>
vmap <Leader>sl :s/\s*\n/ /g<cr>$

" Ruby - Convert String To Symbol
nnoremap <Leader>cs m`bhr:wwx``
nnoremap <Leader>sc m`bhr"wea"<ESC>``

" Don't wait so long for the next keypress (particularly in ambigious Leader
" situations.
set timeoutlen=300

" Window split settings from Pat Brisdin ( @thoughtbot )
set winwidth=84
set winheight=10
set winminheight=10
set winheight=50

augroup secretarygroup
  autocmd!
  autocmd BufRead,BufNewFile ~/.secretary* set filetype=secretary
  autocmd BufWritePost ~/.secretary-* execute '! timesheet --parse'
augroup END

augroup rubypath
  autocmd!
  autocmd FileType ruby setlocal suffixesadd+=.rb
augroup END

augroup golang
  autocmd!
  autocmd FileType go setlocal tabstop=4
  autocmd FileType go setlocal shiftwidth=4
  autocmd FileType go setlocal noexpandtab
augroup END

" Set statusline
set laststatus=2
set statusline=%F%m%r%h%w
set statusline+=\ %{fugitive#statusline()}
set statusline+=[%{strlen(&fenc)?&fenc:&enc}]
set statusline+=\ [line\ %l\/%L]
set statusline+=\ [col\ %c]

" More natural splits
set splitbelow
set splitright
