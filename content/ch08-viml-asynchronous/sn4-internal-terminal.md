+++
title = "8.4 使用配置内置终端"
weight = 4
+++

<!-- ## 8.4 使用配置内置终端 -->

### 8.4.1 使用异步的两个方面

本章讨论的是 vim 的异步特性，其实这包含两个方面。其一如何利用 VimL 编程控制异
步任务，（写插件）实现特定的功能。前三节都是围绕这个话题的，从简单到复杂介绍了
vim 提供的三种异步机制，定时器、任务与通道。那可能有点抽象或晦涩，需要与具体的
插件功能结合起来才更好理解，但是基于本书的定位，也不便介绍与解读太复杂的插件。

其二是如何更好地使用 vim 新版本自身提供的异步功能，典型的就是内置终端。作为普
通用户，相对于开发，运用可能是更简单有趣的。本节就是打算跳出复杂的异步编程的曲
折过程，调剂一下，重新回到简单常规的 VimL 调教与定制内置终端，使之更符合个性习
惯，成为日常使用的利器。

当然，这依然是引导性质或经验之谈，详细文档请看 `:help terminal` 。

### 8.4.2 内置终端的启动

```vim
: terminal
: terminal bash
: terminal python
```

用 `:terminal` 命令开启内置终端。其实广义来讲，它可以接受外部命令参数，在内置
终端中运行任意的外部命令，譬如打开一个 python 解释器。默认无参数时就执行
`&shell` 指定的程序，比如 `bash` 。

不过一般地，我们提到内置终端，就是指狭义上的在 vim 里面运行一个 shell 。它会横
向分裂一个半屏窗口，在这个特殊的窗口就几乎与外面运行的 shell 一样的操作与功能
，包括比如 `.bashrc` 的 shell 配置。

`:terminal` 除了可以指定外部命令参数外，还可以接受许多选项，控制诸如内置终端的
窗口大小、位置等各种选项。你可以将自己的偏好启动选项封装起来，自定义一个函数、
命令或快捷键。

此外，除了 vim 命令，还有个 vim 函数 `term_start()` 用于在编程逻辑中启动一个内
置终端，用法就如 `job_start()` 一样，给予灵活控制，按需启动终端。

### 8.4.3 终端模式的快捷键映射

在打开的内置终端窗口，为了能像外部 shell 那样使用 shell 本身的快捷键，Vim 禁用
了绝大部分快捷键。虽然在内置终端窗口中可以键入 shell 命令，但那不是 vim 的插入
模式也不是命令行模式，所以 `imap` 与 `cmap` 都不生效，当然更不可能是普通模式了
。 事实上，Vim 为此专门新定义了一种特殊模式，叫“终端任务”（`Terminal-Job`）模
式，不妨简称终端模块。如果要为终端模式自定义快捷键，应该用 `tmap` 系列命令。

不过在动手之前，还是要了解 vim 已经保留了一个特殊键用来切换回 vim 的普通模式；
而且由于前叙原因，也仅保留了一个键。这个键由选项 `&termwinkey` 给出，默认也是
`<C-W>` ，因为它的本意正是如何使用 `:wincmd` 切出终端窗口。于是 `<C-W>` 引导的
快捷键在终端窗口与普通窗口保持一致的含义，并且附带两个扩展：

* `<C-W>w` 切到下一窗口，`<C-W>W` 切到上一窗口，`<C-W>p` 切到之前所在窗口……
* `<C-W>n` 或 `<C-W><C-N>` 终端窗口切到普通模式（可以用 hkl 移动了）
* `<C-W>:` 从终端窗口进入 vim 命令行，（否则按冒号只是在 shell 提示符后输入冒
  号呢）

如果不喜欢 `<C-W>` 这个引导键——比如说因为 `<C-W>` 在 shell 中是删除前面一个词
的快捷键，故想将 `<C-W>` 键传给 shell ——那么可以设置 `&termwinkey` 更换。但一
般不建议修改，保持 Vim 内换窗口操作一致性较为重要，况且换任何键都可能会与
shell 冲突，总之是需要权衡。

从终端的任务模式回到普通模式略为麻烦，要按 `<C-W><C-N>` （在已经按下 `<C-W>`
的情况下，`<C-N>` 多按或少按那个 `ctrl` 键差别不大了）。为什么不保留 `<Esc>`
键回到普通模式呢？大概是 vim 想兼容更多的终端，有些终端用 `<Ecs>` 作为转义符。
就个人使用经验而言，在 shell 中会经常用到 `<Ecs>.` （接一个点）快捷键输入上一
条命令最后一个词。不过权衡之下，可以重定义 `<Esc>` 回到普通模式：

```vim
tnoremap <Esc> <C-\><C-N>
tnoremap <C-W>b <C-\><C-N><C-B>
tnoremap <C-W>n <C-W>:tabnext<CR>
tnoremap <C-W>N <C-W>:tabNext<CR>
tnoremap <C-W>1 <C-W>:1tabNext<CR>
tnoremap <C-W>2 <C-W>:2tabNext<CR>
...
```

除了 `<Esc>` 键外，我还定义了其他几个快捷键。比如使用终端时需要经常上翻查看结
果，就在 `<C-W>` 引导键后加个 `b` ，回到普通模式的同时上翻一页。然后我自己用
tabpage （标签页）比较多，所以也用 `<C-W>` 加数字切到特定的标签页中。当然，明
白了 `tnoremap` 之后，就能像 `nnoremap` 一样按自己习惯重定义快捷键了。

另外，按特定方式启动终端也可以自定义方便的快捷键，不过我推荐另一种思路，短命令
，例如：

```vim
command! -nargs=* TT tab terminal <args>
command! -nargs=* TV vertical terminal <args>
```

这意思是用 `:TT` 命令在另一个标签页打开终端，用 `:TV` 按纵向分割窗口打开终端。
可以将其想象为 `<mapleader>` 是 `:` ，而且冒号本来就要按下 `shift` 键，再接一
两个大写字母也顺手，只不过最后还要多按 `<CR>` 回车确认执行命令。然而这另有个好
处是还可以随时增加其他命令行参数（传给 `:terminal` ），这种灵活性是普通模式下
的快捷键不能达成的。因此，“短命令”适合于替代那些“次常用”的快捷键，毕竟键盘布局
的快捷键资源以及个人的记忆习惯是有限的。

既然内置终端的启动方式可以定制，那么就想如何能在启动终端时才自动定义那些 `tmap`
快捷键呢？毕竟 `tmap` 在平时是用不上，也未必是每次打开 vim 都会用到内置终端，
将 `tmap` （及其他与终端相关的设置）直接写在全局 `vimrc` 有点“浪费”。vim 显然
也想到了这个需求，很贴心地增加了一个自动命令事件，`TerminalOpen` 就会在打开内
置终端窗口时触发，于是可将如下事件写在某个合适的事件组（`augroup`）中：

```vim
autocmd! TerminalOpen * call OnTermialOpen()
```

将你想要定制内置终端的代码都写在 `OnTerminalOpen()` 函数中，当然使用 `#` 形式
的自动加载函数会更好。

### 8.4.4 内置终端与 vim 交互

所谓交互，自然是分两方面的。其中从内置终端（的任务中）向 vim 发起交互的需求，
可能来自一个有趣的“哲学”问题：可不可以在内置终端中输入 `$ vim file` 再启一个
vim 编辑文件呢。那自然是可以的，但在实用中那显得有点愚蠢，不够优雅。于是，就需
要一个机制，从内置终端中向开启它的“宿主” vim 发送消息，令其打开某个文件。

于是 vim 就有了这么个约定（据说来自 emacs），在内置终端运行的程序，只要向标
准输出打印如下序列：

```
<Esc>]51;["drop", "filenmae"]<07>
```

实际上就会将 `["drop", "filenmae"]` 传递给宿主 vim ，然后 vim 就知道将该消息解
释为执行 `:drop filename` 命令。`:drop` 命令其实与 `:edit` 命令类似，就是打开
一个文件，只不过如果文件已被打开，就会跳到相应的目标窗口。`:drop` 命令也就是随
内置终端版本一起增加的，可见它的原意就是想解决这个痛点。

