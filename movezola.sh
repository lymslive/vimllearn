#!/bin/bash
# 重构目录结构，以适应 zola book 要求

mkdir content
cd content

##################################################

chapter=ch00-prefcace
mkdir ${chapter}
cat << EOF > ${chapter}/_index.md
+++
title = "前言"
weight = 0
sort_by = "weight"
+++
EOF
cat ../z/20170816_1.md >> ${chapter}/_index.md

##################################################

chapter=ch01-viml-feature
mkdir ${chapter}
cat << EOF > ${chapter}/_index.md
+++
title = "第一章 VimL 语言主要特点"
weight = 1
sort_by = "weight"
+++
EOF
cat << EOF >> ${chapter}/_index.md
# 第一章 VimL 语言主要特点
基础篇包括第一章至第三章。
EOF

section=sn1-hello-world
cat << EOF > ${chapter}/${section}.md
+++
title = "1.1 Hello World 的四种写法"
weight = 1
+++
EOF
cat ../z/20170816_2.md >> ${chapter}/${section}.md

section=sn2-from-ex-command
cat << EOF > ${chapter}/${section}.md
+++
title = "1.2 同源 ex 命令行"
weight = 2
+++
EOF
cat ../z/20170816_3.md >> ${chapter}/${section}.md

section=sn3-week-type-strong-scope
cat << EOF > ${chapter}/${section}.md
+++
title = "1.3 弱类型强作用域"
weight = 3
+++
EOF
cat ../z/20170816_4.md >> ${chapter}/${section}.md

section=sn4-autoload-schema
cat << EOF > ${chapter}/${section}.md
+++
title = "1.4 自动加载脚本机制"
weight = 4
+++
EOF
cat ../z/20170816_5.md >> ${chapter}/${section}.md

##################################################

chapter=ch02-viml-grammar
mkdir ${chapter}
cat << EOF > ${chapter}/_index.md
+++
title = "第二章 VimL 语言基本语法"
weight = 2
sort_by = "weight"
+++
EOF
cat << EOF >> ${chapter}/_index.md
# 第二章 VimL 语言基本语法
EOF

section=sn1-variable-type
cat << EOF > ${chapter}/${section}.md
+++
title = "2.1 变量与类型"
weight = 1
+++
EOF
cat ../z/20170817_1.md >> ${chapter}/${section}.md

section=sn2-comapare-condition
cat << EOF > ${chapter}/${section}.md
+++
title = "2.2 选择与比较"
weight = 2
+++
EOF
cat ../z/20170817_2.md >> ${chapter}/${section}.md

section=sn3-loop-iterate
cat << EOF > ${chapter}/${section}.md
+++
title = "2.3 循环与迭代"
weight = 3
+++
EOF
cat ../z/20170817_3.md >> ${chapter}/${section}.md

section=sn4-function-call
cat << EOF > ${chapter}/${section}.md
+++
title = "2.4 函数定义与使用"
weight = 4
+++
EOF
cat ../z/20170817_4.md >> ${chapter}/${section}.md

section=sn5-exception-error
cat << EOF > ${chapter}/${section}.md
+++
title = "2.5 异常处理"
weight = 5
+++
EOF
cat ../z/20170817_5.md >> ${chapter}/${section}.md

##################################################

chapter=ch03-viml-command
mkdir ${chapter}
cat << EOF > ${chapter}/_index.md
+++
title = "第三章 Vim 常用命令"
weight = 3
sort_by = "weight"
+++
EOF
cat << EOF >> ${chapter}/_index.md
# 第三章 Vim 常用命令
EOF

section=sn1-option-set
cat << EOF > ${chapter}/${section}.md
+++
title = "3.1 选项设置"
weight = 1
+++
EOF
cat ../z/20170818_1.md >> ${chapter}/${section}.md

section=sn2-key-remap
cat << EOF > ${chapter}/${section}.md
+++
title = "3.2 快捷键重映射"
weight = 2
+++
EOF
cat ../z/20170818_2.md >> ${chapter}/${section}.md

section=sn3-custom-command
cat << EOF > ${chapter}/${section}.md
+++
title = "3.3 自定义命令"
weight = 3
+++
EOF
cat ../z/20170818_3.md >> ${chapter}/${section}.md

section=sn4-execute-normal
cat << EOF > ${chapter}/${section}.md
+++
title = "3.4 execute 与 normal"
weight = 4
+++
EOF
cat ../z/20170818_4.md >> ${chapter}/${section}.md

section=sn5-autocmd-event
cat << EOF > ${chapter}/${section}.md
+++
title = "3.5 自动命令与事件"
weight = 5
+++
EOF
cat ../z/20170818_5.md >> ${chapter}/${section}.md

