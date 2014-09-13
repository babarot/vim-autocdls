" autocdls.vim
"   Automatically ls after cd in Vim.
" Author:  b4b4r07
" Version: 1.0
" License: MIT

let s:save_cpo = &cpo
set cpo&vim

" Global variables {{{
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
endif

if !exists('g:autocdls_newline_disp')
  let g:autocdls_newline_disp = 0
endif

if !exists('g:autocdls_ls_highlight')
  let g:autocdls_ls_highlight = 1
endif

if !exists('g:autocdls_lsgrep_ignorecase')
  let g:autocdls_lsgrep_ignorecase = 1
endif
"}}}
" Capitalize automatically {{{
if g:autocdls_alter_letter == 1
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

  let s:alter_letter_entries = []
  call autocdls#alter_letter_add('^ls$',  'Ls')
  call autocdls#alter_letter_add('^ls!$', 'Ls!')
  cnoremap <expr> <Space> autocdls#alter_letter()
endif "}}}

function! autocdls#ls_after_cd() "{{{
  " Capitalize, if typting :ls and CR key only.
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
    let raw_path = substitute(getcmdline(), '\(^cd\|^chd\%\[ir\]\|^lcd\?\)\s*', '', 'g')
    redraw
    return empty(raw_path) ? "\<CR>" . autocdls#get_list($HOME, '') : "\<CR>" . autocdls#get_list(fnamemodify(raw_path, ":p"), '')
  else
    return "\<CR>"
  endif
endfunction "}}}
function! autocdls#get_path(path) "{{{
  let path = empty(a:path) ? getcwd() : substitute(expand(a:path), '/$', '', 'g')

  if path ==# '.'
    echo system("ls -dl " . shellescape(path) . '/')
    throw 'ls_result'
  else
    if filereadable(path)
      echo system("ls -l " . shellescape(path))
      throw 'ls_result'
    elseif isdirectory(path)
      return path
    elseif !isdirectory(path)
      throw path . ': No such file or directory'
    else
      throw 'autocdls: a fatal error'
    endif
  endif
endfunction "}}}
function! autocdls#get_list(path, bang, ...) "{{{
  try
    let path = autocdls#get_path(a:path)
  catch /^ls_result$/
    return
  catch /^autocdls:/
    errormsg v:exception
    return
  catch /:.*directory$/
    echohl ErrorMsg |echomsg v:exception |echohl None
    return
  endtry

  let save_ignore = &wildignore
  set wildignore=
  let filelist = glob(path . "/*")
  if !empty(a:bang)
    let filelist .= "\n" . glob(path . "/.??*")
  endif
  let &wildignore = save_ignore
  let filelist = substitute(filelist, '', '^M', 'g')

  if empty(filelist)
    echo "no file"
    return
  endif

  let s:lists = []
  for file in split(filelist, "\n")
    if isdirectory(file)
      call add(s:lists, fnamemodify(file, ":t") . "/")
    else
      if executable(file)
        call add(s:lists, fnamemodify(file, ":t") . "*")
      elseif getftype(file) == 'link'
        call add(s:lists, fnamemodify(file, ":t") . "@")
      else
        call add(s:lists, fnamemodify(file, ":t"))
      endif
    endif
  endfor

  " Use s:ls_grep
  if a:0 && a:1 == 1
    return s:lists
  endif

  if g:autocdls_show_pwd "{{{
    highlight Pwd cterm=NONE ctermfg=white ctermbg=black gui=NONE guifg=white guibg=black
    echohl Pwd | echon substitute(l:path, $HOME, '~', 'g') | echohl NONE
    echon "\: "
  endif "}}}
  if g:autocdls_show_filecounter "{{{
    highlight FileCounter cterm=NONE ctermfg=red ctermbg=black gui=NONE guifg=red guibg=black
    echohl FileCounter | echon len(s:lists) | echohl NONE
    echon "\: "
  endif "}}}
  if g:autocdls_show_filecounter || g:autocdls_show_pwd "{{{
    echon "\t"
  endif "}}}

  if a:0 == 0
    if strlen(join(s:lists)) > &columns * &cmdheight
      echohl WarningMsg
      echo len(s:lists) . ': too many files'
      echohl NONE
      return
    endif
  elseif a:0 && a:1 == 2
    if g:autocdls_newline_disp
      if g:autocdls_ls_highlight
        call autocdls#colorize(s:lists, g:autocdls_newline_disp)
      else
        echon "\n".join(s:lists, "\n")
      endif
      return
    endif
  endif

  if g:autocdls_ls_highlight
    call autocdls#colorize(s:lists)
  else
    echon join(s:lists)
  endif
endfunction "}}}
function! autocdls#colorize(list, ...) "{{{
  highlight LsDirectory  cterm=bold ctermfg=NONE ctermfg=26        gui=bold guifg=#0096FF   guibg=NONE
  highlight LsExecutable cterm=NONE ctermfg=NONE ctermfg=Green     gui=NONE guifg=Green     guibg=NONE
  highlight LsSymbolick  cterm=NONE ctermfg=NONE ctermfg=LightBlue gui=NONE guifg=LightBlue guibg=NONE

  if g:autocdls_ls_highlight == 0
    highlight LsDirectory  NONE
    highlight LsExecutable NONE
    highlight LsSymbolick  NONE
  endif

  "let sep = ' '
  "if a:0 "&& a:1 == g:autocdls_newline_disp
  "  let sep = g:autocdls_newline_disp ? "\n" : " "
  "endif
  let sep = a:0 && g:autocdls_newline_disp ? "\n" : " "
  if g:autocdls_newline_disp
    "echo sep
  endif

  for item in a:list
    if item =~ '/'
      echon sep
      echohl LsDirectory | echon item[:-2] | echohl NONE
      echon item[-1:-1]
      ". sep
    elseif item =~ '*'
      echon sep
      echohl LsExecutable | echon item[:-2] | echohl NONE
      echon item[-1:-1]
      ". sep
    elseif item =~ '@'
      echon sep
      echohl LsSymbolick | echon item[:-2] | echohl NONE
      echon item[-1:-1]
      ". sep
    else
      echon sep
      echon item 
      ". sep
    endif
  endfor
endfunction "}}}
function! autocdls#ls_grep(pattern, bang) "{{{
  if empty(a:pattern)
    echohl WarningMsg
    echon 'no arg'
    echohl NONE
    return
  elseif a:pattern
    let pattern = input('grep word: ')
  else
    let pattern = a:pattern
  endif

  redraw
  let list = autocdls#get_list(getcwd(), '', 1)
  if !empty(a:bang)
    call extend(list, autocdls#get_list(getcwd(), a:bang ,1), len(list))
  endif

  let lists = []
  for file in l:list
    let res = g:autocdls_lsgrep_ignorecase ? stridx(tolower(file), tolower(pattern)) : stridx(file, pattern)
    if res != -1
      call add(lists, file)
    endif
  endfor

  if empty(len(lists))
    echohl WarningMsg
    echon 'no match'
    echohl NONE
  endif

  call autocdls#colorize(lists)
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et fdm=marker ft=vim ts=2 sw=2 sts=2:
