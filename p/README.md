# VimLScriptGuide文档说明

### VimLScriptGuide是什么？
VimLScriptGuide.pdf是作者[lymslive](https://github.com/lymslive/vimllearn)写的VimL教程md文件的pdf版本，著作权归原作者所有。

### 如何将多个md文件合并为pdf
本文件是在Linux下结合pandoc和texlive，由md文件转换得到。

步骤：
- 利用cat命令将所有md文件追加到一个文件，如VimLScriptGuide.md。  
 > $ cat *.md >> VimLScriptGuide.md 
- 使用pandoc转换  
 > $ pandoc --latex-engine=xelatex -V mainfont="SimSun" VimLScriptGuide.md -o VimLScriptGuide.pdf  
 > \# xelatex是texlive的一个引擎，可处理中文。\# SimSum是宋体，也可使用其他字体如SimHei(黑体）。
- 时间：15s左右。
- 系统：Ubuntu 18.04 LTS 

### 依赖：
- pandoc [文档转换神器](https://github.com/jgm/pandoc)
- texlive 可参考这篇文章[安装](https://blog.csdn.net/Shieber/article/details/93716448)

### 其他：
Linux/Mac OS/Windows下还可使用Atom编辑器自带的markdown转pdf插件将合并后的md转换为pdf，
快捷键是Ctrl+Shift+E。
