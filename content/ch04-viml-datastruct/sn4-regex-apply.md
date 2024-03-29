+++
title = "4.4 正则表达式"
weight = 4
+++

<!-- ## 4.4\* 正则表达式 -->

在本章末尾，再简要介绍一下正则表达式的内容。正则表达式对于 Vim 很重要，但本教
程不打处专门用一章的内容来讲叙正则表达式（实际上正则表达式的内容可以写一本书）
。插录在这章数据结构之后，你可以认为正则表达式也是一种表达字符串内部结构的模糊
方法——模糊其实比精确更难理解与掌握。

Vim 对于正则表达式的内置帮助文件请查阅 `:h pattern.txt`。

### Vim 正则表达式的设置模式

很多编程语言或工具软件，都支持正则表达式，所以这是一种很实用的通用技能。然而不
幸的是各家支持的正则表达式都“略有不同”，更不幸的是 Vim 自家里面还有几种不同的
正则表达式语法，这是通过选项设置 `&magic` 改变正则表达式“包装套餐”的。

Vim 一共支持四套正则表达式，在 `/` 或 `?` 命令行中可添加特殊前导字符来表示本次
搜索采用哪套正则表达式：

* `\v`(very magic)，最接近 `perl` 语言的正则表达式。除了常规标识符字符外，大多
  数字符都有特殊含义，即魔法字符。
* `\m`(magic)，这是 Vim 的标准正则表达式。主要特征是括号与加号都是字面意义，不
  是魔法字符，需要在前面多加一个反斜杠来表示魔法意义。
* `\M`(nomagic) 更少的魔法字符，点号(`.`)与星号(`*`)都是字面意义。
* `\V`(very nomgic) 只有斜杠本身及正则表达式定界符有特殊意义，其他所有字符按字
  面意义匹配。

这四种正式表达式是根据魔法字符的多寡程度划分的。但是用反斜框可以改变魔法字符的
意义。即在一种正则表达式中，如果一个字符是魔法字符，反斜杠转义后就表示字面意义
；反之如果一个字符不是魔法字符，加反斜杠转义后就可能成为魔法字符表示特殊意义。
例如在 `\m` 正则表达式中，加号 `+` 不是魔法字符，它匹配字面的加号，使用 `\+`
表示匹配前面那个字符一次以上。而在 `\v` 正则表达式中，`+` 是魔法字符，表示匹配
前面那个字符一次以上，而用 `\+` 匹配字面上的加号。

如果没有显式指定哪种正则表达式（这应该是大部分 vimer 使用 `/` 搜索的默认方式）
，就根据 `&magic` 选项决定。设定了 `:set magic` 就默认使用 `\m` 正则表达式，设
定 `:set nomagic` 就默认使用 `\M` 正则表达式。但是若要使用 `\v` 或 `\V` 必须显
示指定。因为 `&magic` 选项的默认值是开启的，所以 Vim 的默认正则表达式是 `\m`
这套，不妨称之为 Vim 的标准正则表达式。

为什么正则表达式已经很复杂了，Vim 还要增加几种非标准正则表达式来使之更复杂？我
想这是 Vim 的另一个设计原则：尽可能减少用户的手动输入字符数（击键次数）。Vim
是一个通用文本编辑器，所编辑的文件内容在不同场合或有不同的侧重。比如在编辑程序
源文件时，应该普遍会有很多括号，很可能就需要经常搜索字面意义的括号，这时用标准
的 `\m` 正则表达式就更方便，而用 `\v` perl 类的正则表达式，就必须用 `\(\)` 来
搜索一对空括号。而在另外一些场合，可能希望直接用 `()` 来表示组合，这就用 `\v`
正则表达式更方便了。

对于精通（或习惯）perl 类正则表达式的用户，可以通过简单映射 `:nnoremap / /\v`
自动添加 `\v` 前缀，始终使用 perl 类正则表达来搜索。在替换命令 `:s///` 的模式
部分，也可以添加 `\v` 或其他前缀显式指定正则表达式的标准。

