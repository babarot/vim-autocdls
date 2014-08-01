" autocdls.vim
"   Do ls after cd automatically.
" Author:  b4b4r07
" Version: 0.1.0
" License: MIT

if exists("g:loaded_vimcdls")
  finish
endif
let g:loaded_vimcdls = 1

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

" Automatically ls after cd in Vim
function! s:auto_cdls()
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
  if !empty(a:path)
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

  let lists = ''
  for file in split(filelist, "\n")
    " Add '/' to tail of the file name if it is directory
    if isdirectory(file)
        let lists .= fnamemodify(file, ":t") . "/" . " "
    else
        let lists .= fnamemodify(file, ":t") . " "
    endif
  endfor
  " Go to $OLDPWD
  "execute ":lcd " . expand(l:pwd)

  if empty(l:bang)
    echo lists
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
