# Automatically ls after cd in Vim.

If you install autocdls.vim, it enables you to 'ls' after 'cd' automatically.

![autocdls.gif](http://cl.ly/image/1t0W0V3W3E2O/autocdls.gif)

# Installation

    NeoBundle 'b4b4r07/autocdls.vim'

# Usage

	:Ls[!] [{path}]

* Show up some files in the `{path}` directory to cmd-line.

* If you want to show up all the files, including the files that begin with a dot in the `{path}` directory, then please put a bang(`:Ls!`).

* If you omit the `{path}`, the current directory is specified as `{path}`.

Next,

	:LsGrep[!] {word}

* Display the candidate that has the name of the directory name that contains the `{word}` in the current directory.

* As well as `:Ls!`, if you want to search the directory name that contains the `{word}`, then please put a bang(`:LsGrep!`).

# Options

	" Set height of cmd-line (equals &cmdheight)
	let g:autocdls_set_cmdheight = 2
	
	" Count number of files when doing ':Ls'
	let g:autocdls_show_filecounter = 1
	
	" View pwd when doing ':Ls'
	let g:autocdls_show_pwd = 0
	
	" Repleace ':ls' with ':Ls' automatically
	let g:autocdls_alter_letter = 1
