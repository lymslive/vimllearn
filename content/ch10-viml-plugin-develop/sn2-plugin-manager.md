+++
title = "10.2 插件管理器插件介绍"
weight = 2
+++

<!-- ## 10.2 插件管理器插件介绍 -->

## 10.2.1 插件管理的必要性

上一节介绍了 vim 用户目录（`~/.vim`，并推荐设为 `$VIMHOME` 环境变量）。这在自
己写简单脚本是很方便的，按规范将不同性质与功能的脚本放在不同子目录。但这有个潜
在的问题，源于你不能总是自己造轮子，且不论是否有能力造复杂的轮子。

这世界上多年以来有许多狂热的 vim 爱好者，开发了许多优秀的插件，应该善加选择然
后下载安装使用。但是如果都安装到 `~/.vim` 目录，那来源于不同插件的脚本就混在一
起了，既可能造成脚本同名文件冲突，也不利于后续维护（升级或卸载）。

后来，vim 提供了一种 `vimball` 的安装方式。就是将一个插件的所有脚本打包成一个
文件，其实也是符合 VimL 语法的脚本，直接用 vim 的 `:source` 命令，就会把“包”内
的文件解压出来，放到 `~/.vim` 目录下，并跟踪记录解压了哪些文件，哪个文件来源于
哪个安装包，然后将来要升级替换或下载删除时便有迹可寻。但这仍不可避免来源于不同
插件的脚本同名冲突，且将个人用户目录搞得混杂不堪，对有洁癖的 vim 用户尤其是程
序员是不能忍受的。

再后来，随着 github 的流行，版本控制与代码仓库的概念深入人心，vim 的插件使用与
管理思想也发生了革命性的变化。其实原理也很简单，关键还是 `&rtp` ，那不是一个目
录，而是一组目录，除了官方 `$VIMRUNTIME` 与用户目录 `$VIMHOME` 外，还可以将任
意一个目录加入 `&rtp` 列表。因此，可以将每个来源于第三方的插件放在另外的一个独
立目录，在该目录内也按 `$VIMRUNTIME` 目录规范按脚本功能分成 `plugin/` 、
`ftplugin/` 等子目录，再将其添加到 `&rtp` 中。如此，在 vim 运行时也就能在需要
时从这个目录读取第三方插件内的脚本，就和安装（拷贝）到 `$VIMHOME` 下的效果一
样。只是现在每个插件都有着自己的独立目录，甚至可直接对应 github 仓库，升级维护
变得极其方便了。

在所谓的现代 vim 时代，“插件”这词一般就特指这种有独立目录并按 vim 规范组织子目
录的标准插件，插件内的各子目录的文件一起协作完成某个具体的扩展功能。而之前那个
用户目录 `$VIMHONE` ，建议只保留给用户自己保存 `vimrc` 及其他想写的脚本，不再
被安装任何第三方插件。在这之前，`$VIMHOME` 目录尤其是 `plugin/` 子目录下的每个
脚本，也许都被称为一个插件，为了区分，或可称之为“广义的插件”。而从现在开始，单
说插件时，只指“狭义”的标准插件（目录）。

当安装插件变得容易时，安装的第三方插件就会越来越多，这时又诞生了另一个需求。那
就是如何再管理所有这些第三方插件？本章的剩下内容就来介绍一些便利的插件管理工具
及其管理思路。这些插件管理工具本身也是个第三方插件。

## 10.2.2 pathogen