但是，对于一些需要正则表达式作为参数的内置函数，如 `match()`，只使用 `magic`
的标准正则表达式。这可能主要是考虑函数实现的方便与效率吧。毕竟函数主要写在
VimL 脚本中，而脚本一般只需写一次，语义一致也更重要。

因此，对于 Vimer 用户，还是建议掌握 Vim 的标准正则表达式。对于其他三种非标准正
则表达式，了解就要，觉得方便有用时，尽管一试。本文剩余部分只介绍 Vim 标准正则
表达式的基本语法。

### Vim 标准正则表达式

正则表达式描述的是如何匹配一个字符串，简单地说，它试图说明以下几个基本问题：

* 匹配什么字符
* 匹配多少次
* 在哪里匹配（定位限制）

再高级的议题还有分组与前向自引用等。

#### 匹配字面字符

以下字符按字面意义匹配（非魔法字符）：

* 大小字符与小写字母：`A-Z` `a-z`
* 数字：`0-9`
* 下划线：`_`
* 加号：`+`
* 竖线：`|`
* 小括号与大括号：`()` `{}`
* 其他没有定义特殊意义的符号，以及其他指明要加反斜杠转义才表示特殊意义的字符。

#### 匹配字符类别

支持的常用字符类别有：

* `\s`：空白字符
* `\d`：数字字符（`0-9`）
* `\w`：单词字符（合法标识符）
* `\h`：合法标识符的开头
* `\a`：字母
* `\l`：小写字母
* `\u`：大写字母

以上这几类字符表示，若改用大写，则表示取反，如 `\S` 表示非空白字符。这与大多数
正则表达式的语法表示是一致的。

Vim 正则表达式还有几类字符表示与选项相关，由相应选项指定字符集。

* `\i` 由选项 `&isident` 指定的标识符
* `\k` 由选项 `&iskeword` 指定的关键字符
* `\f` 由选项 `&isfname` 指定的可用于文件名（路径）的字符
* `\p` 由选项 `&isprint` 指定的可打印字符
* `\I` `\K` `\F` `\P` 大写版本在以上小写版本基础上排除数字

也可以手动指定字符范围，用中括号 `[]`：

* `[]` 匹配括号内任意一个字符，如 `[abcXYZ]` 可匹配这六个字符中的任一个
* `[0-9]` 用短横线（减号）指定的连续字符范围，匹配该范围内任一字符
* `[^0-9]` 匹配非数字，括号内第一字符是 `^` 时表示取反
* `[-a-z]` 若要包含减号本身，放在中括号内第一个字符，该示例表示小写字母或减号

中括号的用法与其他多数正则表达式一样。所以中括号与大小括号不一样，它是魔法字符
，若要匹配字面的中括号，则须用 `\[` 或 `\]`。

Vim 正则表达式还支持另一种特殊的中括号用法：

* `\%[]` 匹配中括号内可选的连续字符串，类似 ex 命令的缩写语法。

例如 `:edit` 可缩写至 `:e`，用正则表示就是 `:e\%[dit]`。

其他一些特殊字符：

* `.` 任一单字符
* `\t` 制表符
* `\n` 换行符
* `\r` 回车符
* `\e` `<Esc>` 键
 
### 匹配重复多次

* 0 或多次：`*`
* 1 或多次：`\+`
* 0 或 1 次：`\?` 或 `\=`
* 指定次数范围：`\{n,m}`，右大括号不需要反斜杠转义，左大括号需转义
* 非贪婪的次数范围：`\{-n,m}`

所以，没有意外地，点号与星号是魔法字符，分别用于匹配任意字符与任意次数，加反斜
杠匹配字面点号（`\.`）与星号（`\*`）。但是问号 `?` 不是魔法字符，须用 `\?` 来
表示匹配 0 或 1 次。

这些语法项不能单独使用，须用于表示字符（或类别）的后面，表示匹配前面那个字符字
符多少次。`\{n,m}` 是通用的次数表示语法，可以省略 n 或（与）m。

