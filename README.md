vim-autocdls
====

**Overview**

Automatically execute shell-like `ls` command after `:cd` in Vim.

## Description

The vim-shellutils provides `:Ls` user-defined command that id shell-like `ls` commands in Vim. In addition, if `g:autocdls_autols_enabled` is true in this plugin, `:Ls` command is executed automatically after executing `:cd`, `:lcd` and so on. Thanks to that, make it easy to know file list in cwd.

![](http://cl.ly/image/1t0W0V3W3E2O/autocdls.gif)

## Requirement

Vim (**+Huge**) 7.3 or more

## Usage

### Ls

	:Ls[!] [{path}]
	
Show up some files in the {path} directory to cmd-line. If you want to show up all the files, including the files that begin with a dot in the {path} directory, then please put a bang. (`:Ls!`) If you omit the {path}, the current directory is specified as {path}.

### LsGrep

	:LsGrep[!] {word}

Display the candidate that has the name of the directory that contains the {word} in the current directory. As well as `:Ls!`, if you want to search the directory that contains the {word}, then please put a bang. (`:LsGrep!`)

## Option

### `g:autocdls_show_filecounter`

- Default is 1
- Show number of files in current directory to cmd-line

### `g:autocdls_show_pwd`

- Default is 0
- Print working directory on cmd-line

and any more.

*For more information, see also [help](./doc/vim-autocdls.txt)*

## Installation

### Manually

Put all files under `$VIM`.

### Pathogen (<https://github.com/tpope/vim-pathogen>)

Install with the following command.

	git clone https://github.com/b4b4r07/vim-autocdls ~/.vim/bundle/vim-autocdls

### Vundle (<https://github.com/gmarik/Vundle.vim>)

Add the following configuration to your `.vimrc`.

	Plugin 'b4b4r07/vim-autocdls'

Install with `:PluginInstall`.

- See [Bundle interface change](https://github.com/gmarik/Vundle.vim/blob/v0.10.2/doc/vundle.txt#L372-L396).


### NeoBundle (<https://github.com/Shougo/neobundle.vim>)

Add the following configuration to your `.vimrc`.

	NeoBundle 'b4b4r07/vim-shellutils'

Install with `:NeoBundleInstall`.

## Licence

>The MIT License ([MIT](http://opensource.org/licenses/MIT))
>
>Copyright (c) 2014 b4b4r07
>
>Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
>
>The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
>
>THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Author

| [![twitter/b4b4r07](http://www.gravatar.com/avatar/8238c3c0be55b887aa9d6d59bfefa504.png)](http://twitter.com/b4b4r07 "Follow @b4b4r07 on Twitter") |
|:---:|
| [b4b4r07](http://github.com/b4b4r07/ "b4b4r07 on GitHub") |

## See also

- [Help file](./doc/vim-autocdls.txt)
- [b4b4r07/vim-autocdls](https://github.com/b4b4r07/vim-autocdls)
