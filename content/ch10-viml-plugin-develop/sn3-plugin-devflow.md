+++
title = "10.3 插件开发流程指引"
weight = 3
+++

<!-- ## 10.3 插件开发流程指引 -->

### 10.3.1 标准插件开发

写插件有两个目的，其一是自用，扩展或增强某个功能，或简化使用接口。其二是发布到
网站上给大家分享。Vim 的官网可以上传插件压缩包，不过现在更流行 github 托管。如
果仅是给自己用，插件脚本可以写得随意点，一些函数的行为也可以只接受自己选定的一种
固定实现。

但如果有较强烈的分享意愿，则应该写得正式点，这是一些实践总结的建议：

* 遵守第 10.1 节介绍的目录规范。
* 除非是单脚本插件放在 `plugin/` 目录中，较大型的插件如有多个脚本，则将主要函
  数实现放在 `autoload/` 子目录中，并且以插件名作为脚本名，或以插件名再建个子
  目录，如此插件名就相当于自动加载函数的命名空间。不过单脚本插件由于具有自包含
  、无依赖特性，在某些情况下也是方便的。
* 给用户提供配置参数（全局变量）定制某些功能的途径，变量名要长，包含插件名前缀
  然后接具有自释义性的多个单词，用下划线 `-` 或 `#` 分隔。并提供文档或注释说明
  。
* 如果插件的主要功能是提供了大量快捷键映射，最好为每个键映射设计 `<plug>` 映射
  ，这种映射名应该与配置变量一样要长，包含插件名前缀，名字要能反映快捷键想做的
  工作。
* 最好在 `doc/` 提供详尽的帮助文档，要符合 `help` 文档格式规范。在文档中要说明
  命令、快捷键等用法，及配置变量的意义。文档也应该随脚本更新。
* 如果发布在 github 上，要提供一个 `readme.md` 说明文档，除了功能简介，至少包
  含安装方法与安装命令，便于让用户直接复制到命令行或 `vimrc` 配置中。

#### 插件配置变量

支持用户配置全局变量的代码一般具有如下形式，在用户未配置时设定合理的默认值：

```vim
if !exists('g:plugin_name_argument')
    let g:plugin_name_argument = s:default_argument_value
endif
```

如果要设置默认值的可配置全局变量数量众多，则可以将这三行代码封装成一个函数，让
使用处精简成一行。设置默认值的函数示例如下：

```vim
function! s:optdef(argument, default)
    if !has_key(g:, a:argument)
        let g:{a:argument} = a:default
    end
endfunction
```

还可以将所有默认值存入 `s:` 作用域内的一个字典中，键名与全局变量名一致。这样还
能进一步方便集中管理默认值及设置默认值。

然后向用户说明，哪些快捷键是必须在加载插件之前（在 `vimrc` 中）设定值的，哪些
快捷键是可以在使用中修改即生效的。

很多插件还习惯用一个 `g:plugin_name_loaded` 变量，来指示禁用加载该插件，在
`plugin/` 脚本的开始处写入如下代码：

```vim
if exists('g:plugin_name_loaded')
    finish
endif
```

虽然依 vim 的插件加载机制会读取到这个脚本，但依用户的变量配置，有可能跳过加载
该脚本的剩余代码，不再对 vim 运行环境造成影响。

#### 插件映射设计

为了允许用户自定义快捷键，一个简单的方法是使用 `<mapleader>` ，让用户可按其习
惯使用不同的 mapleader 。另一个更复杂但完备的做法是设计 `<plug>` 映射。当前有
许多优秀插件的映射名使用类似 `<plug>(PlugNameMapName)` 的形式，把映射名放在另
一对小括号中，看起来像个函数名。如果要伪装成函数，还可以就这样定义：

```vim
nnoremap <plug>=PlugName#MapName() :call PlugName#MapName(default_argument)<CR>
```

理解 `<plug>` 映射的关键，就是把 `<plug>` 当作类似 `<CR>` 、`<Esc>` 这样表示的
一个特殊字符好了，只是它特殊到根本不可能让用户从键盘中按出来。这样让 `<plug>`
作为插件映射的 mapleader 就不可能与普通映射冲突了。为了也避免与其他插件的映射
相冲突，还在 `<plug>` 字符之后加上表示插件名的一长串字符以示区别。

为了直观类比，再想象一下 `vip` 这个键序表示什么意义？就是依次按下 `v` `i` `p`
三个键，它会选定当前段落（空行分隔）！假如要开发一个插件，扩展 `vip` 选段落的
功能（主要目的还应是操作段落），例如根据文件或上下文语境，段落有不同的含义，不
一定是空行分隔呢。那么该快捷键映射显然不能直接覆盖重定义 `vip` ，否则用户 `v`
进行可视选择模式会存在困难。至少应该定义为 `<mapleader>vip` 。对大部分用户来说
， mapleaer 就是反斜杠，于是按 `\vip` 就触发该插件智能选段落的功能。

但这还不够灵活，更专业的做法是用 `<plug>vip` ，明示它来源于插件映射。但
`<plug>` 映射不是给用户最终使用的接口，因为 `<plug>` 字符根本按不出来。所以要
双重映射：

```vim
nnoremap <plug>vip :call PlugName#SelectParagraph()<CR>
nmap <maplead>vip <plug>vip
```

注意第二个只能用 `map` 命令，不能用 `noremap` 命令，因为它要求继续解析映射。以
上两行的组合效果相当于是：

```vim
nnoremap <mapleader>vip :call PlugName#SelectParagraph()<CR>
```

那为何要多此一举？程序界有句俗话，很多麻烦的事情，多加一层便有奇效。vim 有个函
数 `hasmapto()` 可判断是否存在映射，在开发的插件若支持用户自己定义映射，就该像
全局变量配置那样，判断用户自己是否自定义过该快捷键了，只在用户未自己定义时，才
提供插件的默认映射。例如：

```vim
if !hasmapto('<plug>vip')
    nmap <maplead>vip <plug>vip
endif
```

所以，让映射（特别是非内置的插件映射）有个纯粹的名字会方便很多。若直接以键序如
`vip` 指代一个映射功能，显得很诡异，程序可读性也不高。既然 `<plug>` 映射主要是
作为名字指称之用，不是让用户直接按的，那它的名字就可以更长更具体些，也可以再加
些修饰符号（只要不是空格，否则让 `map` 命令解析麻烦）例如：

```vim
nnoremap <plug>=PlugName#SelectParagraph() :call PlugName#SelectParagraph()<CR>
nmap <maplead>vip <plug>=PlugName#SelectParagraph()
```

当然 `PlugName` 要替换为实际为插件取的名字。至于是否要在前后加 `=` 与 `()` 则
无关紧要，只是风格而已。常见的风格还有将左括号 `(` 紧接 `<plug>` 之后，括起整
个映射名。但 `<plug>` 字符必须在映射名最前面。

插件的功能实现最终一般会落实到函数中，所以将插件映射名对应实现的函数名也是良好
的风格，方便代码管理。但由于函数可以写得更通用些，可以接受参数调整具体功能，而
快捷键映射没有参数的概念，所以不能强求映射名与函数名一一对应，而应该为每个常用
参数的函数调用分别定义映射。例如，想用 `\Vip` 实现与 `\vip` 不同的功能：

```vim
nnoremap <plug>(PlugName#SelectParagraphBig) :call PlugName#SelectParagraph('V')<CR>
nmap <maplead>vip <plug>(PlugName#SelectParagraphBig)
```

虽然在插件映射名中也可以加括号与参数表示键序以求与函数调用外观一致，但未必更直观，
而且传入多个参数时要注意不能加空格。例如：

```vim
nnoremap <plug>=PlugName#SelectParagraph(Big) :call PlugName#SelectParagraph('V')<CR>
nnoremap <plug>=PlugName#SelectParagraph('V') :call PlugName#SelectParagraph('V')<CR>
nnoremap <plug>=PlugName#SelectParagraph(1,'$') :call PlugName#SelectParagraph(1, '$')<CR>
nnoremap <plug>=PlugName#SelectAll() :call PlugName#SelectParagraph(1, '$')<CR>
```

从对比中可见，当用参数 `(1, '$')` 调用函数时，不如直接取名为 `SelectAll` 更简
洁易懂。

#### 插件命令设计

插件映射 `<plug>` 的设计颇有些精妙，在早期的插件中推荐用得比较多。后来自定义命
令 `command` 越来越强大，于是在映射之外，再给用户界面提供一套命令接口也是一个
选择。

