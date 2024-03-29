+++
title = "3.4 execute 与 normal"
weight = 4
+++

<!-- ## 3.4 execute 与 normal -->

为什么这两个命令值得单独拿出来讲，因为它们使得其他大部分 Vim 基本命令变得可编
程，用 VimL 编程。不仅是更高层次上的流程控制，更可以控制单个命令的执行，控制所
要执行的命令或参数。简单地说，就是可利用 VimL 语言的一切特性，拼接并生成将要执
行的 ex 命令，然后真正执行它。

* `:execute` 将 VimL 的字符串（值）当作命令执行。
* `:normal` 用 ex 命令的方式执行普通命令。

### 基本释义：execute

还是通过例子来说明。`:execute 'map x y'` 相当于直接执行命令 `:map x y`。当然这
似乎没什么用，多套层 `:execute` 似乎写起来还更复杂。但是我们可以这样写：
```vim
: let lhs = 'x'
: let rhs = 'y'
: execute 'map ' . lhs . ' ' . rhs
```

似乎还更复杂了是不？然而，这背后的思想在于，`lhs` 与 `rhs` 都是变量，我们可以
根据需求计算出它们值，然后再定义相应的映射。这就可以灵活地动态地执行 ex 命令了
。一般情况下，我们会把 `:execute` 命令写在脚本或函数中，比如写个叫
`s:BuildMap()` 的函数封装一下：
```vim
function s:BuildMap() abort
    let l:lhs = 'x'
    let l:rhs = 'y'
    let l:map = 'nnoremap'
    execute l:map . ' ' . l:lhs . ' ' . l:rhs
    " 或者下面这行语句等效
    execute l:map l:lhs l:rhs
endfunction
```

`:execute {expr}` 这是 `:execute` 的正式语法，它后面接一个表达式。vim 首先计
算出这个表达式的值，一般期望它是个字符串，如果不是字符串也会自动转为字符串。然
后执行这个字符串。

事实上它可以跟多个表达式，`:execute {expr1} {expr2}`，vim 会先求出各个表达式的
值，再拼接成一个字符串，中间有个空格。如果你不确定这个自动拼接机制，或者不想在
相邻表达式之间多加个空格，则可以用 VimL 的字符串连接操作符，一个点号 `.`，这样
就可以自己把握要或不要这个空格了。

在上个示例中，我们将函数内的局部变量直接赋值了（常量字符串），这仅为说明
`:execute` 的用法特征。更好的封装做法是利用函数参数，例如：
```vim
function s:BuildMap(map, lhs, rhs) abort
    execute a:map a:lhs a:rhs
endfunction
```
把函数体简化为一条语句了。当然更健壮的做法应该先检测一下 `a:map` 参数是否为合法
的映射命令，以避免一些灾难错误。而且真正的映射命令可能还不止由这三部分组成，还
可能有很多类似 `<buffer>` 这样的特殊参数呢，不过这里暂不考虑了。

当把眼光向外拓展，函数参数怎么来？那就把 VimL 当作普通脚本语言（类似 python
perl lua 这种脚本思想），根据需求计算变量的值，传递参数调用函数就可以了。

### 基本释义：normal

那么 `:normal` 命令又有何妙用。因为 VimL 本质上只是 ex 命令的组合，原则上在
vim 脚本中只能使用 ex 命令。但是 Vim 的基本模式是普通模式，有很多基本操作在普
通模式用普通命令可以很方便地达成，但在 ex 命令行模式（或脚本中）却可能一时找不
到对应的命令来实现相同功能，或者可以实现却写起来麻烦。

这时 `:normal {commands}` 命令就来帮忙了。它将其后的 `{commands}` 参数当成是在
普通模式下按下的字符（键）序列来解释。比如我们知道在普通模式下用 `gg` 跳到首行，
用 `G` 跳到末行。可有什么 ex 命令来完成这任务吗？有肯定有，至少可以调用函数
`cursor()` 来放置光标，但是用 `:normal` 似乎更简明：
```vim
: normal gg
: normal G
```