* `\{n}` 严格匹配 n 次
* `\{n,}` 至少要匹配 n 次
* `\{,m}` 匹配 0 至 m 次
* `\{}` 匹配 0 或多次，等同于 `*`
* `\{0,1}` 匹配 0 或 1 次，等同于 `\?`
* `\{1,}` 匹配 1 或多次，等同于 `\+`

正则表达式一般采用贪婪算法，以上的 `\{n,m}` 及 `*` `\+` 都是尽可能匹配更多次。
在一些场合需求下，需要采用非贪婪算法，可用 `\{-n,m}` 表示尽可能匹配更少次数。
`\{-n,m}` 也有省略变种，与 `\{n,m}` 用法一样，只是在左大括号内开始多一个减号。

例如，对于字符串 `<b>hello</b> <b>world!</b>`，如果用正则表达式 `<b>.*</b>` 或
`\<b>.\{}</b>` 就能匹配整个字符串，因为是在 `<b>` 标签之间贪婪匹配尽可能多的字符。
但如果是 `\<b>.\{-}</b>` 则只能匹配前一个标签，即子字符串 `<b>hello</b>`，这就
是非贪婪的意义。（注意：如果在 Vim 中测试该例，在 `/` 命令行输入这些正则表达式
，须注意转义 `/` 本身，即应该输入 `/<b>.*<\/b>`）

#### 匹配定界符(锚点)

* `^` 匹配行首
* `$` 匹配行尾
* `\<` 匹配词首
* `\>` 匹配词尾

在 Vim 编辑过程中，按 `*` 或 `#` 命令，用于搜索当前光标下的单词，就会在当前单
词前后自动加上 `\<` 与 `\>` 表示界定匹配整个单词。例如，你将光标移到本文的
`hello` 单词上，按下 `*`，Vim 应该会高亮所有 `hello` 单词，但如果有个地方写成
`hello_world` 加了下划线连字符，那就不会高亮这里的 `hello` 前缀。使用 `:reg /`
可以查看 Vim 为我们自动添加的正则表达式为 `\<hello\>`，你也可以按 `/` 进入搜索
命令后再按向上方向键把上次的搜索模式复制到当前命令行中查看。

* `\zs` 不匹配任何东西，只标定匹配结果的开始部分
* `\ze` 不匹配任何东西，只标定匹配结果的结束部分

这两个标记不影响“是否匹配”的判断，只影响若匹配成功后实际匹配的结果子字符串。例
如先看个简单模式 `hello.*world!`，它可以匹配 `hello world!` 或者在这两个单词之
间添加了其他乱七八糟的字符后也能匹配，匹配结果是从 `hello` 到 `world!` 之间的
所有长字符串。但是另一个类似模式`\zshello\ze.*world!`，它与前面那个模式能匹配
一样的字符串或文本行，但是匹配结果只有前面那个 `hello` 单词而已。可以利用 Vim
搜索的高亮显示来理解这个差异。

所以如果仅为了搜索，`\zs` 与 `\ze` 是基本不影响结果的，但如果同时要替换时，这
两个标定就很有用了，可使替换命令或函数大为简化。例如将 `hello` 改为首单词大写
：`:s/\zshello\ze.*world!/Hello/`，它只会修改后面还接了 `world!` 的 `hello`，
单独这个单词却不会被修改的。

Vim 的正则表达式，还有另外一些定位扩展，以 `\%` 形头的：

* `\%^` 匹配文件开头
* `\%$` 匹配文件结束
* `\%l` 匹配行，在 `\%` 与 `l` 之间应该是一个有效的数字行号，表示匹配相应的行
  ，若在行号前再加个 `<` 表示匹配该行之前的行，加个 `>` 则表示匹配之后的行。例
  如 `\%23l` `\%<23l` `\%>23l` 等。
* `\%c` 匹配列，与 `\%l` 用法类似。
* `\%#` 匹配当前光标位置
* `\%'m` 匹配标记 m，m可以是任一个命令标记（mark）。

#### 分组与引用

* `\(\)` 创建一个分组（子表达式），它本身不影响匹配，但便于其他语法功能使用
* `\1` `\2` ... `\9` 依次引用前面用 `\(\)` 创建的分组
* `\%(\)` 多加一个 `%` 与 `\(\)` 创建分组一样功能，但又不当作一个子表达式，即
  不影响 `\1` `\2` 等的引用次序。

分组的子表达式引用也可用于替换命令的替换部分，这可能是前向引用的常用用法，例如
`:s/\(\d\+\) + \(\d\+\)/\2 + \1/` 用于将一个加法运算的表达式的两个操作数调换次
序，将 `123 + 321` 修改为 `321 + 123`。

当然在正则表达内部也能用前向引用以达到某些特殊要求，比如常见的匹配 html 配对标
签，`<\(.*\)>hello<\/\1>` 可以匹配用任意标签括起的 `hello` 单词，如
`<b>hello</b>` `<xyz>hello</xyz>` 等，但若标签不配对不能匹配。

#### 其他限定语法

* `\c` 忽略大小写
* `\C` 不能忽略大小写

在默认情况下，正则表达式匹配也受 `&ignorecase` 的影响，但如果在一个模式中任意
地方加上了 `\c` 或 `\C` 控制符，就强行忽略或不忽略大小写。一般是加在表达式末尾
，临时改变主意在怎么忽略大小写。

这与 `\m` 或 `\M` 的控制符不一样，它只影响后续正则表达式的魔法字符释义。不过建
议放在整个正则表达式最前面为好。
 
### Vim 正则表达式总体构成

正则表达的具体语法细节，需要经常翻手册确认。不过最后还是再归纳一下 Vim 正则表
达式的总体构成定义，按帮助文档的术语，一个正则表达式从上到下分以下几个层次：
pattern <-- branch <-- concat <-- piece <-- atom <-- item 。

1. 一个正则表达式也叫一个模式（pattern），一个模式可能由多个分支（branch）构成
   ，虽然大多应用场合下只有一个分支。多个分支由 `\|` 分隔，表示“或”的语义（`|`
   不是魔法字符，所以要用 `\|`）。任一个分支匹配目标字符串，则表示该模式匹配成
   功；如果多个分支都匹配，则匹配结果取第一个能匹配的分支。
2. 每个分支可能由一个或多个聚合（concat）组成，若多个聚合由 `\&` 分隔，这表示“
   且”的语义。必须匹配每一部分的聚合，该分支才算匹配，但匹配结果是按最后一个聚合
   的匹配为准。
3. 每个聚合又可以由多个分子（piece）构成，分子之间相当于有自然引力结合，无须特殊
   字符直接粘接。如模式 `abc` 就只一个分支，一个聚合，该聚合有三个分子，每个分
   子是简单的字面字符；模式 `a[0-9]c` 或 `a\dc`同样是由三个分子组成。
4. 每个分子又由一个或多个原子（atom）构成。上一小节讲述的正则表达式语法其实主
   要都处于这一层。字符类别如 `\d` `\s` `\w` 就是表示一个原子，用 `[]` 指定的
   字符集合，也只是一个原子，而表示重复次数的 `\{n,m}` 就是描述多个原子的情况。
5. 每个原子即可以是普通原子，又可以是循环定义的子模式，即用 `\(\)` 或 `\%(\)` 
   创建的分组。

以上的第1第2层相当于逻辑或与逻辑且用于正则表达式的上层扩展，第3层却是很平凡的
定义，语法细节最多的是第4层，而第5层则是更深入的高级用法。

### 小结

正则表达式是很精妙的技术，非短时间所能掌握，只有多加实践积累经验。在 Vim 中，
可多利用高亮模式（`set hlsearch`）来测试正则表达式的正确性。有其他语言或工具的
正则表达式经验的用户，则特别注意一下 Vim 的特性语法。

正则表达的匹配是很复杂的算法，在其他一些语言中，可能有预编译正则表达式的功能（
库函数）。但在 VimL 中，似乎还未提供类似的内建函数。不过在写较大的 VimL 脚本时
，如果涉及使用正则表达式，也建议将常用的正则表式（字符串）统一定义在脚本开头，
方便管理与修改。
