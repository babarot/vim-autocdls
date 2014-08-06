" autocdls.vim
"   Do ls after cd automatically.
" Author:  b4b4r07
" Version: 0.1.2
" License: MIT

let s:save_cpo = &cpo
set cpo&vim

" Global variables {{{
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

if !exists('g:autocdls_alter_letter')
  let g:autocdls_alter_letter = 1
  let s:alter_letter_entries = []
endif

if !exists('g:autocdls_newline_disp')
  let g:autocdls_newline_disp = 0
endif
"}}}

function! autocdls#alter_letter_add(original_pattern, alternate_name) "{{{
  call add(s:alter_letter_entries, [a:original_pattern, a:alternate_name])
endfunction "}}}

function! autocdls#alter_letter() "{{{
  let cmdline = getcmdline()
  for [original_pattern, alternate_name] in s:alter_letter_entries
    if cmdline =~# original_pattern
      return "\<C-u>" . alternate_name . substitute(cmdline, original_pattern, '', 'g') . " "
    endif
  endfor
  return ' '
endfunction "}}}

" Automatically ls after cd in Vim
function! autocdls#auto_cdls() "{{{
  if g:autocdls_alter_letter == 1
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
    let l:raw_path = substitute(getcmdline(), '\(^cd\|^chd\%\[ir\]\|^lcd\?\)\s*', '', 'g')

    if g:autocdls_record_cdhist == 1
      let s:hist_file = expand('~/.vim/history')
      execute ":redir! >>" . s:hist_file
      echo autocdls#get_list(fnamemodify(l:raw_path, ":p"), '', '')
      redir END
    endif

    redraw
    return empty(l:raw_path) ? "\<CR>" . autocdls#get_list($HOME, '', 'many') : "\<CR>" . autocdls#get_list(fnamemodify(l:raw_path, ":p"), '', 'many')
  else
    return "\<CR>"
  endif
endfunction "}}}

" Get the file list
function! autocdls#get_list(path, bang, option) "{{{
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
  endif

  " Get the file list, accutually
  let l:filelist = glob(l:path . "/*")
  if !empty(a:bang)
    let l:filelist .= glob(l:path . "/.??*")
  endif

  if empty(filelist)
    echo "no file"
    return
  endif

  let s:count = 0
  let s:lists = ''
  for file in split(l:filelist, "\n")
    " Add '/' to tail of the file name if it is directory
    let s:count += 1
    if isdirectory(file)
      let s:lists .= fnamemodify(file, ":t") . "/" . " "
    else
      let s:lists .= fnamemodify(file, ":t") . " "
    endif
  endfor

  if a:option == 'return'
    return s:lists
  endif

  if g:autocdls_show_pwd != 0 "{{{
    highlight Pwd cterm=NONE ctermfg=white ctermbg=black gui=NONE guifg=white guibg=black
    echohl Pwd | echon substitute(l:path, $HOME, '~', 'g') | echohl NONE
    echon "\: "
  endif "}}}

  if g:autocdls_show_filecounter != 0 "{{{
    highlight FileCounter cterm=NONE ctermfg=red ctermbg=black gui=NONE guifg=red guibg=black
    echohl FileCounter | echon s:count | echohl NONE
    echon "\: "
  endif "}}}

  if g:autocdls_show_filecounter != 0 || g:autocdls_show_pwd != 0 "{{{
    echon "\t"
  endif "}}}

  if a:option == 'many'
    if strlen(s:lists) > &columns * &cmdheight
      echohl WarningMsg
      echo s:count . ': too many files'
      echohl NONE
      return
    endif
  else
    if g:autocdls_newline_disp == 1
      echo tr(substitute(s:lists, ' $', '', 'g'), " ", "\n")
    endif
  endif
  echon s:lists
endfunction "}}}

" Search the file or directory like grep
function! autocdls#ls_grep(pattern, bang) "{{{
  if empty(a:pattern)
    echohl WarningMsg
    echon 'no arg'
    echohl NONE
    return
  elseif a:pattern == 1
    let l:pattern = input('grep word: ')
  else
    let l:pattern = a:pattern
  endif

  let s:list_lists = []
  let l:filelist = autocdls#get_list(getcwd(), '', 'return')
  if !empty(a:bang)
    let l:filelist .= autocdls#get_list(getcwd(), '!' ,'return')
  endif

  for separated in split(l:filelist, ' ')
    call add(s:list_lists, separated)
  endfor

  let l:n = 0
  let l:flag = 0
  redraw
  while l:n < len(s:list_lists)
    if stridx(s:list_lists[n], l:pattern) != -1
      let l:flag = 1
      echon s:list_lists[l:n] . ' '
    endif
    let l:n += 1
  endwhile

  if l:flag == 0
    echohl WarningMsg
    echon 'no match'
    echohl NONE
  endif
endfunction "}}}

if g:autocdls_alter_letter == 1
  cnoremap <expr> <Space> autocdls#alter_letter()
  call autocdls#alter_letter_add('^ls!', 'Ls!')
  call autocdls#alter_letter_add('^ls', 'Ls')
endif

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et fdm=marker ft=vim ts=2 sw=2 sts=2:
