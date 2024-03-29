+++
title = "9.2 外部语言接口编程"
weight = 2
+++

<!-- ## 9.2 外部语言接口编程 -->

### 9.2.1 语言接口介绍

Vim 支持其他诸多语言接口。这意味着，你不仅可以写 VimL 脚本，也可以使用被支持的
语言脚本。这就相当于在 vim 中内嵌了另一种语言的解释器。当然你不能完全像其他语
言的解释器来使用 vim ，毕竟还是遵守 vim 制定的一些规范，那就是 vim 为该语言提
供的接口。

在 Vim 帮助首页，专门有一段 Interfaces 的目录，列出了 Vim 所支持的语言接口，大
都以 `if_lang.txt` 命名，其中 `lang` 后缀指某个具体的（脚本）语言。笔者较熟悉
的脚本语言有 lua、python、perl ，而其他如 ruby、tcl 较少了解。因而在本章打算简
要介绍下 `if_lua` `if_python` 与 `if_perl` 这几个语言接口。（因 python 有两个
版本，故在帮助文档中其实用 `if_pyth.txt` 命名，避免 python 狭义地指 python2，
不过本文仍习惯使用 python 统称）

一些功能复杂的插件，为了规避 VimL 语言的不足，都倾向于按语言接口采用其他语言来
完成一部分或主要功能。比如，[unite](https://github.com/Shougo/unite.vim) 就采
用了 `if_lua` 接口，后来的升级版 [denite](https://github.com/Shougo/denite.nvim)
则采用 `if_python` 接口，另外推荐一个插件 [LeaderF](https://github.com/Yggdroot/LeaderF)
也是用 `if_python` 写的。这都是不错的实际项目源码，想深入学习的可以参考。

不过采用 `if_perl` 接口的现代插件较少，笔者鲜有看到。但是笔者偏爱 perl ，所以
在本章剩余篇幅将重点以 `if_perl` 为主，也算略微弥补一点空白。而且， Vim 为各语
言提供的接口大同小异，思路是一致的。介绍一种语言接口，也期望读者能举一反三。真
要用好某种语言接口，除了要仔细学习 vim 相关的 `if_lang.txt` 文档，还需要对目标
语言掌握良好，才能方便地在两种环境中来回游弋。

### 9.2.2 自定义编译 vim 支持语言接口

默认安装的 vim 一般不支持语言接口，需要自己重新从源码编译安装。这也其实很简单
，只要修改一些编译配置即可。首先从 vim [官网](https://www.vim.org/)或其 github
[镜像](https://github.com/vim/vim)下载源代码包，解压后进入 `src/` 子目录，
`vi Makefile` 查找并取消如下几行注释：

```
CONF_OPT_LUA = --enable-luainterp
CONF_OPT_PERL = --enable-perlinterp
CONF_OPT_PYTHON = --enable-pythoninterp
```

原来这几行是被 `#` 注释的，表示相关语言接口是被禁用的，你所需做的只是删去 `#`
符号启用功能。当然每个语言接口在 `Makefile` 都提供了好几个不同的（被注释）选项
备用，各有不同的含义，典型的如动态链接或静态链接。上面示例是打开静态链接编译选
项，含 `=dynamic` 的表示动态链接编译选项。你只需打开（取消注释）其中一条选项，
一般建议用静态链接编译。动态链接只是减少最后编译出的 vim 程序的大小，或许也略
微减少 vim 运行时所需的内存。在硬盘与内存都便宜的情况下，这都不算问题，用静态
链接可减少依赖，避免版本不兼容的麻烦。

不过 python 语言接口分 python2 与 python3 两个选项，它们既像一个语言又像两个语
言。打开 python3 接口的编译选项是 `--enable-python3interp` 。注意，你不能同时
打开 python2 与 python3 的静态编译选项，如果想同时支持，只能都用动态链接编译选
项。除非你有绝对理由想同时使用 python2 与 python3 ，还是建议你只使用其中之一。
而且 python2 都是历史原因，以后的趋势都应该都是转向 python3 。

在自定义安装 vim 时，还有个选项推荐打开，就是安装到个人家目录下，不安装到系统
默认的路径下，也就不影响系统其他用户使用的 vim 。只要指定 `prefix` 即可，一般
也就是打开（取消注释）如下这行：

```
prefix = $(HOME)
```

然后，就可以按 Unix/Linux 源码编译安装程序的标准三部曲执行如下命令了：

```bash
$ make configure
$ make
$ make install
```

如果你运气足够好，应该直接 make 成功的。如果 make 失败，最可能的原因是系统没有
安装相应的语言开发包，请用系统包管理工具（`yum` 或 `apt-get`）安装语言开发包，
如 `perl-dev` ，注意有些系统为语言开发包名的命名后缀不同，也可能是 `perl-devel` 。
安装好了所需语言开发包（及可能的其他依赖），再重新 `confire` `make` 应该就能成
功了。

在编译成功之后，`make install` 安装之前，最好检查一下新编译的 vim 是否满足你所
需的特性。执行如下命令：

```bash
$ ./vim --version
```

在 `vim` 命令之前添加 `./` 表示使用当前目录（`src/` 编译时目录）的 vim 程序，
否则可能会查找到系统原来的 vim 程序。如果打印的版本信息，包含 `+perl` （或
`+lua` `+python`），就表示成功编进了相应的语言接口。当然，你也可以直接不带参数
地启动 `./vim` 体验一下，并可在 vim 的命令行查看如下命令的输出：

```vim
: version
: echo has('perl')
: echo has('python')
: echo has('python3')
```

`:version` 命令与 shell 命令参数 `--version` 的输出基本类似。`has()` 函数用于
检测当前 vim 是否支持某项特性，如果支持返回真值（`1`），否则假值（`0`）。
`has()` 函数也经常用于 VimL 脚本尤其是插件开发中，为了兼容性判断，根据是否支持
某项特性执行不同的代码。

确认无误后，就可以 `make install` 安装。所谓安装也不外是将刚才编译好的 vim 程
序及其他运行时文件与手册页等文件，复制到相应的目录中。安装的根目录取决于之前
`$prefix` 选项，如果按之前指导选择了 `$(HOME)` ，那 vim 就会安装到 `~/bin/vim`
中。一般建议将个人家目录下的 `~/bin` 添加到环境变量 `$PATH` 之前，这样在 shell
启动命令时，首先查找 `~/bin` 目录下的程序。

当然了，在你决定手动编译 vim 之前，最好在目前默认使用的 vim 中用 `:version` 与
`has()` 检测下它是否已经支持相应的特性了，如果已经支持，那就可跳过这里介绍的手
动编译流程了。

### 9.2.3 语言接口的基本命令

测试某个语言接口是否真的能正常工作，也可直接以相应语言名作为 vim 的命令，执行
一条目标语言的简单语句，例如：

```vim
: perl print $^V
: perl print 'Hello world!'
: lua print('Hello world!')
: python print 'Hello world!'
: python3 print 'Hello world!'
```

其中第一条语句是打印 `if_perl` 接口使用的 perl 版本，其后就是使用不同语句打印
喜闻乐见的 `Hello world!` 了。

语言名如 `:perl` 也就是相应语言接口的最基本接口命令了，可见它们保持着高度的一
致性，vim 调用相应的语言解释器执行其参数所代表的代码段，所不同的只是各语言的语
法文法了。下面，如无特殊情况，为行文精简，就基本只以 `if_perl` 为例说明了。

基本命令 `:perl` 只适合在命令行执行简短的一行 perl 语句（当然，对于 perl 语言，
单行语句也可以很强大）。如果要执行一大块 perl 语句，短合在脚本中用 `here` 文档
语法，即 VimL 也像许多语言一样支持 `<< EOF` 标记：

```vim
perl << EOF
print $^V; # 打印版本号
print "$_\n" for @INC; # 打印所有模块搜索路径
print "$_ = $ENV{$_}" for sort keys %ENV; # 打印所有环境变量
EOF
```

`EOF` 只是约定俗成的标记，其实可以是任意字符串标记，甚至可以省略默认就是单个点
`.` 号。Vim 会从下一行开始读入，直到匹配某行只包含 `EOF` 标记，将这块内容（长
串字符串）送给 `:perl` 命令作为参数。换用其他标记的理由，一般是内容本身包含
`EOF` 避免误解。

不过良好的实践，不推荐将 `perl << EOF` 裸写在某个 `*.vim` 脚本文件中，而应该封
装在一个 VimL 函数中，最好再用 `if has` 判断保护，如：

```vim
function! PerlFunc()
    if has('perl')
        perl << EOF
        print $^V;
        print "$_\n" for @INC;
        print "$_ = $ENV{$_}" for sort keys %ENV;
EOF
    endif
endfunction
```

注意：`EOF` 不能缩进，只能顶格写，即整行只能有 `EOF` 才表示 `here` 文档结束。
这样封装之后，更能提高代码的健壮性与兼容性。然后就可按普通 VimL 函数一样调用了
`:call PerlFunc()` 。

当然，每次都写 `if has` 判断可能有点繁琐，那么可以将这个判断保护提升到更大的范
围内，如：

```vim
if has('perl')

function! PerlFunc1()
    perl code;
endfunction

function! PerlFunc2()
    perl code;
endfunction

endif
```

或者将所有利用到语言接口的代码收集到一个脚本，然后在最开始判断：

```vim
if !has('perl')
    finish
endif
```

在 `if_lua` 或 `if_python` 接口中，还提供执行整个独立的 `*.lua` 或 `*.py` 脚本
文件的命令，如下：

```vim
:luafile script.lua
:pyfile script.py
```

但是比较奇怪，`if_perl` 并没有类似的 `:perlfile` 命令，要实现类似功能，可以用
`:perl require "script.pl"` 命令，并且要注意 `perl` 的模块搜索路径问题。而在
`:luafile` 或 `:pyfile` 命令中，查寻命令行中提供的脚本文件，还是 vim 的工作，
取决于 vim 的搜索路径。

另外一个很有用的命令是 `:perldo` ， 它会遍历指定当前 buffer 范围的每一行（默认
是 `1,$` ），将 perl 的默认变量 `$_` 设为遍历到的那行文本（不包括回车换行符）
，如果 `:perldo` 命令参数的代码段修改了 `$_` ，它就会替换“当前”行文本。例如：

```vim
:perldo s/regexp/replace/g
:%s/regexp/replace/g
```

上面两行语句其实是一样的意义，都是执行全文正则替换，只不过第一行 `:perldo` 采
用 perl 风格的正则语法，它实际执行的是 perl 语句；第二行 `:%s` 就是执行 VimL
自己的正则替换。如果你想体会 perl 正则与 VimL 正则有什么异同，或对 perl 正则比
较熟悉，觉得某些情况下用 perl 正则更舒服，就可以用 `:perldo s` 代替 `%s` 试试
。

当然，`:perldo` 所能做的事情远不只 `s` 替换，`s` 在 perl 语言中只是一个操作符
。perl 语言的单行语句非常强大，尤其是支持后置 `if/for/while` 的条件判断或循环
，这就取决于用户的 perl 语言造诣了。

不过 `:perldo` 命令，与上一节介绍的过滤器机制略有不同，尝试用它实现给文本行编
号的功能，最初的想法可能是：

```vim
:perldo $_ = "$. $_"
```

但这不能达到要求，`$.` 在 `:perldo` 遍历的每一行中都输出 `0` ，这说明 perl 并
没有把文本行当成标准输入（或其他输入文件）处理，并没有给 `$.` 变量自动赋值。改
成如下语句能达到编号需求：

```vim
:perldo $_ = ++$i . " $_"
```

看起来有点像 perl 的黑魔法，其实不过是借助了一个变量 `$i` ，未定义变量当作数字
用时被初始化 `0` ，然后也支持像 C 语言的前置 `++i` 语法，然后又将该数字通过点
号 `.` 与一个字符串连接，代表行号的数字自动转化为字符串。这样创建使用的 `$i`
将是 perl 的全局变量，在执行完这条语句后，可以再用如下语句：

```vim
:perl print $i
```

查看 `$i` 的值，可见它仍保留着最后累加到的行号值。如果再次执行上面的 `:perldo` 
语句对文本行编号，那起始编号就不对了。需要手动 `:perl $i = 0` 重置编号。但这也
正意味着，如果要求编号从任意值开始，上述 `:perldo` 语句就很容易适应。

在 lua 或 python 语言接口中，也有类似 `:perldo` 的命令。但是它们没有类似 `$_`
默认变量的机制，`:luado` 与 `:pydo` 实际是在循环中为每行隐含调用一个函数，传入
`line` 与 `linenr` 参数代表“当前”行文本与行号，然后在参数的代码段中可以利用这
两个参数进行操作，并可用 `return` 返回一个字符串，取代“当前”行。在写法上没
perl 那么简洁，而且在单行语句中不像函数的地方使用 `return` 也多少有点违和与出
戏感。

### 9.2.4 目标语言访问 VIM

显然，如果使用一种语言接口，只是换一门语言自嗨诸如打印 `Hello world` 这种是没
有前途的。决定使用一种语言接口时，总是期望能利用那种语言更强大的能力，如更快的
运算速率或更丰富的标准库第三方库功能，完成一系列数据与业务逻辑处理后，最终还是要
通过某种形式反馈到 vim ，对 vim 有所影响才是。

为此，`if_lua` 与 `if_python` 都提供了专门的 `vim` 模块，在目标语言中将 vim 视
为一个逻辑对象，可从那语言代码中直接访问、控制 vim ，如设置 vim 内 buffer 的
文本，执行 vim 的 Ex 命令等。`if_perl` 也提供类似的模块，名叫 `VIM`，使用语法
与常规点号调用方法不同而已，perl 使用 `::` 与 `->` 符号。

以 `if_perl` 为为例，其 VIM 模块提供了如下实用接口：

* `VIM::DoCommand({cmd})` 从 perl 代码中执行 vim 的 Ex 命令；
* `VIM::SetOption({arg})` 设置 vim 的选项，相当于执行 `:set` 命令；
* `VIM::Msg({msg}, {group}?)` 显示消息，相当于 `:echo` ，但可以指定高亮颜色；
* `VIM::Eval({expr})` 在 perl 代码中计算一个 vim 的表达式；
* `VIM::Buffers([{bn}...])` 返回 vim 的 buffer 列表或个数；
* `VIM::Windows([{wn}...])` 返回 vim 的窗口表表或个数。

其中，前三个接口方法只是执行 vim 的命令，perl 代码中不再关注其返回值。后三个方
法是计算与 vim 相关的表达式，需要获得并利用其返回值。而 perl 语言的表达式是有
上下文语境的概念的。

`VIM::Eval()` 方法在标量环境中获得一个 vim 表达式的值，并转化为 perl 的一个标
量值。所谓 vim 表达式，比如 `@x` 表示 vim 寄存器 `x` 的内容，`&x` 表示 vim 的
`x` 的选项值。当然简单的 `1+2` 也是 vim 的表达式，但这种平凡的表达式直接在
perl 代码中求值也是一样的意义，没必要使用 `VIM::Eval()` 了。Vim 中的环境变量
`$X` 也与 perl 中 `$ENV{X}` 等值。 perl 的标量值具体地讲就是数字或字符串。但如
果该方法在列表语境中求值，则结果也是一个列表，特别地是二元列表：

```perl
($success, $value) = VIM::Eval(...);
@result = VIM::Eval(...);
if($result[0]) { make_use_of $result[1] };
```

返回结果的第一个值表示 `Eval` 求值是否成功，毕竟参数给定的 vim 表达式有可能非
法，如果成功，第二值才是实际可靠的求值结果。如果确信求值有意义，可直接用标量变
量接收 `VIM::Eval()` 的返回值，那就是求值结果，可简化写法，省略成功与否的判断
。

`VIM::Buffers()` 与 `VIM::Windows()` 的上下文语境就更易理解了，它符合 perl 的
上下文习惯：本来是数组的变量，在标量上下文表示数组的大小。所以不带参数的
`VIM::Buffers()` 返回所有 buffer 的列表，或在标量语境下返回 buffer 数量。如果
提供参数（可以一个或多个），就根据参数筛选 buffer 列表。如果想获取某个特定的
buffer，也得通过在列表结果中取索引，例如：

```perl
$mybuf = (VIM::Buffers('file.name'))[0]
```

你得保证 `file.name` 至少匹配一个 buffer，否则返回空列表，再对空列表取索引 `[0]`
是未定义的值。而且一般建议参数给精确，能且只能匹配一个 buffer ，否则如果匹配多
个，按 vim 的 `bufname()` 函数的行为，在歧义时也返回空。如果给的参数是表示
buffer 编号的数字，一般能保证唯一，只要是有效的 buffer 编号。给这个方法传多个
参数时，就返回相应参数个数的 buffer 列表，例如：

```perl
@buf = VIM::Buffers(1, 3, 4, 'file.name', 'file2.name')
```

就将取得一系列指定的 buffer 对象，存入于 `@buf` 数组中。

一旦获得 buffer 对象，就可以用对象的方法，操作它所代表的相应的 vim buffer：

* `Buffer->Name()` 获得 buffer 的文件名；
* `Buffer->Number()` 获得 buffer 编号；
* `Buffer->Count()` 获得 buffer 的文本行数；
* `Buffer->Get({lnum}, {lnum}?, ...)` 获取 buffer 内的一行或多行文本；
* `Buffer->Delete({lnum}, {lnum}?)` 删除一行或一个范围内的所有行；
* `Buffer->Append({lnum}, {line}, {line}?, ...)` 添加一行多多行文本；
* `Buffer->Set({lnum}, {line}, {line}?, ...)` 替换一行或多行文本；

Window 对象也有自己的方法，请查阅相应文档，这里就不再罗列了。此外，还提供两个
全局变量用于操作当前 buffer 与当前窗口：

* `$main::curbuf` 表示当前 buffer ；
* `$main::curwin` 表示当前窗口。

由于 `:perl` 命令执行的 perl 代码，就默认在 `main` 的命名空间（包）内，所以一
般情况下可简写为 `$curbuf` 与 `$curwin` 。

