" autocdls.vim
"   Do ls after cd automatically.
" Author:  b4b4r07
" Version: 0.1.0
" License: MIT

if exists("g:loaded_autocdls")
  finish
endif
let g:loaded_autocdls = 1

let s:save_cpo = &cpo
set cpo&vim

" Global variables
if !exists('g:auto_ls_enabled')
  let g:auto_ls_enabled = 1
endif

if !exists('g:autocdls_record_cdhist')
  let g:autocdls_record_cdhist = 0
endif

if !exists('g:autocdls_set_cmdheight')
  let g:autocdls_set_cmdheight = &cmdheight
endif

if exists('g:autocdls_set_cmdheight')
  let &cmdheight=g:autocdls_set_cmdheight
endif

if !exists('g:autocdls_show_filecounter')
  let g:autocdls_show_filecounter = 1
endif

if !exists('g:autocdls_show_pwd')
  let g:autocdls_show_pwd = 0
endif

if !exists('g:autocdls_swaping_capital')
  let g:autocdls_swaping_capital = 1
endif

if g:autocdls_swaping_capital != 0
  let s:alter_letter_entries = []

  function! s:alter_letter_add(original_pattern, alternate_name)
    call add(s:alter_letter_entries, [a:original_pattern, a:alternate_name])
  endfunction
  cnoremap <expr> <Space> <SID>alter_letter()

  function! s:alter_letter()
    let cmdline = getcmdline()
    for [original_pattern, alternate_name] in s:alter_letter_entries
      if cmdline =~# original_pattern
        return "\<C-u>" . alternate_name . substitute(cmdline, original_pattern, '', 'g') . " "
      endif
    endfor
    return ' '
  endfunction

  call s:alter_letter_add('^ls!', 'Ls!')
  call s:alter_letter_add('^ls', 'Ls')
endif

" Automatically ls after cd in Vim
function! s:auto_cdls()
  if g:autocdls_swaping_capital != 0
    let cmdline = getcmdline()
    for [original_pattern, alternate_name] in s:alter_letter_entries
      if cmdline =~# original_pattern
        return "\<C-u>" . alternate_name . "\<CR>"
      endif
    endfor
  endif

  " Support cd, lcd and chdir
  if getcmdtype() == ':' && getcmdline() =~# '^cd\|^chd\%\[ir\]\|^lcd\?'
    " Only real path
  let l:raw_path = substitute(getcmdline(),'\(^cd\|^chd\%\[ir\]\|^lcd\?\)\s*', '', 'g')

  if g:autocdls_record_cdhist == 1
    let s:hist_file = expand('~/.vim/history')
    execute ":redir! >>" . s:hist_file
      echo s:get_list(fnamemodify(l:raw_path, ":p"),'')
      redir END
    endif

    redraw
    " Same result
    "return empty(l:raw_path) ? "\<CR>" . s:get_list($HOME,'') : "\<CR>" . s:get_list(fnamemodify(l:raw_path, ":p"),'')
    return "\<CR>" . string(empty(l:raw_path) ? s:get_list($HOME,'') : s:get_list(fnamemodify(l:raw_path, ":p"),''))
  endif
  return "\<CR>"
endfunction

" Get the file list
function! s:get_list(path,bang)
  let l:pwd = getcwd()
  let l:bang = a:bang

  " Argmrnt of ':Ls'
  if empty(a:path)
    let l:path = getcwd()
  else
    let l:path = substitute(expand(a:path), '/$', '', 'g')
    " Failure to get the file list
    if !isdirectory(l:path)
      echohl ErrorMsg
      echo l:path ": No such file or directory"
      echohl NONE
      return
    endif
    " If the given path exist, cd to it
    execute ":cd " . expand(l:path)
  endif

  " Get the file list, accutually
  let filelist = glob(getcwd() . "/*")

  " Go to $OLDPWD
  execute ":lcd " . expand(l:pwd)
  if empty(filelist)
    echo "no file"
    return
  endif

  let s:count = 0
  let lists = ''
  for file in split(filelist, "\n")
    " Add '/' to tail of the file name if it is directory
    let s:count += 1
    if isdirectory(file)
      let lists .= fnamemodify(file, ":t") . "/" . " "
    else
      let lists .= fnamemodify(file, ":t") . " "
    endif
  endfor

  if g:autocdls_show_pwd != 0
    highlight Pwd cterm=NONE ctermfg=white ctermbg=black gui=NONE guifg=white guibg=black
    echohl Pwd | echon substitute(l:path, $HOME, '~', 'g') | echohl NONE
    echon "\: "
  endif

  if g:autocdls_show_filecounter != 0
    highlight FileCounter cterm=NONE ctermfg=red ctermbg=black gui=NONE guifg=red guibg=black
    echohl FileCounter | echon s:count | echohl NONE
    echon "\: "
  endif

  if g:autocdls_show_filecounter != 0 || g:autocdls_show_pwd != 0
    echon "   "
  endif

  if empty(l:bang)
    echon lists
  else
    echo tr(substitute(lists,' $','','g'), " ", "\n")
  endif
endfunction

augroup autocdls-auto-cd
  autocmd!
  autocmd BufEnter * execute ":lcd " . expand("%:p:h")
augroup END

if g:auto_ls_enabled == 1
  cnoremap <expr> <CR> <SID>auto_cdls()
endif

nnoremap <silent> <Plug>(autocdls-dols) :<C-u>call <SID>get_list(getcwd(),'')<CR>
command! -nargs=? -bar -bang -complete=dir Ls call s:get_list(<q-args>,<q-bang>)

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ft=vim ts=2 sw=2 sts=2:
