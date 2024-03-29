+++
title = "6.2 操作编辑对象"
weight = 2
+++

<!-- ## 6.2 操作编辑对象 -->

与 Vim 可视编辑的有关的几个概念对象是缓冲（buffer）、窗口（window）与标签页（
tabpage），还有目前较少用到的在命令行参数提供的文件列表（argument list）。VimL
也提供了许多函数以供脚本来控制这些编辑对象。

### 编辑对象背景知识

很早期的 `vi` 一次只能编辑一个文件。不过从命令行启动时可以提供多个文件名参数，
首先编辑第一个文件，编辑完后可以接着编辑下一个文件。如以下命令启动：
```bash
$ vim file1 file2 file3
```

Vim 就记忆着这三个文件，称之为参数列表，相当于执行了如下 VimL 语句：
```vim
: let arglist = ['file1', 'file2', 'file3']
```

注意在 Vim 启动时，还可以加很多命令行选项（以 `-` 开头的参数），一般用于指定
Vim 以何种方式、何种配置等启动。这些选项在 Vim 启动过程中就会被处理掉，不会保
存在参数列表中，所以参数列表只保存待编辑的文件名。

后来，Vim 支持同时编辑多个文件。作为通用编辑器，配置好 `vimrc` 后，它也经常省
略命令行参数，直接以裸命令 `$ vim` 启动，其参数列表就为空 `[]`。然后在 Vim 自
己的命令行中用命令 `:edit file` 打开要编辑的文件。

Vim 每打开一个文件，就创建一个缓冲（buffer），并记录相应的缓冲信息。即使打开另
一个文件，曾经打开的而目前看不见的文件，也记忆着它的缓冲，除非用命令显示地清除
它。Vim 的这个缓冲概念与系统缓存并不一样，对于非活跃 buffer （看不见的文件），
Vim 也不可能将文件的所有内容留在内存中，尤其是打开了很多大文件。可认为 buffer
是 Vim 为每个编辑文件创建的一个对象，记录着一些必要的信息。但是，也不一定每个
buffer 都对应着文件系统内的物理文件（磁盘上的文件），例如新建 buffer 尚未保存
甚至未命名，还有很多标准插件与三方插件的辅助窗口中的特殊 buffer 根本就不想写入
文件。

然后正在编辑的活跃 buffer 必然是显示在窗口的。早期的 `vi/vim` 也只支持一个窗口
，后来实现了多窗口。一个窗口只能装载一个 buffer，但一个 buffer 可以同时显示在
多个窗口中。再后来更扩展到多个标签页，每个标签页都可以分隔为多个窗口。

缓冲、窗口与标签页都被 Vim 顺序编号以便维护，这有点像参数文件列表的索引。不过
参数列表是真当作列表变量类型的，索引从 `0` 开始。而缓冲、窗口与标签页的编号都
从 `1` 开始。关闭文件并不意味着关闭缓冲，即使清除缓冲或隐藏缓冲也不会改变每个
缓冲的编号，但是关闭或移动窗口（或标签页），却会改变它们的编号。为此，自 Vim8
起，又引入窗口 id 概念，它是唯一且稳定的（不过似乎尚未有标签页 id 的概念）。

然而要指出，即使引入了缓冲概念，参数列表也还是有价值的。在有些情况下启动 vim
确实有明确目标要编辑某系列文件，将所有文件保存在参数列表中（其实在进入 vim 后
也可以提供或更改文件参数列表），就有很多批量命令能统一处理这系列文件。即使引入
窗口 id 概念，也还有窗口编号的价值。因为窗口编号更直观，从左到右，从上到下，很
容易知道哪个窗口是 1 2 3 4 。

查看缓冲可用如下命令之一：
```vim
: buffers
: ls
```
注意 `:buffers` 是有 `s` 后缀的复数形式，那才是打印缓冲列表的意思。如果是单数
命令 `:buffer` 则一般需要接个参数，用于打开另一个缓冲的意思。`:ls` 更简短，这
命令在 shell 中是列出文件意思，而在 Vim 中是列出缓冲的意思。这两个命令的输出中
，包含缓冲编号及相应的文件名等信息。

