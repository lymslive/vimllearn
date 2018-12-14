#! /usr/bin/env perl
# 从 vim 内置终端发送 drop 消息打开文件
# 传输的 json 消息必须用双引号 ""
use strict;
use warnings;

use Cwd 'abs_path';
my $filename = shift or die "usage: dorp filename";
my $filepath = abs_path($filename);
exec "vim $filepath" unless $ENV{VIM};
print qq{\x1B]51;["drop", "$filepath"]\x07};
