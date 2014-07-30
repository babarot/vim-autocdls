# Automatically ls after cd in Vim.

If you install autocdls.vim, it enables you to 'ls' after 'cd' automatically.

# Installation

    NeoBundle 'b4b4r07/autocdls.vim'

# Usage

	:Ls[!] [{path}]

# Key mapping

Optional.

	nmap <Leader>ls <Plug>(autocdls-dols)

write your vimrc.

# Options

    " enable ls automatically (default 1)
    let g:auto_ls_enabled = 1

    " set the cmd-line's height (default &cmdheight)
    let g:autocdls_set_cmdheight = 2

    " Record history of cd (default 0)
    let g:autocdls_record_cdhist = 1


# Misc.
## TODO

 - When a path that contains spaces is passed as an argument to |s:get_list|,
   error occurs.

 - Regardless |g:auto_ls_enabled| is valid, when the destination directory
   has many files, not automatically execute ls after cd.


## LICENSE

The MIT License (MIT)

Copyright (c) 2014 b4b4r07

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


## CHANGELOG

* v0.1.0 

	2014-07-30	
	Initial version.