section=sn6-debug-command
cat << EOF > ${chapter}/${section}.md
+++
title = "3.6 调试命令"
weight = 6
+++
EOF
cat ../z/20170818_6.md >> ${chapter}/${section}.md

##################################################

chapter=ch04-viml-datastruct
mkdir ${chapter}
cat << EOF > ${chapter}/_index.md
+++
title = "第四章 VimL 数据结构进阶"
weight = 4
sort_by = "weight"
+++
EOF
cat << EOF >> ${chapter}/_index.md
# 第四章 VimL 数据结构进阶
中级篇包括第四章至第七章。
EOF

section=sn1-list-string
cat << EOF > ${chapter}/${section}.md
+++
title = "4.1 再谈列表与字符串"
weight = 1
+++
EOF
cat ../z/20170819_1.md >> ${chapter}/${section}.md

section=sn2-dictionary
cat << EOF > ${chapter}/${section}.md
+++
title = "4.2 通用的字典结构"
weight = 2
+++
EOF
cat ../z/20170819_2.md >> ${chapter}/${section}.md

section=sn3-nest-compose
cat << EOF > ${chapter}/${section}.md
+++
title = "4.3 嵌套组合与扩展"
weight = 3
+++
EOF
cat ../z/20170819_3.md >> ${chapter}/${section}.md

section=sn4-regex-apply
cat << EOF > ${chapter}/${section}.md
+++
title = "4.4 正则表达式"
weight = 4
+++
EOF
cat ../z/20170922_1.md >> ${chapter}/${section}.md

##################################################

chapter=ch05-viml-function
mkdir ${chapter}
cat << EOF > ${chapter}/_index.md
+++
title = "第五章 VimL 函数进阶"
weight = 5
sort_by = "weight"
+++
EOF
cat << EOF >> ${chapter}/_index.md
# 第五章 VimL 函数进阶
EOF

section=sn1-variable-argument
cat << EOF > ${chapter}/${section}.md
+++
title = "5.1 可变参数"
weight = 1
+++
EOF
cat ../z/20170819_4.md >> ${chapter}/${section}.md

section=sn2-function-refer
cat << EOF > ${chapter}/${section}.md
+++
title = "5.2 函数引用"
weight = 2
+++
EOF
cat ../z/20170819_5.md >> ${chapter}/${section}.md

section=sn3-dict-function
cat << EOF > ${chapter}/${section}.md
+++
title = "5.3 字典函数"
weight = 3
+++
EOF
cat ../z/20170819_6.md >> ${chapter}/${section}.md

section=sn4-closure-lambda
cat << EOF > ${chapter}/${section}.md
+++
title = "5.4 闭包函数"
weight = 4
+++
EOF
cat ../z/20171023_1.md >> ${chapter}/${section}.md

section=sn5-autoload-function
cat << EOF > ${chapter}/${section}.md
+++
title = "5.5 自动函数"
weight = 5
+++
EOF
cat ../z/20171028_1.md >> ${chapter}/${section}.md

##################################################

chapter=ch06-builtin-function
mkdir ${chapter}
cat << EOF > ${chapter}/_index.md
+++
title = "第六章 VimL 内建函数使用"
weight = 6
sort_by = "weight"
+++
EOF
cat << EOF >> ${chapter}/_index.md
# 第六章 VimL 内建函数使用
EOF

section=sn1-operate-datatype
cat << EOF > ${chapter}/${section}.md
+++
title = "6.1 操作数据类型"
weight = 1
+++
EOF
cat ../z/20170821_1.md >> ${chapter}/${section}.md

section=sn2-operate-edit-object
cat << EOF > ${chapter}/${section}.md
+++
title = "6.2 操作编辑对象"
weight = 2
+++
EOF
cat ../z/20170821_2.md >> ${chapter}/${section}.md

section=sn3-operate-filesystem
cat << EOF > ${chapter}/${section}.md
+++
title = "6.3 操作系统文件"
weight = 3
+++
EOF
cat ../z/20170821_3.md >> ${chapter}/${section}.md

section=sn4-other-utility
cat << EOF > ${chapter}/${section}.md
+++
title = "6.4 其他实用函数"
weight = 4
+++
EOF
cat ../z/20170821_4.md >> ${chapter}/${section}.md

##################################################

chapter=ch07-object-program
mkdir ${chapter}
cat << EOF > ${chapter}/_index.md
+++
title = "第七章 VimL 面向对象编程"
weight = 7
sort_by = "weight"
+++
EOF
cat << EOF >> ${chapter}/_index.md
# 第七章 VimL 面向对象编程
EOF

