+++
title = "9.3 Perl 语言接口开发"
weight = 3
+++

<!-- ## 9.3\* Perl 语言接口开发 -->

本节将专门讲一讲 `if_perl` 接口的开发指导与实践经验，虽然只讲 perl ，但其基本
思路对于其他语言接口也可互为参照。

### 9.3.1 VimL 调用 perl 接口的基本流程

典型地，假如要使用（perl）语言接口实现某个较为复杂的功能或插件，其调用流程大概
可归纳如下：

1. 定义快捷键映射，`nnoremap` ，这不一定必要，可能直接使用命令也方便；
2. 快捷键调用自定义命令，`command`；
3. vim 自定义命令调用 vim 自定义函数；
4. 在 vim 函数中使用 `:perl` 命令调用 perl 函数；
5. 在 perl 函数中实现业务运算，可能有更长的调用链或引入其他模块；
6. 在 perl 函数使用 VIM 模块将运算结果或其他效果反馈回 vim 。

在以上流程中，前三步是是纯 VimL 编程（细究起来，前两步准备动作还只是使用 vim
），第 5 步是纯 perl 编程，而第 4 步与第 6 步就是 VimL 与 perl 的接口过渡。接
口的使用只能按标准规定，打通一种可能，而要直接实现有意义的功能，重点还是回归到
第 5 与第 3 步两门语言的掌握程度上。

整个流程是同步的，当 perl 代码执行完毕后，堆栈上溯，一直回到第 1 步的命令完成
，才算一条 vim 的 `Ex` 全部完成，然后 vim 继续响应等待用户的按键。

但凡编程，要有作用域的意识，在这第 4 步中，首先是在 VimL 的函数的局部作用域中
，首次进入的 perl 代码，是在 perl 的 `main` 命名空间。如果在 perl 的后续调用链
中，进入了其他命名空间，再想引用本次 vim 命令（第 2 步）或之前 vim 命令中在
perl `main` 命名空间定义的变量，就得显式加前缀 `main::` 或简写 `::` 也可。在
perl 代码中，使用 VIM 模块，只能直接影响 vim 的全局变量，它无法获知调用 `:perl` 
命令所处的函数作用域或脚本作用域。如果有这个需求，请约定使用的全局变量，并在
`:perl` 代码同步返回时，及时从被影响的全局变量更新局部变量保存下来。

另一个基本意识是有关程序的输入输出。从 `:perl` 开始执行的代码，它的标准输出被
重定向到 vim 的消息区。所以如果打印简单字符，`:perl print` 与 `:echo` 效果差不
多。在这里执行的 perl 不应试图从标准输入读取数据，如果需要输入，可以打开文件的
方式（如临时文件，或确定的目标文件），或者利用 VIM 模块直接读取 buffer 内容。

### 9.3.2 Perl 代码与 VimL 代码解耦

虽然语言接口允许你将两种语言混用写在一起，但当真正想实现一些较复杂功能时，将两
种语言的代码分别保存在独立的 `*.vim` 或 `*.pl` 是更好的代码维护与项目管理方式。
而且也尽量将使用了 `VIM` 模块的 perl 脚本与未使用 `VIM` 模块的代码分开。

因为 `VIM` 模块只能是从 vim 执行的 perl 代码才可用。将那些未使用 `VIM` 模块的
纯数据运算逻辑的 perl 代码独立开来，方便独立测试，也便于将其复用在非 vim 环境
下的常规 perl 脚本开发中。使用了 `VIM` 模块的 perl 代码，只方便在 vim 环境下测
试。如果一定要在外部独立测试调试，只能自己提供一个简易模拟版的 `VIM.pm` ，将在
脚本用到的 `VIM::` 方法都实现出来（比如就打印调试信息之类）。

如下代码段可以判断 perl 是否运行在 vim 环境（是否通过 `:perl` 调用的）：

```perl
package main;
our $InsideVim = 0;
{
    eval { VIM::Eval(1); };
    $InsideVim = 1 unless $@;
}
```

perl 的 `eval` 语句块，有类似的 `try ... catch` 的功能，就是尝试执行 `VIM` 模
块的随便一个有效的方法，最简单就是 `VIM::Eval(1)` 了。如果不是从 vim 环境执行
，`eval` 会出错，出错信息保存在 `$@` 变量中。如果确实在 vim 环境中，`eval` 正
常执行，`$@` 为空，`unless` 是条件取反，变量 `$InsideVim` 被置为 1 标记之。

