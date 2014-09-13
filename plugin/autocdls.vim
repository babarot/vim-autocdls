" autocdls.vim
"   Automatically ls after cd in Vim.
" Author:  b4b4r07
" Version: 1.0
" License: MIT

if exists("g:loaded_autocdls")
  finish
endif
let g:loaded_autocdls = 1

let s:save_cpo = &cpo
set cpo&vim

let g:autocdls_autols_enabled = get(g:, 'autocdls_autols_enabled', 1)
if empty(maparg('<CR>', 'c')) && g:autocdls_autols_enabled
  cnoremap <expr> <CR> autocdls#ls_after_cd()
endif

command! -nargs=? -bar -bang -complete=file Ls call autocdls#get_list(<q-args>, <q-bang>, 2)
command! -nargs=1 -bar -bang -complete=dir LsGrep call autocdls#ls_grep(<q-args>, <q-bang>)

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et fdm=marker ft=vim ts=2 sw=2 sts=2:
