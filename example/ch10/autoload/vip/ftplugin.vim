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