在任一时刻，都有（正在编辑中的）当前缓冲，当前窗口与当前标签页的概念。如果提供
了参数文件列表，也有当前文件的概念。不过当前文件不一定与当前缓冲相同。因为常规
编辑命令不会改变参数列表，你可以用 `:e` 或 `:b` 命令切换到编辑另一个可能并不在
参数列表中的“无关”文件，但在 vim 内部随参数文件列表保存的当前索引并不会改变。

最后，将这三个或四个概念统称为编辑对象。当了解这些编辑对象的意义后，就能更好地
理解相关的函数功能了。初学者可能会对缓冲与文件（参数列表）有所迷惑，日常使用时
可不求甚解认为缓冲即是指文件。不过编程时需要准确理解其中的不同。

### 获取编辑对象信息

* bufnr() 获取缓冲编号
* bufname() 获取缓冲名字
* winnr() 当前窗口编号，`winnr('$')` 获取窗口数量即最大编号
* tabpagenr() 当前标页面编号，`'$'` 参数获取标签页数量
* tabpagewinnr() 某个标签页的当前窗口编号
* bufwinnr() 获取某个缓冲的窗口编号
* winbufnr() 获取某个窗口的缓冲编号

其中，`bufnr()` 与 `bufname()` 的参数是一样意义，指示如何搜索一个缓冲，搜索失
败时前者返回 `-1`，后者返回空字符串：

* 数字：即表示缓冲编号。`bufnr(nr)` 一般返回编号本身（无效时返回 `-1`）。
  `bufname(nr)` 用于获取指定编号的缓冲文件名。
* 字符串：除了以下特殊字符意义，将该字符串当作文件名模式去搜索缓冲，也就是说不
  必指定文件全名，可以按文件名通配符（不同于正则表达式）搜索。但如果有歧义能匹
  配多个，或未能匹配，都算失败，返回 `-1` 或空串。当然会优先匹配全名，如果要限
  定只当作全名匹配，可加前后缀 `^` 与 `$`。
* 缺省：不能缺省参数，至少提供空字符串。
* `""`：空字符串表示当前缓冲。
* `"%"`：也表示当前缓冲。
* `"#"`：表示另一个轮换缓冲（在编辑当前缓冲之前的那个缓冲）。
* `0`：数字零也表示另一个缓冲。

注意，`bufname()` 返回的缓冲名，与 `:ls` 命令输出的相应缓冲行的主体部分相同。
该缓冲名是否包含文件全路径名，可能与当前路径有关。所以，如果要在程序中唯一确定
一个缓冲，应该用 `bufnr()` 的返回值，`bufname()` 一般只用于显示。

`bufnr()` 函数不能无参数调用，空字符串或数字零都是有特殊意义的参数。但是，
`winnr()` 与 `tabpagenr()` 一般是无参数调用，以获取当前窗口（标签页）的编号，
而用 `"$"` 参数表示获取最后一后窗口（标签页）编号，也就是最大编号或其总数量。
`tabpagewinnr()` 用于获取另一个标签页的当前窗口编号，比 `winnr()` 多加一个标签
页编号参数在前面。因为每个标签页都有当前窗口的概念，即是最后驻留的那个窗口。此
外，`"#"` 参数可用于 `winnr()` 与 `tabpagewinnr()` 表示之前窗口编号（即进入当
前窗口之前的那个窗口，`<C-w>p` 或 `:wincmd p` 将进入的窗口）；但不可用于
`tabpagenr()` 函数，因为 Vim 似乎没有维护之前标签页的概念。

以窗口编号为例，其典型调用方式小结如下：
* `winnr()` 当前窗口编号
* `winnr('$')` 最大窗口编号或窗口数量
* `winnr('#')` 之前窗口的编号

因为一个缓冲可能显示在多个窗口中，所以 `bufwinnr()` 返回的是显示了指定缓冲的第
一个窗口编号。其参数与 `bufnr()`意义相同，可认为先调用 `bufnr()` 确定缓冲编号
再查找相应窗口编号。反之，一个窗口在一个时刻只显示一个缓冲，所以 `winbufnr()`
返回的缓冲编号是确定的。其参数是窗口编号，用 `0` 表示当前窗口，但不能像
`winnr()` 那样使用 `$` 或 `#` 字符表示特殊窗口，否则字符串按 VimL 自动转换规则
转为数字 `0`，仍是调用 winbufnr(0)。