要注意与 `:execute` 命令不同的是，`:normal` 的参数 `{command}` 它不是个表达式
，它就表示字面上看到的字符。如果写成 `:normal "gg"` 反而错了，因为在普通模式下
，前两个字符（按键）`"g` 是取寄存器 `g` 的意思呢。

`:normal! {commands}` 的叹号变种，表示后面的 `{commands}` 不受映射的影响。因为
正常用户使用 vim 时都会在 `vimrc` 中定义相当多的映射，所以 `:normal` 命令会
继续根据映射来再次查寻将要执行的（普通）命令。这往往使得结果不可预测，所以一般
情况下建议使用 `:normal!` 而非 `:normal`。

不过，使用 `:normal` 还是有些限制的，毕竟不能完全像普通模式那样的使用效果。最重
要的一点是 `:normal` 命令必须完整。如果命令不完整，vim 自动在最后添加 `<Esc>`
或 `<Ctrl-c>` 返回普通模式，以保持完整性。完整性不太好定义，那就举例说几个不完
整的：

* 操作符在等待文本对象时不完整。如果执行 `:normal! d` 什么事都不会发生。因为在
  普通模式下 `d` 会等待用户继续输入文本对象。而用 `:normal` 来执行时，就无从等
  待，结果就是像按下 `d` 后又按下 `<Esc>` 取消了。但是 `:normal! dd` 能正确完
  成删除一行的操作。
* 用 `:normal` 命令进入插入模式操作后，会自动 `<Esc>` 回到普通模式，不会停留在
  插入模式。例如 `:normal! Ainsert something` 会在当前行末增加一些字符串，但是
  整个命令结束后，不能期望它还在插入模式，它会回到普通模式。
* 在 `:normal` 后面用冒号进入命令行模式并输入一些命令，却不能以想当然的方式执
  行。比如输入 `:normal! :map` 后按回车，它并不会执行 `:map` 命令列出映射。因
  为它相当于在命令行输入 `:map` 后按 `<Ctrl-c>` 取消了，并不是按回车执行了。你
  必须用个技巧将回车符添加到 `:map` 之后才行，直接按回车是执行 `:normal!` 这条
  命令的意思。这样输入：`:normal! :map^M` 再按回车就可以了，其中 `^M` 表示回车
  符，通过按 `<C-v><CR>`两个键才能输入。

总之，`:normal` 命令执行完毕后，会保证仍回到普通模式。也因此不能通过 `Q` 键进
入 `Ex 模式`。

### execute + normal 联用

正如上面看到，`:normal` 命令后的参数（普通命令按键序列），只适于可打印字符，对
于特殊字符，须用 `<C-v>` 转义后才能输入，这不太方便。但是可用 `:execute` 命令
再套一层，因为它接收的字符串表达式，当用双引号引起字符串时，特殊字符可用 `\` 转
义。比如为解决上面那个难题 `:normal! :map`：
```vim
: execute 'normal! ' . ":map\<CR>"
```

但是，`execute + normal` 的基友组合，远不止是为了输入特殊字符这么简单。
`:execute` 还可以使 `:normal` 也用上变量。例如，我们可以用 `5gg` 来跳到第 5 行
，用 `:normal` 命令也能跳到特定行：
```vim
: normal! 5gg
: normal! 10gg
```
然而，你无法直接动态地改变 5 或 10 这个数字，借且 `:execute` 就可以了：
```vim
: let count = 15
: execute 'normal! ' . count . 'gg'
```

再举个例子，在第 1.2 节，我们在普通模式下生成了一个满屏尽是 “Hello world!” 的
文章，回顾如下：
```vim
20aHello World!<ESC>
yy
99p
```

现在，我们用 VimL 语言编程的思路，利用 `execute + normal` 重新生成。既是编程，
封装成函数才好：
```vim
function HelloWorld(row, col) abort
    normal G
    let l:word = 'Hello World!'
    for i in range(a:row)
        normal! o
        execute 'normal! ' . a:col . 'a' . l:word
    endfor