首先介绍一款插件：
[https://github.com/tpope/vim-pathogen](https://github.com/tpope/vim-pathogen)。
看其名字 pathogen，大约是“路径生成器”的意思，其主要工作就是管理 vim 的 `&rtp`
目录列表。

按 pathogen 的思路，是在 `$VIMHOME` 约定一个 `bundle/` 子目录，然后将所有想
用的第三方插件下载安装到该目录。对于托管在 github 上的插件，可以直接用 `git
clone` 命令，例如就安装 pathogen 插件本身：

```bash
$ mkdir -p ~/.vim/bundle
$ cd ~/.vim/bundle
$ git clone https://github.com/tpope/vim-pathogen
```

这样，插件安装部分就完成了，可以如法炮制安装更多插件。然后要 vim 识别这些插件，
让它们真正生效，还要在 `vimrc` 中加入如下两句：

```vim
set rtp+=$VIMHOME/bundle/vim-pathogen
execute pathogen#infect()
```

其中第一句是将 pathogen 本身的插件目录先加到 `&rtp` 列表，如此才能调用第二句的
`pathogen#infect()` 函数。很显然，这是个自动加载函数，它会找到
`autoload/pathogen.vim` 脚本，加载后就能正式调用该函数了。该函数的功能就是扫描
`bundle/` 下的每个子目录，将它们都加入 `&rtp` 列表，就如同第一句显式加入那样；
只不过 pathogen 批量扫描，帮你做完剩余的事了。

事实上， pathogen 插件只有 `autoload/pathogen.vim` 这一个脚本是关键起作用的，
如果将该文件安装（下载或拷贝）到 `$VIMHOME` 中，那就没必要第一句显式将
pathogen 加入 `&rtp` ，因为它已经能在 `&rtp` 中找到了。如果在 Linux 系统，若为
安全或洁癖原因，不想复制污染用户目录，则可用软链接代替：

```bash
$ cd ~/.vim/autoload
$ ln -s ../bundle/vim-pathogen/autoload/pathogen.vim pathogen.vim
```

所以 pathogen 插件本身不必安装在 `bundle/` 目录中，`bundle/` 只是它用来管理其
他后续安装的第三方插件。如果不想混在个人用户目录中，pathogen 可以安装在任意合
适的地方，只要在 `vimrc` 将其加入 `&rtp` 或如上例做个软链接。

## 10.2.3 vundle 与 vim-plug

pathogen 在管理 `&rtp` 方面简单、易用，且高效、少依赖。只有一个缺点，那就是还
得手动下载每一个插件。如果连这步也想偷懒，那还有另一类插件管理工具可用，如下几
个都支持自动下载插件：

* [https://github.com/VundleVim/Vundle.vim](https://github.com/VundleVim/Vundle.vim)
* [https://github.com/junegunn/vim-plug](https://github.com/junegunn/vim-plug)
* [https://github.com/Shougo/dein.vim](https://github.com/Shougo/dein.vim)

其中，Vundle 出现较早，自动安装的插件默认也放在 `~/.vim/bundle` 目录，只不过需
要在 `vimrc` 中用 `:Plugin` 命令指定要使用的插件。现在基本推荐使用 vim-plug 代
替 Vundle ，用法类似，只不过使用更短的 `:Plug` 命令，而且支持并行下载，所以首
次安装插件的速度大大增快。dein.vim 管理插件则不提供命令，要求直接使用
`dein#add()` 函数，并且插件安装目录默认不放在 `~/.vim/bundle` 了。

这里仅以 vim-plug 为例介绍其用法。它只有单脚本文件，官方建议安装到
`~/.vim/autoload/plug.vim` 中。但正如 `pathogen.vim` 一样，你可以放到其他位置
，只是首先在手动维护这个插件管理的插件本身的 `&rtp` 路径。然后在 `vimrc` 进行
类似如下的配置：

```vim
call plug#begin('~/.vim/bundle')
Plug 'author1/plugin-name1'
Plug 'author2/plugin-name2'
call plug#end()
```

显然，`plug#bigin()` 与 `plug#end()` 是来自 `autoload/plug.vim` 脚本的函数，用
于该插件管理工具进行内部初始化等维护工作，其中 `plugin#begin()` 函数可指定插件
安装目录。然后在这两个函数调用之间，使用 `:Plug` 命令配置每个需要使用的插件。
参数格式 `author1/plugin-name1` 表示来源于
`https://github.com/author1/plugin-name1` 的插件。`:Plug` 还支持可选的其他参数
，比如用于配置复杂插件下载后可能需要进行的编译命令，这就不展开了。

在 vim 启动时，vim-plug 会分析 `vimrc` 配置的插件列表，如果插件尚未安装，则会
自动安装，并打开一个友好的窗口显示下载进度及其他管理命令。如果在 vim 运行时编
辑了 `vimrc` ，修改了插件列表，并不建议重新 `:source $MYVIMRC` ，而是可以手动
使用 `:PlugInstall` 命令安装插件。一般只有在修改了插件列表配置后首次启动 vim
时才会触发自动下载的动作，当然下载速度取决于个人的网络环境，不过由于它的并行下
载，横向对比其他插件管理工具的下载速度要快。在安装完插件之后启动 vim 显然就几
乎不会影响启动过程了。当然需要更新已安装插件时，可用 `:PlugUpdate` 命令。

vim-plug 这类插件管理工具的最大优点是功能丰富，不仅维护插件的 `&rtp` 路径，还
集成了插件的下载安装。当插件来源于 github 时，使得插件安装过程对于用户极其方便
。相比于 `pathogen` ，它不仅是替用户偷懒免去手动下载过程，更简化了用户移植个人
vim 配置。比如想将自己的 vim 配置环境从一台机器挪到另一台机器，那只要备份
`vimrc` 而已（或 `~/.vim` 目录），而插件列表内置在 `vimrc` 中，可不必另外备份
，在新机器上首次启动 vim 时自动安装。

## 10.2.4 Vim8 内置的 packadd

从 Vim8 版本开始，也提供了自己的一套新的插件管理方案，取代曾经昙花一现的 vimball
安装方式。核心命令是 `:packadd` ，而方案的名词概念叫 `package` ，可用 `:help`
命令查看详细帮助文档。

Vim8 内置的插件管理在思想上更接近 pathogen ,就连 pathogen 的作者也在该项目主页
上推荐新用户使用 Vim8 的内置管理方案了。因为这更符合 Vim 一贯以来的 Unix 思维
，集中做好一件事。从 Vim 的角度，插件管理就只要维护好每个插件的 `&rtp` 路径就
尽职了。至于插件是怎么来的，怎么下载安装的，是用 `git clone` 还是 `svn co` ，
或是手动下载再解压，再或是用户自己在本地写的…… Vim 全不管，它只要求你把插件放
到指定的目录，就如一开始规定得把（广义的插件）脚本放在 `plugin/` 目录一样。

事实上，之前的 vimball 就是 Vim 曾经试图介入用户安装插件过程的一种尝试。但是
vimball 没有成功推广，仅管那方案有可取之处。所以 Vim8 汲取经验教训，package 方
案不再纠结用户安装插件的事了，用户爱怎么折腾就怎么折腾。

现在，就来具体地介绍 package 方案如何做插件何管理的工作。如果将 pathogen 管理的
插件迁移到 Vim8 的 package ，可用如下命令：

```bash
$ mkdir -p ~/.vim/pack/bundle/start
$ mv ~/.vim/bundle/* ~/.vim/pack/bundle/start/  # 移动 bundle 目录
$ ls -s  ~/.vim/pack/bundle/start ~/.vim/bundle # 为兼容原目录名，建个软链接
```

这里，`~/.vim/pack` 叫做一个 `&packpath` 。那也是 Vim8 新增的一个选项，意义与
`&runtimepath` 或 `&path` 类似，是一个以逗号分隔的目录列表。

我们将 `packpath` 译为包路径，其下的每个子目录叫做一个“包”（package），每个包
下面可以有多个插件（plugin）。如果包内的插件设计为需要在 vim 启动时就加载，就
将这类插件放在包下面的 `start/` 子目录中，如果不想在 vim 启动时就加载，就将插
件放在包下面的 `opt/` 子目录中。此后，在 vim 运行时，可以用 `:packadd` 命令将
放在包下面的 `opt/` 类插件按需求再加载起来（直接在命令行手动输入 `:packadd` 命
令，或在 VimL 脚本中调用该命令）。

也就是说，在 vim 启动时，会搜索 `~/.vim/pack/*/start/*` ，将找到的每个目录都认
为是一个标准插件目录，加入 `&rtp` 列表并加载执行每个 `plugin/*.vim` 脚本。当使
用 `:packadd plug-name` 时，就搜索 `~/.vim/pack/*/opt/plug-name/` 目录，如果找
到，则将其加入 `&rtp` 并加载其下 `plugin/*.vim` 脚本。然后，`&packpath` 也不一定
只有 `~/.vim/pack/` 一个目录，用户可另外设置或增加包路径。

Vim8 将插件分为 `start/` 与 `opt/` 两类，这是容易理解的。因为 vim 要优化启动速
度，允许用户决定哪些插件得在启动加载，哪些可稍后动态加载。那为何又要在这之上再
加个包的概念呢。那估计是前瞻性考虑了，预计将来 vim 用户普遍会安装很多插件，于
是可以进一步将某些相关插件放在一个包内，以便管理。

对用户来说，如何使用包呢？如果从 github 下载的插件，很容易对应，就将作者名作为
包名，于是该作者的所有插件都归于一个包。不过对个人用户来说，极可能只会用到某个
作者的一个插件，并不会对他的所有插件都感兴趣；况且作者本身也可能只会公布少数一
到两个 vim 插件。这样，每个包下面的插件数量太少，又似乎失去了包的初衷意义，而
且包下面深层次目录只有一个子目录，利用率低，不太“美观”。

于是另有一个思路是根据插件功能来划分包名。想探寻某个功能，找到了几个来自不同作
者开发的插件，各有优劣与适用场景，或者就是要多个插件配合使用，那就可以将其归于
一个包。例如，上面介绍的插件管理插件，出于研究目的，可以都将其下载了，统一放在
名为 `plug-manager` 的包内：

```bash
$ mkdir -p ~/.vim/pack/plug-manager
$ cd ~/.vim/pack/plug-manager
$ mkdir opt
$ cd opt
$ git clone https://github.com/tpope/vim-pathogen
$ git clone https://github.com/VundleVim/Vundle.vim
$ git clone https://github.com/junegunn/vim-plug
$ git clone https://github.com/Shougo/dein.vim
```

显然，这些插件应该归于 `opt/` 类，不能在启动时加载。

事实上，对个人用户而言，始终建议将下载的第三方插件安装在 `opt/` 子目录下。否则
，启动时自动加载的 `start/` 插件可能太分散，也不利于维护。自己写的插件，放在
`start/` 相对来说更为稳妥可信，但为了统一，也建议就放 `opt/` 。确定需要启动加
载的，就在 `vimrc` 中显式地用 `:packadd` 列出来。或者可以将这样的一份插件列表
单独放在 `~/.vim/plugin/loadpack.vim` 脚本中：

```vim
packadd plugin-name1
packadd plugin-name2
...
```

可见，这样的一份插件列表，就很接近 vim-plug 管理工具要求的 `:Plug` 配置列表了
，只是没有下载功能而已。也许将来，会有配合内置 package 的插件管理工具，用来增
补自动下载的功能，供用户多个选择。

只是 package 方案出炉略晚，很多用户已经习惯了 vim-plug 这类的插件管理方式，短
时间内不会转到内置 package 来。但是之前 pathogen 的用户，强烈建议改用 package 包管
理机制。