section=sn1-object-intro
cat << EOF > ${chapter}/${section}.md
+++
title = "7.1 面向对象的简介"
weight = 1
+++
EOF
cat ../z/20170821_5.md >> ${chapter}/${section}.md

section=sn2-dict-object
cat << EOF > ${chapter}/${section}.md
+++
title = "7.2 字典即对象 "
weight = 2
+++
EOF
cat ../z/20170821_6.md >> ${chapter}/${section}.md

section=sn3-object-organize
cat << EOF > ${chapter}/${section}.md
+++
title = "7.3 自定义类的组织管理"
weight = 3
+++
EOF
cat ../z/20170821_7.md >> ${chapter}/${section}.md

##################################################

chapter=ch08-viml-asynchronous
mkdir ${chapter}
cat << EOF > ${chapter}/_index.md
+++
title = "第八章 VimL 异步编程特性"
weight = 8
sort_by = "weight"
+++
EOF
cat << EOF >> ${chapter}/_index.md
# 第八章 VimL 异步编程特性
高级篇包括第八章至第十章
EOF

section=sn1-asynchronous-intro
cat << EOF > ${chapter}/${section}.md
+++
title = "8.1 异步工作简介"
weight = 1
+++
EOF
cat ../z/20181121_1.md >> ${chapter}/${section}.md

section=sn2-asynchronous-job
cat << EOF > ${chapter}/${section}.md
+++
title = "8.2 使用异步任务"
weight = 2
+++
EOF
cat ../z/20181205_1.md >> ${chapter}/${section}.md

section=sn3-channle-job
cat << EOF > ${chapter}/${section}.md
+++
title = "8.3 使用通道控制任务"
weight = 3
+++
EOF
cat ../z/20181210_1.md >> ${chapter}/${section}.md

section=sn4-internal-terminal
cat << EOF > ${chapter}/${section}.md
+++
title = "8.4 使用配置内置终端"
weight = 4
+++
EOF
cat ../z/20181212_1.md >> ${chapter}/${section}.md

##################################################

chapter=ch09-viml-mix-program
mkdir ${chapter}
cat << EOF > ${chapter}/_index.md
+++
title = "第九章 VimL 混合编程"
weight = 9
sort_by = "weight"
+++
EOF
cat << EOF >> ${chapter}/_index.md
# 第九章 VimL 混合编程
EOF

section=sn1-extern-filter
cat << EOF > ${chapter}/${section}.md
+++
title = "9.1 用外部语言写过滤器"
weight = 1
+++
EOF
cat ../z/20181215_1.md >> ${chapter}/${section}.md

section=sn2-extern-interface
cat << EOF > ${chapter}/${section}.md
+++
title = "9.2 外部语言接口编程"
weight = 2
+++
EOF
cat ../z/20181215_2.md >> ${chapter}/${section}.md

section=sn3-perl-interface
cat << EOF > ${chapter}/${section}.md
+++
title = "9.3 Perl 语言接口开发"
weight = 3
+++
EOF
cat ../z/20181217_2.md >> ${chapter}/${section}.md

##################################################

chapter=ch10-viml-plugin-develop
mkdir ${chapter}
cat << EOF > ${chapter}/_index.md
+++
title = "第十章 Vim 插件管理与开发"
weight = 10
sort_by = "weight"
+++
EOF
cat << EOF >> ${chapter}/_index.md
# 第十章 Vim 插件管理与开发
EOF

section=sn1-plugin-directory
cat << EOF > ${chapter}/${section}.md
+++
title = "10.1 典型插件的目录规范"
weight = 1
+++
EOF
cat ../z/20181219_1.md >> ${chapter}/${section}.md

section=sn2-plugin-manager
cat << EOF > ${chapter}/${section}.md
+++
title = "10.2 插件管理器插件介绍"
weight = 2
+++
EOF
cat ../z/20181219_2.md >> ${chapter}/${section}.md

section=sn3-plugin-devflow
cat << EOF > ${chapter}/${section}.md
+++
title = "10.3 插件开发流程指引"
weight = 3
+++
EOF
cat ../z/20181219_3.md >> ${chapter}/${section}.md

##################################################

chapter=chA1-postfcace
mkdir ${chapter}
cat << EOF > ${chapter}/_index.md
+++
title = "结语"
weight = 90
sort_by = "weight"
+++
EOF
cat << EOF >> ${chapter}/_index.md
# 结语
诚然，VimL 是个众语言，中文的教程书籍资料更是稀缺，故笔者不惮用爱发电，
将个人在钻研使用 VimL 开发插件过程的实践经验，整理成章。冀望对后来同好者
有所启迪与助益。
EOF

##################################################