* bufexists() 检测一个缓冲是否存在
* buflisted() 检测一个缓冲是否能列表出来（`:ls`）
* bufloaded() 检测一个缓冲是否已加载
* tabpagebuflist() 返回显示在某个标签页中的所有缓冲编号列表

以上三个检测缓冲状态的函数，所有接收的参数除了缓冲编号外，若字符必须是文件全名
（全路径或相对当前路径），并能像 `bufnr()` 的参数那样支持文件通配符。一些特殊
缓冲并不会被列表出来，取决于局部选项 `&buflisted` 的设置。已加载的缓冲是指显示
在某个窗口的缓冲，但如果一个缓冲设置了 `&bufhidden` 局部选项为可隐藏 `hide`，
则它即使不显示了也仍算加载状态。

若要获取所有已显示在窗口中的缓冲，可用 `tabpagebuflist()` 函数，它返回一个列表
，收集了指定标签页中所有窗口内显示的缓冲（编号）；缺省参数是指当前标签页。在所
有标签页中显示的缓冲都是已加载状态（但已加载缓冲可能还包含一些隐藏缓冲），如下函
数可返回几乎所有已加载缓冲的列表：

```vim
function! BufLoaded() abort
    let l:lsBufShow = []
    for i in range(1, tabpagenr('$'))
          call extend(l:lsBufShow, tabpagebuflist(i))
    endfor
    return l:lsBufShow
endfunction
```

* argc() 参数文件列表个数
* argv() 参数文件列表，或返回指定索引的文件参数
* argidx() 当前所处参数文件的索引
* arglistid() 返回参数文件列表的ID

这是几个处理参数文件列表的函数。在去除启动选项后，`argc()` 与 `argv()` 就是命
令行参数。无参数调用 `argv()` 返回整个文件列表，但可指定索引 `argv(idx)` 返回
相应的文件名，`argc()` 就是这个列表的长度，即文件个数，而 `argidx()` 是指所谓
的当前文件的索引。但是 Vim 还对参数文件列表作了扩展，除了从命令行启动时指定的
参数列表叫做全局参数文件列表外，还可以为每个窗口定义局部参数文件列表，所以有了
`arglistid(winnr, tabnr)` 函数用以返回某个指定窗口（参数都可缺省，即用当前窗口
或当前标签页）的参数文件列表，全局的参数文件列表 ID 用 `0` 表示。

* `win_getid()` 获取指定标签页与窗口编号（可缺省默认当前）的窗口ID
* `win_gotoid()` 切换到指定窗口ID的窗口，有可能切换当前标签页
* `win_id2win()` 将窗口ID转换为窗口编号，只在本标签页查找
* `win_id2tabwin()` 将窗口ID转换为二元组 [标签页编号, 窗口编号]
* `win_findbuf()` 根据缓冲编号查找所有相应的窗口ID（是列表类型）

这几个处理 `window-ID` 的函数是从Vim8 版本引入的。函数名已经很望文生义了，可以
在窗口ID与窗口编号（及标签页编号）之间互相转换。要注意的是，每个标签页的窗口编
号都是从 `1` 开始重新编号，相互独立。但窗口ID是全局的，所有标签页的窗口共享一
套统一的ID。

### 获取编辑对象数据

前文在介绍 VimL 变量作用域时，提到三个特殊的局部作用域前缀 `b:` `w:` `t:` ，那
就是分别保存在特定缓冲、窗口与标签页的变量。如果仅用这个前缀，而无后缀主体变量
名，那就是表示收集了所有相应局部变量的字典（如 `b:` 也是个类似 `s:` 的特殊字典
）。从语义上理解，字典可当作一个对象，键当作属性。那么这些局部变量也就相当于相
应编辑对象的属性数据了。以下的 `get/set` 函数就是处理这些变量的函数：

* getbufvar() 返回缓冲局部变量 `b:`
* setbufvar() 设置缓冲局部变量的值
* getwinvar() 返回窗口局部变量 `w:` （限当前标签页）
* setwinvar() 设置窗口局部变量的值
* gettabvar() 返回标签页局部变量 `t:`
* settabvar() 设置标签页局部变量的值
* gettabwinvar() 返回窗口局部变量 `w:`
* settabwinvar() 设置窗口局部变量的值