endfunction
```
函数接收两个参数，分别表示生成多少行，与每行多少个“Hello World!”。在函数体中，
`:normal! G` 先将光标定位到当前 buffer 末尾，以便在末尾插入许多 “Hello World!”
。然后对每一行循环，每行循环中，先用 `o` 命令打开新行，再用 `:execute` 拼接重
复多次的 `a` 命令。

你可以用函数调用命令 `:call HelloWorld(100,20)` 来达到 1.2 节的效果，并且可调
用行列数生成不同规模的“Hello World!”。

### \*用 execute 定义命令

在上一节中，我们推荐了一种定义命令的常用范式：`call WorkFunc(<f-args>)`。这里
再介绍另一种定义命令的有趣范式：
```vim
:command! {cmd} execute ParseFunc(<q-args>)
```
形式上只是把 `:call` 命令换成了 `:execute` 命令。将自定义命令 `{cmd}` 的所有参
数打包传给函数 `ParseFunc()`，期望它返回一个字符串，再用 `:execute` 执行它。

这另有什么妙用呢？一般情况下，用 `:execute` 可能只想到用它来执行常规的 ex 命令
，但是也并不妨碍它用于执行 VimL 的特殊语法命令。例如，`:let` 命令只能一次创建
一个变量，下面这种“连等号”的语法是错误的：
```vim
: let x = y = z = 1
```

但我们可以试着自定义一个 `:LET` 命令，让它允许这个语法：
```vim
" File: ~/.vim/vimllearn/clet.vim
function! ParseLet(args)
    let l:lsMatch = split(a:args, '\s*=\s*')
    if len(l:lsMatch) < 2
        return ''
    endif
    let l:value = remove(l:lsMatch, -1)
    let l:lsCmd = []
    for l:var in l:lsMatch
        let l:cmd = 'let ' . l:var . ' = ' . l:value
        call add(l:lsCmd, l:cmd)
    endfor
    return join(l:lsCmd, ' | ')
endfunction

command! -nargs=+ LET execute ParseLet(<q-args>)
```
这代码有点长，适合保存在脚本文件中再 `:source`。先解释下函数 `ParseLet()` 的意
思：它首先将输入参数按等号（两边允许空格）分隔成几部分；将最后部分当作是值，其
余每部分当作一个变量，然后构造命令用 `:let` 为每个变量赋相同的值；最后将几个赋
值语句用 `|` 连接并返回，`|` 是在同一行分隔多个语句的意思。

有了 `ParseLet` 函数后，再定义一个命令 `:LET`，现在就可以尝试下连续赋值了：
```vim
: LET x = y = z = 1
: echo x
: echo y z
: echo ParseLet('x = y = z = 1')
```
可见 `x` `y` `z` 三个变量都已经被赋值为 `1` 了。最后一个 `:echo` 语句是为了显
示 `:LET` 如何工作的，实质上它转化为 `let x=1 | let y=1 | let z=1` 多个赋值语
句了。

那么，新定义的 `:LET` 能否正确处理变量的作用域呢，我们写个函数测试一下：
```vim
function! TestLet()
    LET l:x = y = z = 'abc'
    echo 'l:x =' l:x 'x =' x
    echo 'l:y =' l:y 'y =' y
    echo 'l:z =' l:z 'z =' z
endfunction

call TestLet()
echo 'x =' x 'y =' y 'z =' z
```
我们在函数中也定义了 `x` `y` `z` 这三个局部变量。结果表明，用 `:LET` 定义的局
部变量与全局变量也互不冲突的，可放心使用。

不过，`:execute` 命令毕竟还是有所限制的。只适合用于定义一些简单的“宏命令”，并
不能妄图重定义一些复杂的语法结构。而且，`:execute` 的效率也不高。