然后就可以根据 `$InsideVim` 的值来做分支判断了。如果代码只设计在 vim 环境中使
用，当 `$InsideVim` 为假值时可直接 return 或 exit 。如果特意还是想在非 vim 环
境下通过测试，那就可以在 `$InsideVim` 为假时引用自写的简易调试版 `VIM.pm` 。

只为调试用的模拟 `VIM` 模块大致结构可以如下：

```perl
# File: VIM.pm
package VIM;

sub DoCommand{
    my $cmd = shift;
    print "Will do Vim Ex Command: $cmd\n";
}

sub Eval{
    my $expr = shift;
    print "Will eval Vim expression: $expr\n";
    return $expr;
}
```

也许还应该为 `Eval()` 函数添加自适应列表环境与标量环境的返回值，还有 Buffer 与
Window 对象的方法，模拟实现都会更复杂。故没必要求全，只根据实际情况，待测试的
脚本用到哪些方法，首先让脚本能编译能运行，再考虑进一步模拟精度的必要性。当然最
可靠的还是在 vim 中整合起来测试效果，只是在 vim 只能交互地手动测试，有时略有不
便。

顺便提一下，使用 `if_perl` 时，不必显式声明 `use VIM;` 就能在相关代码中使用
`VIM` 模块。但使用 `if_python` ，还是要显式声明 `import vim` 的。

### 9.3.3 Perl 与 VimL 数据交换的几种方式

首先，简单的 perl 代码，如果 print 至标准输出的，在被 vim 调用时是打印到消息区
的，因而可以用重定向消息的方法，将 perl 的标准输出内容捕获至 vim 变量中。例如
，专门写个 `ifperl.vim` 存些基本工具函数，如：

```vim
" File: ifperl.vim
function! s:execute(a:code) abort
    let l:perl = 'perl ' .  a:code
    redir => l:ifstdout
    silent! execute l:perl
    redir END
    return l:ifstdout
endfunction
```

这个函数将封装执行一段 perl 代码，将其标准输出当作一个变量返回（为简明起见，省
略了错误等特殊情况处理）。一般更推荐调用 perl 函数，如此利用 `s:execute()` 也
很容易封装函数调用：

```vim
function! s:call(func, ...) abort
    let l:args = join(a:000, ',')
    let l:code = printf('%s(%s);', a:func, l:args)
    return s:execute(l:code)
endfunction
```

实际上，在 vim 命令行向 perl 函数传参数还得注意引号问题，这里也从略。然后，模
拟 `:pyfile` 实现并未内置支持的 `:perlfile` 功能，也可简单封装成一个函数，如果
也想关注执行一个 `*.pl` 可能的输出，可以改用上面的 `s:execute()` 函数：

```vim
function! s:require(file) abort
    execute printf('perl require("%s");', a:file)
endfunction
function! s:use(pm) abort
    execute printf('perl use "%s";', a:pm)
endfunction
function! s:uselib(path) abort
    execute printf('perl use lib("%s");', a:path)
endfunction
```

注意，在 perl 中，`require` 与 `use` 语句有区别，各有用途。但都涉及搜索路径，
在程序中推荐用 `use lib` 动态添加。可以将用于 vim 调用的 perl 脚本收集在一个目
录（或专门的插件目录），并用 `use lib` 添加这个目录，便于 vim 使用。

其次，如果要用到的 perl 脚本，主要是一些工具函数，要利用其返回值的，而不是打印
到标准输出的。这种情况下，若强行在 perl 处加一层打印函数，在 vim 处重定向消息
，那是比较低效也不优雅的。另一个可考虑的替代的办法是专门设计几个全局变量槽让
perl 访问。例如；

```vim
" File: ifperl.vim
let g:useperl#ifperl#scalar = ''
let g:useperl#ifperl#list = []
let g:useperl#ifperl#dict = {}
```

```perl
# File: ifperl.pl
sub ToVimScalar
{
    my ($val) = @_;
    VIM::DoCommand("let g:useperl#ifperl#scalar = '$val'");
}
sub ToVimList
{
    my ($array_ref) = @_;
    VIM::DoCommand("let g:useperl#ifperl#list = []");
    foreach my $val (@$array_ref) {
        VIM::DoCommand("call add(g:useperl#ifperl#list, '$val')");
    }
}
sub ToVimDict
{
    my ($hash_ref) = @_;
    VIM::DoCommand("let g:useperl#ifperl#dict = {}");
    foreach my $key (keys %$hash_ref) {
        my $val = $hash_ref->{$key};
        VIM::DoCommand("let g:useperl#ifperl#dict['$key'] = '$val'");
    }
}
```

在 perl 中的三种数据类型，标量、列表、散列，分别可对应 VimL 变量的字符串、列表
与字典，并且字符串在可能的情况下都可当作数字使用。当 perl 里的数据需要发往
VimL 时，临时借助事先规定好的这几个全局变量做缓存，只多调用一层转接函数，不影
响原来 perl 函数的使用方式。

最后，其实要考虑的问题，是否真有必要将 perl 数据发还 VimL 。在协作完成一个功能
时，得盘算好哪部分必须在 VimL 处完成，哪部分可集中在 perl 处完成，没必要的中间
结果就别传回 VimL 处理了。

如果真要从 perl 频繁传出大量文本，自己用变量接收也不如用 VIM 内部的 Buffer 方
法有效率。例如，也专门设计一个 buffer，取名 `IFPERL.buf` ，在 perl 中将需要查
看的文本直接附加到这个 buffer 的末尾：

```vim
" File: ifperl.vim
let g:useperl#ifperl#buffer = 'IFPERL.buf'
```

```perl
# File: ifperl.pl
sub ToVimBuffer
{
    my $bufname = VIM::Eval('g:useperl#ifperl#buffer');
    my $buf = (VIM::Buffers($bufname))[0];
    $buf->Append($buf->Count(), @_);
}
```

这里直接将 `ToVimBuffer()` 函数的参数全部传给 `Append()` ，便支持同时添加多行
（字符串列表）或一行（标量字符串）至 vim buffer 中。须提醒的是 `Append()` 方法
的第一参数，不能使用 `'$'` 表示最后一行，只能是数字，因为这是在 perl 代码中，
`'$'` 没有特殊行号意义，当作普通字符串转化为数字时，就是 `0` ，结果就会添加到
buffer 最前面而不是最后面。

这种策略也适于记录被 vim 调用的 perl 代码执行过程的日志，直接发到某个 vim
buffer 中查看。在开发调试时有奇效，比写日志文件更有效，然后由用户再决定有无必
要保存日志。当然，完整的日志功能需要更灵活的控制，如在生产中就应该关闭，不打扰
原则。

### 9.3.4 小结

使用 `if_perl` 接口混合编程的一个实用示例可参考这个插件：
[useperl](https://github.com/lymslive/useperl) 。本节上述引用的代码段也多是从该
插件简化而来的。该插件目前主要利用了 `if_perl` 实现 perl 语言编写补全，理论上
利用 vim 内嵌的 perl 解释器可达到语义理解级别，只是在具体实现细节上还比较初步
，可能不甚完善。

然后说明一个事实，vim 支持多种语言接口，直接原因并非 VimL 本身设计多厉害（vim
的厉害之处更在其他整体综合上），而是因为那些脚本语言设计良好，方便嵌入其他程序
。例如，perl 与 python 都可提供 C/C++ 扩展，而 vim 就是个 C 语言写的应用程序；
还有 lua 语言最初设计目的就是便于嵌入到其他更大型的程序或服务上。所以 vim 利用
这些脚本语言的开发接口，编入它们的解释器，原非大惊小怪。也许，vim 还正想借这些
语言弥补自 VimL 脚本的不足。

那么，有了这些语言接口，是否就弱化了 VimL 脚本的意义了呢。那也不尽然，有些功能
还是适合用 VimL 来实现，尤其是涉及用户界面接口部分，如快捷键 `noremap` 与自定
义命令 `command` 还有 GUI 版本的菜单 `menu` 。此外，VimL 兼容与移植性更好，毕
竟其他语言接口不是默认编译选项。使用统一的官方 VimL 语言更有利于用户的交流与融
合。

所以，随着 vim 的进化与发展， VimL 语言也应该稳步发展，这将成为 vim 文化与社区
不可或缺的一部分。