以缓冲局部变量为例，函数参数原型是 `getbufvar(缓冲, 变量名, 默认值)`。其参数一
是缓冲编号或名字（类似 `bufnr()`的参数意义）；参数二的变量名是没有 `b:` 前缀的
主体名字，即 `b:` 字典的键；参数三是默认值，当不存在相应变量时的返回值，该参数
可缺省，缺省时就是空字符串，即当变量不存在时也不会出错，而至少返回空字符串。参
数二变量名不可缺省，当它是空（字符串）时，返回 `b:` 字典本身。设值函数参数原型
时 `setbufvar(缓冲，变量名，新值)`，第三参数不可缺省。

窗口局部变量取值与设值函数，可能与标签页有关。`gettabwinvar(标签页号，窗口编号
，变量名，默认值)`，需要在第一个参数前多插入一个标签页编号，如果取当前标签页的
窗口变量，则用 `getwinvar(窗口编号，变量名，默认值)`。窗口编号参数传 `0` 的话
，表示当前窗口。

* getbufinfo() 返回缓冲对象信息列表
* getwininfo() 返回窗口对象信息列表
* gettabinfo() 返回窗口对象信息列表

这三个函数是从 Vim8 引入的。其返回类型是字典的列表，即每个列表元素都是字典，字
典所包含的属性键依对象而不同。如果参数限定了一个对象，返回值也是包含一个元素的
列表；如果根据参数无法确定（搜索到）任一对象，则返回空列表。如果没有参数，则返
回由所有对象的信息字典组成的列表。

如果提供参数，`getwininfo()` 需传入窗口ID，而 `gettabinfo()` 传入标签页编号。
而 `getbufinfo()` 稍为复杂，除了可像 `bufnr()` 那样传入缓冲编号或名字外，还可
以用字典指定筛选缓冲的条件：`buflisted` 已列出的，`bufloaded` 已加载的。

这三个函数返回的对象信息字典，详细的键名解释请参考文档。但是都有一个键
`variables` （注意单词复数形式），其值是另一个字典（引用），即是特殊字典 `b:`
或 `w:` `t:`。所以 `get...info()` 函数也实现了 `get...var()` 的功能，不过前者
所得信息大而全，用法更复杂。另外 `get...var()` 函数可获取局部选项的值，以 `&`
为前缀的变量名传入即可，但这无法由 `get...info()` 获得，因为选项值并不保存在
`b:` 字典中。

### 获取光标位置信息

显然，当前光标只有一个确定位置。但 Vim 另有一个光标标记（`mark`）的概念，用于
记忆多个位置信息。例如在普通模式下用 `mx` 命令，就定义了标记 `x` ，保存着当前
光标的位置。此后移动到他处后，再用命令 `'x`（单引用）就能跳回标记 `x` 的行首，
使用 `` `x `` （反引号）就跳回标记 `x` 的准确行列位置。每个缓冲都能让用户定义以小
写字母 `a-z` 为名的标记，称为局部标记；而大写字母为名的标记是全局的，可以跨文
件缓冲跳转。此外，Vim 还有些自动定义的标记，如在选择模式下按 `:` 进入命令行，
会自动添加 `:'<,'>`，那就分别表示选区起始行与终止行的标记。

* line() 光标或标记的行号
* col() 光标或标记的列号（字节索引）
* virtcol() 光标或标记的屏幕占位列号
* winline() 光标在当前窗口的行号
* wincol() 光标在当前窗口的列号
* screenrow() 光标在屏幕的行号
* screencol() 光标在屏幕的列号

以上 `line()` `col()` 返回的行列号是相当缓冲文件而言。`col()` 是按字节列号的，
第一列是 `1`，`0` 用于表示错误列号。`virtcol()` 指屏幕占位列号，光标所在字符所
占的最后一列。假如一行全是汉字，光标停在第四个汉字上，`col()` 是 `10`，因为前
三个汉字只 `9` 字节，第四汉字从第 `10` 字节开始；`virtcol()` 是 `8` ，因为每个
汉字占两列宽，第四个汉字已占到第 `8` 列。当有制表符 `\t` 时，屏幕列与字节显然
也是不同的。不过这三个函数必须带参数调用，字符串参数意义如下：

* `.` 单点号表示当前光标
* `$` 当前行最后一列
* `'x` 表示 `x` 标记
* `v` 用于选择模式下，表示选区起始（因当前光标只表示选区终止）

特殊用法是 `col([行号, '$'])` 可获得指定行的最后一列。

`winline()` 与 `wincol()` 不带参数，只用于获取当前光标相对于窗口的行列号，因为
标记位置可能不在窗口显示区域，为标记调用这两个函数无意义。`winline()` 与
`line('.')` 的意义不同显而易见，长文件经常滚动，窗口的第一行在不同时刻对应着文
件的不同行。水平滚动条不如垂直滚动条用得多，但即使无水平滚动，`wincol()` 可能
也与 `col('.')` 不同。仍以上例汉字行，光标停在第四汉字上，`wincol()` 返回的是
`7`，因为前三汉字占 `6` 屏幕宽度，第四字从第 `7` 开始。

因为 Vim 可以分隔多个窗口，所以屏幕行列号 `screenrow()` `screencol()` 又与窗口
行列号 `winline()` `wincol()` 不同。不过屏幕行列号一般只用于测试。且直接在命令
行手动输入 `:echo screencol()` 时，它始返回 `1` ，因为执行命令时光标已经在命令
行首列了。

* getpos() 获取光标或标记的位置信息
* setpos() 设定光标或标记的位置信息
* getcurpos() 获取当前光标的位置信息
* cursor() 放置当前光标

顾名思义，可能会觉得 `getpos()` 就是 `line()` 与 `col()` 的综合效果，但其实位
置信息不仅是行列号。`getpos()` 的返回值是一个四元列表 `[bufnr, line, col, off]`，
其意义如下：

* `bufnr` 缓冲编号，`0` 表示当前缓冲，只有在取跨文件的全局标记，才需要返回其所
  在缓冲的编号，否则就是 `0`。
* `line` 行号，这就相当于 `line()` 函数了
* `col` 列号，这就相当于 `col()` 函数了
* `off` 偏移，只有在 `&virtualedit` 选项打开时才不是 `0`。比如 `<Tab>` 键可能
  占多列，但在一般情况下移动光标时是直接跳过的，但在打开 `&virtualedit` 选项时
  ，就可能移动到制表符中间某个位置了，这就是第四个返回值的意义。

`setpos()` 是 `getpos()` 的对应函数，它所接收的第二参数就是后者返回的四元列表
。第一参数就是标记名 `'x`（注意含单引用，而非反引号） 或表示当前光标的 `.`。

`getcurpos()` 无参数，只返回当前光标的位置信息，基本与 `getpos('.')` 功能相同
，不过返回值列表还多一个第五元素 `curswant` ，它表示当光标垂直移动（`jk`）时，
它优先移动到的列号，因为当前列号在下一行或上一行未必是有效的，这时该移动到哪列
呢，这第五个返回值就有效果了。

`cursor()` 用于放置当前光标，从语义上是 `getcurpos()` 函数的“反函数”，但是却不
能将后者的返回参数传给前者。因为 `getcurpos()` 返回值是五元列表，而 `curosr()`
函数用不到其第一个返回值 `bufnr`，将第一个元素移除后的列表传给 `cursor()` 是可
行的。事实上，`cursor()` 还可以几个非列表的参数直接调用。如 `cursor(line, col,
off)` ，或 `coursor([line, col, off, curswant])` 当然，只有行列号是必须的。当
需要明确移动光标到某处时，直接调用 `cursor(line, col)` 是最方便的。当需要恢复
光标时，最好与 `setpos()` 联用，如：

```vim
: let save_cursor = getcurpos()
" 移动光标干活
：call setpos('.', save_cursor)
```

* byte2line() 文件的第几字节处于第几行
* line2byte() 第几行是从文件第几字节开始的

这两个函数将整个缓冲文件的字节索引与行号相互转换。注意包含换行符，换行符是一字
节还是两字节则与文件格式有关。`line2byte(line("$") + 1)` 可获取缓冲的大小，其
实比缓冲大小多 `1`，因为是文件最后一行的下一行的起始索引。除此之外，非法行号返
回 `-1`。

