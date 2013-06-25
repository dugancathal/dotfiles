syntax on
filetype plugin on
let mapleader = ","

set hlsearch
set ignorecase
set incsearch
set number

set noswapfile
set ruler
set expandtab
set shiftwidth=2
set tabstop=2
set autoindent
set pastetoggle=<Leader>pa

highlight Pmenu ctermfg=black ctermbg=gray

execute pathogen#infect()

"comment (cc) and uncomment (cu) Ruby code 
noremap   <silent> cc      :s,^\(\s*\)[^# \t]\@=,\1# ,e<CR>:nohls<CR>zvj
noremap   <silent> cu      :s,^\(\s*\)# \s\@!,\1,e<CR>:nohls<CR>zvj

:command! -nargs=* -complete=shellcmd RIW bot new | setlocal buftype=nofile bufhidden=hide noswapfile | silent r !<args>
au BufRead,BufNewFile *.md setlocal spell
au BufRead,BufNewFile *.md setlocal textwidth=80

hi SpellBad term=reverse cterm=underline ctermbg=1 gui=undercurl guisp=Red

map <Leader>e :Explore<CR>
map <Leader>t :call RunCurrentTestFile()<CR>
map <Leader>q :q<CR>

" Remove White Space from ends of lines
map <Leader>rws :%s/\s\+$//g<CR>

map <Leader>n :tabn<CR>
map <Leader>b :tabp<CR>

" Open up a vsplit of ~/.vimrc and then source it
nnoremap <Leader>ev :vsplit $MYVIMRC<cr>
nnoremap <Leader>sv :source $MYVIMRC<cr>

" Exit with jk
inoremap jk <esc>

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


" Tab completion
" will insert tab at beginning of line,
" will use completion if not at beginning
set wildmode=list:longest,list:full
set complete=.,w,t
function! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    else
        return "\<c-p>"
    endif
endfunction
inoremap <Tab> <c-r>=InsertTabWrapper()<cr>

" Switch between last two files
nnoremap <leader><leader> <c-^>