`Esc` 字符是终端的转义符，在 VimL 中固然可以用 `<Esc>` 表示，但在其他语言（如
C 语言）中，则一般用 `\e` 表示，或直接用其 ASCII 码（ `\x1B` 或 `\033` 即十进
制的 27）表示。

例如，可以在 `~/bin/` 目录下写个简单的 `drop.sh` 脚本：
```bash
#! /bin/bash
echo -e "\e]51;[\"drop\", \"$1\"]\x07"
```

注意传给 vim 的消息要求是 json 模式（见前一节的通道模式），`drop` 与文件名参数
须按 json 标准用双引号括起。在多数语言或脚本中如果用双引号括起整个序列字符串，
就得将里面的 json 字符串的双引号用 `\"` 转义。可以用其他任何语言写这个 drop 脚
本，例如等效的 perl 脚本（`dorp.pl`）可以如下：
```perl
#! /usr/bin/env perl
my $filename = shift;
print qq{\x1B]51;["drop", "$filename"]\x07};
```

然后为了使用习惯，可以再在 `~/bin/` 中建个 `drop` 软链接，指向实用的 drop 脚本
，如：

```bash
$ chmod +x drop.pl
$ ln -s drop.pl drop
```

如果 `~/bin` 在环境变量 `PATH` 中，则在 vim 的内置终端中，执行如下命令：
```bash
vim-shell $ drop file
```

就能在宿主 vim 中用 `:drop` 打开相应的文件。不过这还有个问题。我们在 shell 中
给任何命令输入文件名参数，一般都是当前目录下的文件名。但是 vim 内置终端的当前
目录，很可能与宿主 vim 的当前目录并不相同，于是 drop 命令可能会失效，所以在传
递消息中应该使用绝对路径，以保证能找到正确的文件。为此，可将原来的
`~/bin/drop.pl` 改为如下：

```perl
#! /usr/bin/env perl
use Cwd 'abs_path';
my $filename = shift or die "usage: dorp filename";
my $filepath = abs_path($filename);
exec "vim $filepath" unless $ENV{VIM};
print qq{\x1B]51;["drop", "$filepath"]\x07};
```

主要改动是利用语言的相关模块获取文件绝对路径，并稍微保护判断下是否是否输入了文
件名参数。另一个改动是倒数第二行 `exec ... unless` 语句。只有在 vim 的内置终端
才会向宿主 vim 发 drop 消息，如果是从外部普通 shell 使用该脚本，那就会改为启动
vim （进程覆盖当前进程）打开命令行指定的文件，而最后一行再也没机会执行了。从
vim 中启动的内置终端会继承 vim 进程的环境变量，至少它会有 `$VIM` 这个环境变量
（可以用 `:echo $VIM` 查看），据此可以判断是内置终端还是外部终端。

当然，如果你熟悉 python ，用 python 写个 `drop.py` 也是容易的。

在 `<Esc>51;[msg]<07>` 转义序列中向 vim 传递的消息，除了支持 `:dorp` 命令，还
支持 `:call` 命令调用特殊的以 `Tapi_` 开头的自定义函数（限定函数名规范是为安全
起见）。消息形如 `["call", "Tapi_funcname", [argument-list]]` 。自定义函数约定
接受两个参数，与内置终端窗口关联的 buffer 编号，以及一个参数，所以如果业务逻辑
需要多个参数，就只能将它们打包在一个列表或字典类型的变量，当作一个参数传入。
Vim 开放这么个接口提供灵活扩展的可能，具体能做什么那当然是用户的实现了。

### 8.4.5 vim 与内置终端交互

交互的另一方面，是 vim 向内置终端发消息。

显示，内置终端也是个任务，有着底层的通道，所以始终可以尝试使用上节介绍的
`ch_sendraw()` 等函数。然而对于内置终端，没必要使用底层的函数，vim 提供更高
层函数 `term_sendkeys()` 直接向内置终端发送一个字符串，效果如同在终端提示符下
手动键入。注意该函数与 `feedkeys()` 的区别，后者是相当于向 vim 键入字符串，会
被 vim 截获，并受 `tmap` 映射影响；而前者是直接向内置终端键入，不受 `tmap` 影
响。