* winheight() 返回指定编号窗口的高度，参数 `0` 表示当前窗口
* winwidth() 返回指定编号窗口的宽度
* winrestcmd() 返回一系列可恢复窗口大小的命令
* winsaveview() 保存当前窗口视图，返回一个字典
* winrestview() 由保存的字典恢复当前窗口视图

注意，`winrestcmd()` 只能恢复窗口大小，以字符串形式返回，将它用于 `:execute`
执行后才能恢复窗口大小。而 `winsaveview()` 与 `winrestview()` 能保存恢复比较完
整的窗口信息。其参数字典保存哪些键名及释义请参阅相关文档。

* screenchar() 返回屏幕指定行列坐标的字符
* screenattr() 返回屏幕指定行列坐标的字符有关的特征属性

Vim 的屏幕不仅包括缓冲窗口，还有标签页行，状态栏，命令行，窗口分隔符等都占据一
定屏幕坐标。不过这两个函数主要用于测试。

### 操作当前缓冲文本

然后是操作缓冲文件文本内容的函数，这是 Vim 作为文本编辑器的基础工作。

* getline() 从当前缓冲中获取一行文本字符串，或多行组成的列表
* setline() 从当前缓冲指定行开始替换文本行
* append()  从当前缓冲指定行下方始插入文本行
* getbufline() 从指定缓冲中获取文本行
* wordcount() 统计当前缓冲的字节、字符、单词，返回值是字典

如果 `getline()` 传入一个行地址参数，则返回一个字符串；如果传入两个起止行地址
参数，则返回一个列表，每个元素为一行文本。行地址参数可以是数量或字符 `.` 表示
当前行，字符 `$` 表示最后一行。`setline()` 可传入一个行地址参数，以及一个字符
串或字符串列表，用以替换指定行以及后续行。`append()` 用法与 `setline()` 一
样，不过是从指定行（下方）开始插入，并不会覆盖原有行。

`getbufline()` 与 `getline()` 类似，不过是取其他缓冲，所以要在第一个参数多传入
一个缓冲编号或名字。另外，行地址参数不能用 `.` 点号表示当前行，因为在其他缓冲
的当前行意义不明显（用户角度），而且返回值必定是列表，即使只有一个起始行地址参
数，也是一个元素的列表。

* mode() 当前的编辑模式：普通、选择、命令行等
* visualmode() 上次使用的选择模式：字符、行、或列块选择

Vim 有很多种模式，在脚本中可用这两个函数获取模式信息，然后根据模式作不同的响应
工作。一个非常有用的用途是用于状态栏定制中，否则触发该函数的时刻经常是命令行模
式（通过命令行调用或加载脚本），或普通模式（映射中调用）。
 
* indent() 指定行的缩进空白列数
* cindent() 按 C 语法应该缩进的空白列数
* lispindent() 按 Lisp 语法应该缩进的空白的列数
* shiftwidth() 每层缩进的有效空白列数

这几个缩进函数其实都是只读函数，并不会改变缓冲内容（执行缩进操作的命令 `=`）。
`indent()` 是返回指定行（参数按 `getline()` 惯例）的当前实际缩进数，按缩进的空
白数计，如果缩进字符是制表符，与相关的制表符宽度选项有关。而 `cindent()` 与
`listindent()` 是假设按 C 或 Lisp 语法规则缩进，该行应该缩进多少。需要根据这个
返回结果调用其他命令或函数执行真正的修改操作。与缩进相关的选项有好几个，而
`shiftwidth()` 函数是综合这几个选项的设置，给出的当前缓冲实际生效的每级缩进数
量。

* nextnonblank() 寻找下一行非空行
* prevnonblank() 寻找上一行非空行

这两个函数很简单，就是从参数指定的起始行地址查找非空行，如果起始行已经是非空行
，直接返回该行地址。返回值是数字，失败时返回 0，因为行地址索引从 1 开始。作为
通用文本编辑器，Vim 假定文本文件用空行分隔段落。而且良好编程风格的大多数语言源
文件，也是应该有空行分隔段落的，所以这两个函数有时挺实用。

* search() 搜索正则表达，返回行地址
* searchpos() 搜索正则表达式，返回行列号组成的二元列表
* searchpair() 按成对关键字搜索
* searchpairpos() 按成对关键字搜索
* searchdecl() 搜索一个变量的定义