如果将前面的 `<plug>` 映射名，去掉 `<plug>` 前缀（对用户使用来说，也相当于改为
`:` 前缀）及其他符号，命名或许可再略加省略简化，那就摇身转变为了合适的自定义命
令名。当然相应地 `map` 要改为 `command` 命令，并注意不同的参数用法。

使用命令作为函数的用户接口，很容易实现传入不同的参数。因此更适合于那些不是非常
常用的功能，没必要分别设计 `<plug>` 映射，毕竟命名也是桩麻烦事。

为了使命令更易用，务必提供合适的补全方法。命令自带提示记忆功能，也是它优于映射
的一大特点。命令定义比普通映射复杂些，但理解起来不比 `<plug>` 映射困难。

提供了命令及相关说明文档之后，记得友情提醒一下用户，让用户知道可以自行、任意为
他自己常用的命令定义快捷键映射，并自行解决可能的快捷键冲突。当然最好也提供一份
快捷键定义示例，让用户可以拷入 vimrc 。例如：

```vim
nnoremap \vip :PNSelectPargraph<CR>
nnoremap \Vip :PNSelectPargraphBig<CR>
```

而这两个命令的定义，是写在插件脚本中的，可以像这样：

```vim
command PNSelectPargraph call PlugName#SelectParagraph()
command PNSelectPargraphBig call PlugName#SelectParagraph('V')
```

对于这个 vip 的例子，最后再提一句。直接将其定义为普通模式的快捷键不算是好的设
计，那应该是操作符后缀（operator-pending）模式映射，那样就不仅支持 `vip` ，还
同时支持类似 `dip` 与 `cip` 等快捷键。不过本章只专注讲插件总体设计，就不深入具
体实现细节了。

### 10.3.2 自动加载插件重构

#### 大量安装插件的新问题

由于插件管理工具的进化，安装插件变得容易了，一些狂热用户就很可能倾向于搜寻安装
过量的插件，启动 vim 加载几十上百个插件，并且让运行时目录 `&rtp` 迅速膨胀。虽
然没有明确的数据显示，vim 加载多少个插件才算“过多”，才会显著影响 vim 启动速度
以及运行时在 `&rtp` 中搜索脚本的速度，仅从“美学”的角度看，太长的 `&rtp` 就显得
笨拙，不够优雅了。

让我们直观地对比下其他脚本语言如 perl/python 的模块搜索路径，典型地一般就五、
六个，不超过十个。然而 vim 若加载 100 个插件，每个插件按标准规范占据一个独立的
`&rtp` 目录，那运行时搜索路径就比常规脚本语言多一个数量级了。（虽然从 vim 使用
角度看，似乎包路径 `&packpath` 对应着常规脚本语言的模块搜索路径，但从 vim 运行
时观点看，搜索 VimL 脚本却是从 `&rtp` 路径中的）

而且 vim 插件的规模与质量参差不齐，除了几个著名的插件，大部分插件其实都是“简单”
插件，也就是只有少量几个 `*.vim` 文件，甚至就是追求所谓的单文件插件。那么为了
一两个脚本，建立一整套标准目录，似乎有点大材小用。

上节介绍的 `dein.vim` 插件管理工具也意识到了这个问题，所以它提出了一个“合并”插
件的概念，以便压缩 `&rtp` 。其实合并插件思想也很简单，有点像回归 vimball 的意
味。只不过原来的 vimball 的是无差别地将所有插件“合并”到用户目录 `$VIMHOME` ，
如此粗暴地入侵用户私人空间，仅管有监控登记在案，那也是不足取的。

所以，更温和点方案是专门另建“虚拟插件”目录，按标准插件的目录规范组织子目录，然
后将其他第三方“简单”插件的脚本文件复制到该目录的对应的子目录中（尤其是
`plugin/` 内的脚本）。这就实现了合并插件，所有被合并的插件共享一个 `&rtp` 目录
。而那些著名的大型插件，显然是值得为其独立分配一个 `&rtp` 的。至于如何判定“简
单”插件，那又是另一个层面的管理策略了。然而如何为被合并的插件保持可更新，那也
是另一个略麻烦的实现细节。

