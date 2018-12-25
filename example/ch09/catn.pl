#! /usr/bin/env perl
# 为文本行编号，按标准输入输出，适于 vim 过滤器
# 可选参数一指定分隔符，参数二指定间隔空白量（默认一个 tab）

my $sep = shift || "";
my $num = shift || 0;
$sep .= ($num > 0) ? (" " x $num) : "\t";
while (<>) { print "$.$sep$_"; }