这几个搜索函数可用于从脚本实现类似 `/` 的搜索命令，但有更灵活细致的控制。先看
最基本的搜索函数的参数原型 `search(pattern, flag, stopline, timeout)`，只有第
一个参数是必须的：

* `{pattern}` 就是 VimL 的正则表达式，在该函数中，一些影响搜索的选项如
  `&ignorecase` `&magic` 等将影响正则表达式的解析。
* `{flag}` 是一个字符串，每个字符表示不同的意义，一些冲突的标志不能并存：
  - `b` 表示反向搜索，默认正向搜索；
  - `c` 在光标处也能匹配成功；
  - `e` 光标移动到匹配成功处的末尾，默认移动到匹配处的起始位置；
  - `n` 即使匹配成功也不移动光标，但可利用函数的返回值，行地址；
  - `p` 返回值不再是行地址，而是匹配成功的（或连接）子模式索引加 `1`；
  - `s` 移动光标到匹配处前，将原位置保存在特殊标记 `'` 中；
  - `w` 搜索到文件末尾时，折回文件起始，与 `b` 并存时是到文件首折回；
  - `W` 搜索到文件末尾或起始时不折回；
  - `z` 从光标的列位置开始搜索，默认是从光标所在行首开始搜索。
* `{stopline}` 搜索从当前光标开始，可指定终止搜索的行。
* `{timeout}` 按毫秒数指定搜索的时间，搜索可能是个费时的操作，尤其是正则表达式
  写得复杂写得低效时，可指定时间，超时不再搜索。

所以这个函数有两个作用，一是返回值表示匹配的行地址，另一个副作用是会移动光标，
除非指定 `n` 标志不移动光标。匹配失败时返回 `0` ，当然也不会移动光标。

`searchpos()` 函数意义一样，只是返回多值（列表），除行号外，还返回列号，如果指
定 `p` 标记，还返回所匹配的子模式索引（加 `1`）。这里的子模式是指由或操作 `\|`
连接的多个模式分支，匹配其中任一个都算匹配成功，但若需要知道匹配的是哪个分支，
`p` 标记就有用了，注意需要被索引标记的子模式还得整个放在 `\(\)` 中。

`searchpair()` 成对搜索的意义类似在 VimL 脚本（或其他类似语法的语言，需加载自
带的 `matchit` 插件）中在 `if` 关键字中按 `%` 命令，它会搜索配对的 `endif` 以
及中间的 `elseif`。其参数就是在 `search()` 的基础上，将第一个正则表达式参数
`{pattern}` 换为三个正则表达式参数 `({start}, {middle}, {end}, ...)`。并且可以
在可选参数 `{flag}` 与 `{stopline}` 之间再加一个可选参数 `{skip}` ，其意义是表
示如何忽略某些匹配，比如 `elseif endif` 在注释或字符串中应该是要忽略的。`{skip}`
是一个可执行字符串，当作表达式执行后返回非 0 就表示要忽略，执行时光标相当于已
移动到匹配处。

`searchpairpos()` 的意义也类似，返回多值，即由行列号组成的列表而已。

`searchdecl()` 的作用与 `gd` 或 `gD` 普通命令类似，当然命令是取光标下的单词，
函数需要将变量名字符串当作参数传入。

* getcharsearch() 获得字符搜索信息
* setcharsearch() 设定字符搜索信息

这两个函数是从 Vim8 版本新增的。字符搜索是指 `f` `F` `t` `T` 这几个命令用于实
现行内搜索字符的，同时还有分号 `;` 与逗号 `,` 按正反向重复上次字符搜索。如果要
从脚本控制这种行为，可参考这两个函数。

### 修订窗口（quickfix）

很多命令会生成一个所谓的 `quickfix` 列表，这里将其译为修订。最早的应用来源是编
译源代码给出的错误列表，每条项目会指出错误出现的文件、位置等，用于方便定位错误
并修改。后来该概念扩展到其他许多命令，比如 `grep` 搜索，所以它就是一个有关定位
的列表。该列表显示在单独的窗口中，就叫做修订窗口，可在该窗口预览各个“错误”信息
，并像在普通窗口上移动，然后有方便的命令跳到相应位置外，并遍历整个列表。