不过，类似 `dein.vim` 的插件管理工具实现的合并插件，有点像亡羊补牢的措施。作为
插件开发者，可以从一开始就考虑这个问题。如何组织插件结构可使得插件可合并，易于
与其他插件共享 `&rtp` ？这里就提供一个以此目的的重构思路。

#### 基于自动加载机制重构插件

仍以上述 `vip` 插件为例。首先我们为这个插件确定一个名字，不如简单点就叫 `vip`
吧，这插件名字也足够高大上有吸引力。如果按标准插件规范，这整个插件应该位于
`$VIMHOME/bundle/vip` 或 `$VIMHOME/pack/bundle/opt/vip` 。再假设这是从一个简单
插件开始的，目前主要只有 `plugin/vip.vim` 这个脚本。

首先，我们将 `plugin/vip.vim` 脚本移动到 `autoload/vip/` 目录下，并改名为
`plugin.vim` ：

```bash
$ mkdir -p autoload/vip
$ mv plugin/vip.vim autoload/vip/plugin.vim
```

然后，编辑原脚本但改名后的 `autoload/vip/plugin.vim` ，在其末尾增加一个
`plugin#load()` 函数，空函数即可，或返回 1 假装表示成功：

```vim
function! plugin#load()
    return 1
endfunction
```

现在有什么不同呢？假设原来的 `vip/` 插件目录已被加入 `&rtp` 中。那么移动改名之
前的 `plugin/vip.vim` 会在 vim 启动时加载，而移动改名后的
`autoload/vip/plugin.vim` 并不会启动加载。但是可以通过调用函数（手动在命令行输
入或在其他控制脚本中写） `:call vip#plugin#load()` 加载。这个函数名意途非常明
确，足够简明易懂。如此触发脚本加载后，原来 vip 插件的所有功能也就加载进 vim 了
，其中的命令与快捷键映射也就能用了。

既然现在 vip 插件的加载可由用户 VimL 代码主动控制了。那就可以将 `autoload/vip`
这个子目录复制到其他任意 `&rtp` 中。当然不建议复制到 `$VIMHOME` 中。可以单独建
个目录用于“合并插件”，比如 `$VIMHOME/packed` ：

```bash
$ cd ~/.vim
$ mkdir packed
$ cp -r bundle/vip/autoload/vip packed/autoload/
```

在 Linux 系统，也可以用软链接代替复制，只要注意以后所指目标不再随意改名：

```bash
$ ln -s ~/.vim/bundle/vip/autoload/vip ~/.vim/packed/autoload/vip
```

然后，在 `vimrc` 或其他可作为管理控制的脚本中，加入如下配置：

```vim
:set rtp+=$VIMHOME/packed
:call vip#plugin#load()
```

如果有其他插件要合并入 `packed/` 目录，依法炮制即可。将要加载的“插件”调用其相
应的 `#load()` 函数，就如那些插件管理工具配制的插件列表。

自己要开发新插件，也可以从开始按这套路来，都不必另建插件目录，只要在自己的
`$VIMHOME/autoload` 建个子目录，写个 `plugin.vim` 脚本，脚本内定义一个
`#load()` 函数。

但是，如果想分享自己的插件，如何兼容之前的“标准”插件呢。或者说，就这个被改装重
构的 vip 插件，如何回到兼容旧版本呢？那也很简单，`plugin/vip.vim` 脚本文件被移
走了，再建个新的就是，但是只要如下一行代码：

```vim
" File: plugin/vip.vim
call vip#pligin#load()
```

这样就可以了，用户（或者利用某个插件管理工具）可以像标准插件一样安装。如果介意
`&rtp` 路径膨胀（或其插件管理工具能识别），只要将 `autoload/vip` 目录复制到用
户自己选定的另一个合适的共享 `&rtp` 即可。

#### 简单插件扩展开发

原来本意为单脚本的插件，如果后来需要扩充功能，以致代码量上升，感觉塞在一个文件
不太方便时，按标准插件的规范建议，也是将函数拆出来放在 `autoload/` 目录中。

而如果像这里重构的 vip 插件，本来就是将主体脚本放在于 `autoload/vip/plugin.vim`
中，在该目录中添加与 `plugin.vim` 文件同层级的“兄弟”脚本，那显然就更加自然了。
事实上，更合理的做法正是将插件的具体功能实现分别拆出放在不同脚本中。例如将选择
段落的功能放在 `select.vim` ，将插入段落的功能放在 `insert.vim` ，替换段落的功
能放在 `replace.vim` 中。当然，如何对插件功能抽象，是另一个层面的设计问题，与
具体的插件及其规模有关。也许这几个插件适合都放在一个名为 `operate.vim` 的脚本
，又或许更复杂的功能适合继续建子目录。