试验一下，在打开内置终端的窗口中，使用 `<C-W>:` 进入命令行，输入：

```vim
: call feedkeys('ls')
```

回车执行后，会在内置终端的提示符之后显示 `ls` 这两个字符，那就是相当于用户通过
vim 界面向内置终端敲了两个字符，但还没敲回车真正发送给内置终端运行。你可以继续
编辑这个命令，比如使用退格键删除之，或在其后增加选项 `-l` ，然后再按一次回车，
内置终端才能响应执行这个 `ls` 命令。然后，再 `<C-W>:` 试试输入：

```vim
: call term_sendkeys('', 'ls')
```

发现效果似乎还是一样，`ls` 这两字符停在内置终端提示符之后等待执行。需要将回车
键与合在这两个函数的参数中，才是通知内置终端立即执行：

```vim
: call feedkeys('ls' . "\<CR>")
: call term_sendkeys('', 'ls' . "\<CR>")
```

注意，回车键 `<CR>` 需要双引号转义。并且 `term_sendkeys()` 函数要求第一个参数
是指定内置终端的 buffer 编号，空值表示当前内置终端。从用户角度看，如果不涉及（
少量的）被 `tmap` 映射的键序列，用这两个函数的效果基本相同，但为了安全起见以及
语义明确，向内置终端发消息时，最好用 `term_sendkeys()` 函数。

在上一节介绍的 ZFVimTerminal 插件有个特性，是从 vim 的命令行中向模拟终端发送命
令。我们也可以借鉴这个思路，实现从 vim 命令行中向内置终端发送命令。当然了，从
内置终端窗口本身再用 `<C-W>:` 进入命令行输命令就有点多此一举了，反而麻烦。所以
需求应该是从任何一个普通 buffer 窗口，按 `:` 后在命令行向内置终端发送命令，避
免需要跳到内置终端的麻烦；当内置终端不存在时，显然应该打开一个新的内置终端。

为此，可以封装一个函数，并定义命令调用该函数，大致如下：

```vim
command! -nargs=* -bang TC call useterm#shell#SendShellCmd(<bang>0, <q-args>)
command! -nargs=* TCD call useterm#shell#SendShellCmd(0, 'cd ' . expand('%:p:h'))

function! useterm#shell#SendShellCmd(bang, cmd) abort
    " save current window
    if a:bang
        let l:tab = tabpagenr()
        let l:win = winnr()
    endif

    let l:found = useterm#shell#GotoTermWin(&shell)
    if empty(l:found)
        :terminal
    endif
    if !empty(a:cmd)
        call term_sendkeys('', a:cmd . "\<CR>")
        " into insert mode to force redraw terminal window
        normal! i
    endif

    " back to origin window
    if a:bang
        if l:tab != 0 && l:tab != tabpagenr()
            execute l:tab . 'tabnext'
        endif
        if l:win != 0 && l:win != winnr()
            execute l:win . 'wincmd w'
        endif
    endif
endfunction "}}}
```

这里，仍然按短命令思想，定义 `:TC` 用于在内置终端中执行任意命令，就是将其参数
用 `term_sendkes()` 函数转发给内置终端，并自动添加了回车键。`:TC!` 加叹号修
饰的话，会回到原来的普通窗口。用 `:TCD` 跳到内置终端窗口，并自动将内置终端的当
前目录切到原来编辑文件所在目录（就是自动执行 `cd` 命令啦）。因为 `TCD` 的用意
就是切到内置窗口，并开始在指定目录下与终端进行交互工作，那肯定是不必跳回原来的
，所以传给实现函数的第一个参数写定为 `0` 。

查找并切到终端窗口的函数，这里不再列出，主要是通过 `&buftype` 选项值是否为
`terminal` 来判断。有兴趣的可以到这个地址查看详细代码：
[https://github.com/lymslive/autoplug/tree/master/autoload/useterm](https://github.com/lymslive/autoplug/tree/master/autoload/useterm) 。
如果不习惯短命令，或担心命名名冲突，尽可自行改自己觉得满意的足够长的命名名，或
者再定义个快捷键映射。