据说最早的 Vim 版本并无此功能，只是一个插件功能，后来由于功能太过强大实用，就
整合为 Vim 的内置功能了。而且还扩展出了局部修订列表的概念，即每个窗口都可以有
自己的修订列表了。术语上，`qflist` 是全局的，`locallist` 是局部的。

* getqflist() 获得修订列表
* setqflist() 设置修订列表
* getlocallist() 获得局部修订列表
* setlocallist() 设置局部修订列表

`getqflist()` 返回的是字典列表，每个字典元素的键名解释请参考相应文档。
`setqflist()` 接收这样的字典列表作为参数，并且有个可选的参数指出是添加到原修订
列表末尾还是覆盖原列表。后两个函数用法一样，不过在最前面多插入一个参数指出窗口
编号（不是窗口ID）。

* taglist() 获得匹配的 tag 列表
* tagfiles() 获得 tag 文件列表

`tag` 文件是外部文件，记录着一些 `tag` （如变量名、函数名、类名等需要在大项目
中检索与交叉引用的东西）的定义位置，该文件是由外部程序扫描（所有相关）源文件生
成的，并遵循一定的格式。有了这样的文件，才能使用快捷键 `C-]` 与 `:tag` 命令。
而 `taglist()` 是其函数形式，参数就是所要检过的 `tag` 名称，以正则表达式解析，
要提供全名应自行加上 `^` 与 `$` 界定。

Vim 使用的 `tag` 文件可用选项 `&tags` 设置，它是以逗号分隔的文件名字符串。函数
`tagfiles()` 返回的是当前缓冲实际所用的 `tag` 文件列表（VimL 列表类型）。

* complete() 设置补全列表
* complete\_add() 向补全列表中增加条目
* complte\_check() 检查是否终止补全
* pumvisible() 检查是否弹出补全窗口

插入模式下的补全是相对高级的话题。Vim 的默认模式是普通模式，定制插入模式本身就
比较复杂。VimL 只提供了几个 api 函数。`complete()` 是简单地提供补全列表。
`complete_add()` 与 `complete_check()` 只能用于自定义的补全函数（`&compltefunc`）
中。

Vim 本身只是定位于通用文本编辑器，并非程序开发 IDE，但提供了这些基本接口，允许
三方插件将其打造成的类似IDE的大多功能。尤其是 Vim8 版本新增的异步功能，能显著
增加补全的性能与可用性。此不再详述，这些高级话题可能另辟章节讨论。

### 命令行信息

最后看几个有关命令行的函数。因为命令行也是可编辑区域，也是可以通过脚本访问的，
不过一般只适于正在编辑命令行时使用，比如 `:cmap` 定义的映射等。

* getcmdline() 获得当前命令行
* getcmdpos() 获得光标在命令行的列位置
* setcmdpos() 设置光标在命令行的列位置
* getcmdtype() 获取命令行类型
* getcmdwintype() 获取命令行窗口类型

命令行类型比如通过 `:` `/` `?` 进入的命令行都是属于不同的命令行类型。命令行窗
口是通过特殊键在命令行之上再打开的一个窗口，里面是命令行历史记录列表，可以方便选
择某个历史命令或在彼基础上作小修改后再次执行。故 `getcmdwintype()` 只有在命令
行窗口时才有意义，其值与 `getcmdtype()` 相同。

* getreg() 获取某个寄存器的内容
* setreg() 设置某个寄存器的内容
* getregtype() 获取某个寄存器的类型

寄存器相当于 Vim 自己管理的剪贴板，允许用户自命名的寄存器有 26 个（即单字母表示），
另外 Vim 还自动更新了许多以特殊符号表示的寄存器，各表示相应的特殊意义。寄存器
的内容可用 `:registers` 查看。这几个函数则用于脚本访问与控制寄存器。此外，对于
常规字母命名的寄存器，以 `@` 前缀的变量可直接表示该寄器（如 `@a`）。寄存器类型
与选择类型（字符、行、列块）相同，因为寄存器内容经常是选择后复制进去的。

用 Vim 编辑文本要善于利用命令行与寄存，这几个函数一般只在映射（调用）中比较有
效果。