这里的关键只是想强调，不要将具体的功能实现（函数）放在 `plugin.vim` 中。
`plugin.vim` 原则上只写有关用户界面操作接口的定义。如 `command` 定义的命令，
`map` 系列定义的快捷键映射。而且，`<plug>` 插件映射的定义也最好不要暴露在
`plugin.vim` 脚本中，它们应该定义在相关实现脚本中。`plugin.vim` 脚本只定义用户
映射，即`<plug>` 插件可出现在 `map` 命令的第二参数中，不可出现在第一参数中。

当插件功能丰富起来后，就要向用户提供一些（全局变量）配置参数了。然后这些变量参
数配置在哪里也是值得考虑的事了。传统习惯中，是简单地让用户配置在 `vimrc` 中。
但可想而知，当安装了许多插件后，你的 `vimrc` 很可能有大量代码在配置插件了。此
后若删减或更换了插件，`vimrc` 中随意添加的插件变量配置也要记得删除。否则留下无
意义代码，降低 vim 启动速度，污染全局变量空间，虽然那程度或许不算严重，但想想
总是不爽不美的事。

参考加载插件的 `vip#plugin#load()` 函数，我们也可以相应地设计一个加载配置的
`vip#config#load()` 函数。这就意味着还有个 `autoload/vip/config.vim` 脚本与
`plugin.vim` 脚本并列。在这个 `config.vim` 脚本中，只使用简单的 `let` 命令定义
插件可用的配置变量的默认值，外带一个可空的 `#load()` 函数。真正有意思的是，允
许并建议、鼓励用户在其私人目录中提供自己的配置脚本，如
`$VIMHOME/autoload/vip/config.vim` 。由于个人 `$VIMHOME` 目录一般在 `&rtp` 最
前面，这个脚本如果存在的话会优先调用，否则就调用（被合并的共享 `&rtp` 目录下）
插件的默认配置。虽然，这句配置加载的调用函数应该写在 `plugin.vim` 的开始处。于
是 `plugin.vim` 脚本的总体框架现在大约如下：

```vim
" File: vip/plugin.vim
call vip#config#load()

" map 映射定义
" command 命令定义，调用其他 vip# 函数

function! vip#plugin#load()
    return 1
endfunction
```

如果没有在当前目录提供默认的 `config.vim` ，或担心用户提供的 `config.vim` 脚本
忘了定义 `vip#config#load()` 函数，为避免报错，可以将 `:call vip#config#load()`
这句调用包在 `try ... catch` 中保护。

让用户将插件配置在独立的 `config.vim` 中显然只应该是建议性的，而不应是强制性的。
如果用户在 vim 启动时始终要加载的插件，相关插件配置被分散到 `autoload/` 目录下
各个 `config.vim` 小文件中，反而会降低 vim 启动速度，不如将这些插件配置集中放
在一个大文件如 `vimrc` 中。事实上，用户将各插件的全局变量配置放在哪里，并无影
响，只是开发者要注意到这个现象。

这个 `plugin.vim` 脚本的体量可以很少，加载速度可以很快。关键在于定义命令时，调
用其他 `#` 函数实现功能，就能在首次调用命令时触发加载插件中其他相关脚本。而快
捷键映射，也建议定义为对命令的调用。如果习惯于 `<plug>` 映射，则将 `<plug>` 映
射本身定义为对具体 `#` 函数的调用（需要随 `plugin.vim` 加载，不能像 `#` 函数自
动加载）

用户在配置自己的 `config.vim` 时，可以推荐先从插件目录复制默认 `config.vim` 到
个人目录，在那基础上调整自己的参数值。如果变量名取得好，并且有一定的注释，那该
配置文件也自带文档功能。更进一步，更激进的点是，如果 `plugin.vim` 脚本也足够简
明，只定义命令与映射的话，用户也可以像复制 `config.vim` 一样复制到个人目录
`$VIMHOME` 对应目录下，然后直接修改快捷键定义（的第一参数）！这比在配置中约定
一个诸如 `g:plugin_name_what_key_map` 的全局变量更直接。

