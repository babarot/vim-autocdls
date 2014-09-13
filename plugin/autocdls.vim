" autocdls.vim
"   Do ls after cd automatically.
" Author:  b4b4r07
" Version: 0.1.2
" License: MIT

if exists("g:loaded_autocdls")
  finish
endif
let g:loaded_autocdls = 1

let s:save_cpo = &cpo
set cpo&vim

" Cd to its directory when opening the file
augroup autocdls-auto-cd
  autocmd!
  "autocmd BufEnter * execute ":lcd " . expand("%:p:h")
augroup END

let g:autocdls_autols#enable = get(g:, 'autocdls_autols#enable', 1)
if empty(maparg('<CR>', 'c')) && g:autocdls_autols#enable
  cnoremap <expr> <CR> autocdls#ls_after_cd()
endif

nnoremap <silent> <Plug>(autocdls-do-ls) :<C-u>call autocdls#get_list(getcwd(), '', '')<CR>
nnoremap <silent> <Plug>(autocdls-do-lsgrep) :<C-u>call autocdls#ls_grep(1, '')<CR>
command! -nargs=? -bar -bang -complete=file Ls call autocdls#get_list(<q-args>, <q-bang>, 2)
command! -nargs=1 -bar -bang -complete=dir LsGrep call autocdls#ls_grep(<q-args>, <q-bang>)

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et fdm=marker ft=vim ts=2 sw=2 sts=2:
