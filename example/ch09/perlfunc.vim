if !has('perl')
    finish
endif

function! PerlFunc()
    if has('perl')
        perl << EOF
        print $^V; # 打印版本号
        print "$_\n" for @INC; # 打印所有模块搜索路径
        print "$_ = $ENV{$_}" for sort keys %ENV; # 打印所有环境变量
EOF
    endif
endfunction

if has('perl')

function! PerlFunc1()
    " todo
endfunction

function! PerlFunc2()
    " todo
endfunction

endif