#### 文件类型相关插件

现在再来考虑文件类型相关的插件，这种可能需要多次加载的“局部”插件，比只需要一次
加载的“全局”插件会复杂点。

假设我们这个 vip 插件要支持 cpp 文件类型了，它认为对于 C++ 源文件来说，什么叫“
段落”应该有它自己特殊的处理。原则仍然是将所有运行时脚本放在 `autoload/vip` 目
录下。与 `plugin.vim` 脚本相对应的，文件类型相关功能可以建个 `ftplugin.vim` 。
然后在该脚本中设计一些意途明显的函数，如 `vip#ftplugin#onft()`，或者若该插件只
想支持少数几种文件类型（大部分情况如此），直接定义 `vip#ftplugin#onCPP()` 函数
。在该函数内的语句只设置局部选项与局部映射等，供每次打开相应文件类型的 buffer
时调用。而局部映射可能需要用到的支持函数，可直接在 `ftplugin.vim` 脚本中定义，
也能保证只加载一次。

然后，如果 vip 还想兼容标准插件目录，那就再建个 `ftplugin/` 子目录，其中
`cpp.vim` 文件只需如下一行调用：

```vim
:call vip#ftplugin#onCPP() " 或 vip#ftplugin#onft('cpp')
```

如果该插件想合并入共享 `&rtp` 目录，则指导用户将这行语句附加到个人目录的
`$VIMHOME/ftplugin/cpp.vim` 中。一般而言，如果用户常用 cpp 文件类型，关注 cpp
文件编辑，就该在个人目录建立这个文件，总有些自己想调教的选项或快捷键可以写在这
个脚本中进行定制。然后安装的其他能增强扩展 cpp 功能的插件，若都像
`vip#ftplugin#onCPP()` 这个显式地在此加行配置，那对 cpp 的影响一目了然，也很好
地体现了个人目录脚本的主控性，还能方便切换启用或禁用某个插件对 cpp 文件类型的
影响。

于是，在首次打开某个 `*.cpp` 文件时，会触发 `autoload/vip/ftplugin.vim` 脚本的
加载。会保证此时 `vip/plugin.vim` 脚本已加载，最好在 `ftplugin.vim` 脚本开头也
加入一行加载插件的调用语句。于是该脚本大致结构如下：

```vim
" File: vip/ftplugin.vim
call vip#plugin#load()

function! vip#ftplugin#onft(filetype, ...)
    if a:filetype ==? 'cpp'
        return vip#ftplugin#onCPP()
    endif
endfunction

function! vip#ftplugin#onCPP()
    " setlocal ...
    " map <buffer> ...
    " command -beffur ...
endfunction

function! vip#ftplugin#load()
    return 1
endfunction
```

但是如果要支持 vim 默认不能识别的文件类型，这样就不够了。例如这个 vip 插件还想
自创一种新文件类型，不如也叫 vip 吧，认为如 `*.vip` 或 `*.vip.txt` 后缀名的文
件算是 vip 类型。因为不能识别，所以不会自动加载 `ftplugin/vip.vim` 脚本。文件
类型的检测是基于自动事件机制，因此可以直接在 `vip/plugin.vim` 脚本中用
`:autocmd` 命令添加支持：

```vim
"File: vip/plugin.vim
augroup VIP_FILETYPE
    autocmd!
    autocmd BufNewFile,BufRead *.vip,*.vip.txt setlocal filetype=vip
augroup END
```

定义了这个事件检测后，再打开 `*.vip` 文件 vim 就会自动加载 `&rtp/ftplugin/vip.vim`
脚本，可在其中调用 `:call vip#ftplugin#onVIP()` ，就如支持标准类型 cpp 那样。
但是也可以直接在 `:autocmd` 事件定义中直接调用函数，没必要间接通过
`ftplugin/vip.vim` 标准文件类型插件脚本来调用。可改为如下：

```vim
"File: vip/plugin.vim
augroup VIP_FILETYPE
    autocmd!
    autocmd BufNewFile,BufRead *.vip,*.vip.txt call vip#ftplugin#onVIP()
augroup END
```

