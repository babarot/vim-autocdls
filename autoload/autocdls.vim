" autocdls.vim
"   Do ls after cd automatically.
" Author:  b4b4r07
" Version: 0.1.2
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
  let g:autocdls_alter_letter = 0
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

function! autocdls#colorize(list) "{{{
  highlight LsDirectory  cterm=bold ctermfg=NONE ctermfg=26        gui=bold guifg=#0096FF   guibg=NONE
  highlight LsExecutable cterm=NONE ctermfg=NONE ctermfg=Green     gui=NONE guifg=Green     guibg=NONE
  highlight LsSymbolick  cterm=NONE ctermfg=NONE ctermfg=LightBlue gui=NONE guifg=LightBlue guibg=NONE

  if g:autocdls_ls_highlight == 0
    highlight LsDirectory  NONE
    highlight LsExecutable NONE
    highlight LsSymbolick  NONE
  endif

  for item in a:list
    if item =~ '/'
      echohl LsDirectory | echon item[:-2] | echohl NONE
      echon item[-1:-1] . " "
    elseif item =~ '*'
      echohl LsExecutable | echon item[:-2] | echohl NONE
      echon item[-1:-1] . " "
    elseif item =~ '@'
      echohl LsSymbolick | echon item[:-2] | echohl NONE
      echon item[-1:-1] . " "
    else
      echon item . " "
    endif
  endfor
endfunction "}}}

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
    let raw_path = substitute(getcmdline(), '\(^cd\|^chd\%\[ir\]\|^lcd\?\)\s*', '', 'g')

    redraw
    return empty(raw_path) ? "\<CR>" . autocdls#get_list($HOME, '', 0) : "\<CR>" . autocdls#get_list(fnamemodify(raw_path, ":p"), '', 0)
  else
    return "\<CR>"
  endif
endfunction "}}}

function! autocdls#get_filesize(file) "{{{
  let size = getfsize(a:file)
  if size < 0
    let size = 0
  endif
  for unit in ['B', 'KB', 'MB']
    if size < 1024
      return size . unit
    endif
    let size = size / 1024
  endfor
  return size . 'GB'
endfunction "}}}

function! autocdls#get_fileinfo(file, bang) "{{{
  if empty(a:file)
    return
  endif
  let file = a:file

  let ftype = getftype(file)
  let fpath = fnamemodify(file, ":p")
  let fname = fnamemodify(file, ":t")
  let fsize = autocdls#get_filesize(file)
  let ftime = strftime("%Y-%m-%d %T", getftime(file))
  let fperm = getfperm(file)

  echon "[". ftype ."] "
  echon fperm . " "
  echon ftime . " "
  echon "("
  if ftype ==# 'dir'
    echon len(split(glob(fpath. "/*") . string(empty(a:bang) ? '' : glob(fpath . "/.??*")), "\n"))
  else
    echon fsize
  endif
  echon ") "
  if ftype ==# 'dir'
    echohl LsDirectory | echon fname | echohl NONE
    echon "/"
  elseif ftype ==# 'link'
    echohl LsSymbolick | echon fname | echohl NONE
    echon "@" . " -> "
    echon resolve(fpath)
  elseif executable(file)
    echohl LsExecutable | echon fname | echohl NONE
    echon "*"
  else
    echon fname
  endif
endfunction "}}}

function! autocdls#get_list(path, bang, option) "{{{
  let bang = a:bang

  " Argmrnt of ':Ls' {{{
  if empty(a:path)
    let path = getcwd()
  else
    if a:path == '.'
      call autocdls#get_fileinfo(getcwd(), bang)
      return
    endif

    let path = substitute(expand(a:path), '/$', '', 'g')
    if getftype(path) != '' && getftype(path) != 'dir'
      call autocdls#get_fileinfo(path, bang)
      return
    endif
    if !isdirectory(path)
      echohl ErrorMsg
      echo path ": No such file or directory"
      echohl NONE
      return
    endif
  endif "}}}}

  " Get the file list, accutually {{{
  let save_ignore = &wildignore
  set wildignore=
  let filelist = glob(path . "/*")
  if !empty(a:bang)
    let filelist .= glob(path . "/.??*")
  endif
  let &wildignore = save_ignore
  let filelist = substitute(filelist, '', '^M', 'g')

  if empty(filelist)
    echo "no file"
    return
  endif
  "}}}

  " Add identifier to tail {{{
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
  "}}}

  if a:option == 1
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

  if a:option == 0
  "if !empty(a:option) && a:option == 0
    if strlen(join(s:lists)) > &columns * &cmdheight
      echohl WarningMsg
      echo len(s:lists) . ': too many files'
      echohl NONE
      return
    endif
  else
    if g:autocdls_newline_disp
      let nlists = []
      for item in copy(s:lists)
        call add(nlists, "\n" . item)
      endfor
      unlet s:lists
      let s:lists = nlists
    endif
  endif

  call autocdls#colorize(s:lists)
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

" Capitalize {{{
if g:autocdls_alter_letter
  let s:alter_letter_entries = []
  call autocdls#alter_letter_add('^ls$',  'Ls')
  call autocdls#alter_letter_add('^ls!$', 'Ls!')
  cnoremap <expr> <Space> autocdls#alter_letter()
endif "}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et fdm=marker ft=vim ts=2 sw=2 sts=2:
