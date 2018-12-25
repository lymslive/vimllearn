
call vip#config#load()

" map 映射定义
" command 命令定义，调用其他 vip# 函数

augroup VIP_FILETYPE
    autocmd!
    autocmd BufNewFile,BufRead *.vip,*.vip.txt setlocal filetype=vip
augroup END

function! vip#plugin#load()
    return 1
endfunction