其实对于标准文件类型如 cpp 也可以通过类似定义事件调用 `vip#ftplugin#onCPP()`
，但是不要在 `ftplugin/cpp.vim` 对该函数同时调用了，否则重复调用浪费工作。

插件自创文件类型还有一种典型情形是，该插件有功能打开一个类似管理或信息窗口时，
想将该特殊 buffer 设为一种新文件类型，便于定义局部快捷键或语法高亮着色等。这种
buffer 还经常是 `nofile` 类型，不与硬盘文件关联，也不存盘。这时就不适合用
`autocmd` 根据文件后缀名来检测文件类型了。但是，由于这种 buffer 窗口是完全在
脚本控制下创建打开的，直接设定 `&ft` 就行了。例如，我们的 vip 插件还在某个情况
下打开一个提示窗口，不妨将其文件类型设为 `tip` ，于是在创建这种特殊 buffer 的
代码处，直接多加两行：

```vim
" 创建 tip buffer 窗口
setlocal filetype=tip
call vip#ftplugin#onTIP()
```

注意，当把 `&filetype` 设为 tip 时，vim 也会自动去所有 `&rtp` 搜索
`ftplugin/tip.vim` 脚本。你可以利用或避免这种特性，决定是否要加 `setlocal` 这
行。而 vip 本身这个插件，对 tip 窗口初始化的入口函数，也像其他标准文件类型一样
，集中放在 `vip/ftplugin.vim` 中定义。

#### 其他标准插件目录的考量

以上，在将 vip 插件重构的过程中，将传统标准插件的 `plugin/` 与 `ftplugin/` 子
目录移到 `autoload/` 下以插件名命名的子目录中，通过将插件名作为一级命名空间，
来实现插件的动态加载，可达到加速 vim 启动速度，精简合并共享 `&rtp` 的目的。这
几乎可以涵盖 95% 以上功能拓展型的 vim 插件。

当然也有些特殊目的的插件不适合于 `autoload` 重构，比如定制颜色主题的 `colors/`
，还有语法定义的 `syntax/` 。理论上来说，语法也是文件类型相关的插件，也可以类
似地移入 `autoload/vip/syntax.vim` 文件，将为每种文件类型定义语法的 `:syntax`
语句封装为函数，并由 `ftplugin.vim` 的相应函数来调用。但可能会有可用性与兼容性
的问题。除非是插件内自创的临时文件类型如 tip 需要简单高亮时，可以考虑直接写在
`vip#ftplugin#onTIP()` 函数中（或由这个函数调用他处定义的语法支持）。

此外，还有 `doc/` 帮助文档。这对用户使用参考很重要，但对 vim 运行时不重要，因
此不在重构范围内。就仍按标准独立插件提供文档吧，如果需要合并插件，也直接复制
`doc/` 文档到共享 `&rtp` 目录，也是简单的。

最后，想说明的是，这里所讨论的“重构”，主要是指插件开发思想上的重构。对于现存写
好的插件，没太大必要如何折腾，除非有相关插件管理工具能较智能地判断简单插件而自动
合并与维护。更关键的是对于今后开发新插件，无论大小，简单或复杂的插件，都可以按
这思路与规范，尽量将主体脚本封装在一个 `autoload/` 子目录中，以求最大化地追求支
持动态或自动加载，也为合并插件共享 `&rtp` 打开方便之门。

笔者有个自写插件的集合
[https://github.com/lymslive/autoplug](https://github.com/lymslive/autoplug)
就在以此思路写了一些符合自身的实用插件。并且提供一个 `:PI` 短命令，用于简化手
动调用 `:call xxx#plugin#load()` 的加载插件操作。

### 10.3.3 小结

本节介绍了两种插件开发的范式，一是继承传统，一是展望未来。传统的标准插件，主要
依靠 vim 内置固定的几种机制，在不同的时机去指定的目录搜寻加载脚本。而后一种自
动加载插件，更准确地说是可控的动态加载插件，则主要利用了 VimL 的一种通用的自动
加载函数机制，能让开发者向用户提供更灵活的插件加载方式与配置方式。

正像学习任一门编程语言一样，学习用 VimL 进行插件开发，更重要的也是实践。只不过
vim 一贯追求个性化，具体的插件开发可能没那么强的通用性，因而不适合作为本书的正
文内容。或许，那应该是另一个故事。而对读者来说，那也才算正式的起航。
