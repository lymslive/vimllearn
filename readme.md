# VimL 语言编程指北 [[繁](./readme_tw.md)]

<a rel="license" href="http://creativecommons.org/licenses/by-nc-nd/4.0/"><img alt="知识共享许可协议" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-nd/4.0/88x31.png" /></a>

本教程按技术书籍方式组织。书名叫“指北”而不是“指南”，主要是考虑有很多指南类书籍
讲 vim 这编辑器工具的使用，而本书则侧重于 VimL 这种脚本语言编程。

GitHub Page 在线阅读：
[https://lymslive.github.io/vimllearn](https://lymslive.github.io/vimllearn)

PDF 格式书籍下载：
[vim-script-guide-book-zh-cn.pdf](p/vim-script-guide-book-zh-cn.pdf)
感谢 @[QMHTMY](https://github.com/QMHTMY) 编译 pdf 版本及相关排版工作。

版权声明：基于知识共享协议。允许自由扩散，以及援用部分段落解说与示例代码。
但其他人不允许将整书或整章节用于商业性的出版或电子平台。

拥抱 github 开源社区。虽非软件项目，但 issue/fork/pr 等功能亦可使用。
欢迎反馈意见或文字纠错。源文件们于 `content/` 子目录。

本书引用的代码段示例都很短，按书照敲或复制也是一种学习方式。 `example/` 目录整
理了部分示例代码，但是建议以书内讲叙或外链接为准。作者自己在 linux 系统下以
vim8.1 版本测试，Windows 与低版本虽未全面测试，但相信 vim 本身的兼容性也基本适
用了。

<hr>

## 变更记录

初稿在本地我用自己的笔记插件 [vnote](https://github.com/lymslive/vnote) 写的，
保存在笔记本 [notebook](https://github.com/lymslive/notebook)。然后将这个较为
系统化的教程独立出来，进行后续的修改与调整。而原 notebook 仓库适合设为私有。

初稿在 `z/` 子目录，另有一页[目录](./content.md) 。

后来，选了个静态网站生成工具 [zola](https://github.com/getzola/zola) 编译为
html ，使用 gitbook 风格的主题，即 [book](https://www.getzola.org/themes/book/)。
此技术选型纯属个人口味，偏好 rust 而已。
因此将 `z/` 目录下的初稿 `.md` 文件，重命名、重组放在 `content/` 目录之下。
每个 `.md` 文件最前面加上了必要元数据头（Front matter），删除或注释了重复的章
节标题。
