syntax on

set ts=4 sw=4
set ai cindent
set cinkeys-=0#
filetype plugin indent on

colorscheme koehler
hi PmenuSel ctermbg=DarkRed

set ruler
set number
set scrolloff=3
set wildmenu
set wildmode=list:full
set backspace=indent,eol,start
set laststatus=2
" Always show tabline
set showtabline=2
" :vsp opens new window on right
set splitright

autocmd BufEnter * silent! lcd %:p:h
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

autocmd FileType sql set commentstring=--\ %s

:command! -nargs=1 Space set ts=<args> sw=<args> et
:command! -nargs=1 Tab set ts=<args> sw=<args> noet

set list
set listchars=tab:\|>

" send the deleted character to the black hole register not the default one
nnoremap x "_x
nnoremap <del> "_x

let mapleader = ","
" revisual text that just got pasted
nnoremap <leader>v V`]
" Switch between header and cpp files
map <leader>m :e %:p:s,.h$,.X123X,:s,.cpp$,.h,:s,.X123X$,.cpp,<CR>
map <leader>n :vsp %:p:s,.h$,.X123X,:s,.cpp$,.h,:s,.X123X$,.cpp,<CR>

map <ESC>OA <C-y>
map <ESC>OB <C-e>

map <CR> i<CR><Esc>l
map <Space> i <Esc>l

function! CloseSomething()
  if winnr("$") == 1 && tabpagenr("$") > 1 && tabpagenr() > 1 && tabpagenr() < tabpagenr("$")
    try | tabclose | endtry
    tabprev
  else
    q
  endif
endfunction

cabbrev <expr> q ((getcmdtype() == ':' && getcmdpos() <= 2)? 'call CloseSomething()' : 'q')

" Reload the file to reflect the permissions change
function! P4Revert()
    !p4 revert %
    e
endfunction
function! P4Edit()
    !p4 edit %
    e
endfunction

" edit, revert, etc the current file
cabbrev <expr> p4e 'call P4Edit()'
cabbrev <expr> p4r 'call P4Revert()'
cabbrev <expr> p4d '!p4 diff %'

function! MoveToCurrentTab(tabnum)
  let l:tab_nr = tabpagenr()
  " When we close the tab, the current tab number will shift down
  if a:tabnum < l:tab_nr
    let l:tab_nr -= 1
  endif

  exe "tabnext" a:tabnum
  let l:cur_buf = bufnr('%')
  close!
  exe "tabnext" l:tab_nr
  vsp
  exe "b".l:cur_buf
endfunc

function! MoveToSeparateTab()
  if winnr('$') < 2
    return
  endif

  let l:cur_buf = bufnr('%')
  close!
  tabnew
  exe "b".l:cur_buf
endfunc

:command! -nargs=1 TabIn call MoveToCurrentTab(<args>)
:command! TabOut call MoveToSeparateTab()

" Search for selected text, forwards or backwards.
vnoremap <silent> * :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy/<C-R><C-R>=substitute(
  \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gV:call setreg('"', old_reg, old_regtype)<CR>
vnoremap <silent> # :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy?<C-R><C-R>=substitute(
  \escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gV:call setreg('"', old_reg, old_regtype)<CR>

command! -complete=shellcmd -nargs=+ Shell call s:RunShellCommand(<q-args>)
function! s:RunShellCommand(cmdline)
  let isfirst = 1
  let words = []
  for word in split(a:cmdline)
    if isfirst
      let isfirst = 0  " don't change first word (shell command)
    else
      if word[0] =~ '\v[%#<]'
        let word = expand(word)
      endif
      let word = shellescape(word, 1)
    endif
    call add(words, word)
  endfor
  let expanded_cmdline = join(words)
  vertical new
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
  call setline(1, 'You entered:  ' . a:cmdline)
  call setline(2, 'Expanded to:  ' . expanded_cmdline)
  call append(line('$'), substitute(getline(2), '.', '=', 'g'))
  silent execute '$read !'. expanded_cmdline
  1
endfunction

function! Wipeout()
  " list of *all* buffer numbers
  let l:buffers = range(1, bufnr('$'))

  " what tab page are we in?
  let l:currentTab = tabpagenr()
  try
    " go through all tab pages
    let l:tab = 0
    while l:tab < tabpagenr('$')
      let l:tab += 1

      " go through all windows
      let l:win = 0
      while l:win < winnr('$')
        let l:win += 1
        " whatever buffer is in this window in this tab, remove it from
        " l:buffers list
        let l:thisbuf = winbufnr(l:win)
        call remove(l:buffers, index(l:buffers, l:thisbuf))
      endwhile
    endwhile

    " if there are any buffers left, delete them
    if len(l:buffers)
      execute 'bwipeout' join(l:buffers)
    endif
  finally
    " go back to our original tab page
    execute 'tabnext' l:currentTab
  endtry
endfunction

:command! Wipe call Wipeout()

