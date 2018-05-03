" File: ~/.vim/vimllearn/frange.vim

function! NumberLine() abort
    let l:sLine = getline('.')
    let l:sLine = line('.') . ' ' . l:sLine
    call setline('.', l:sLine)
endfunction

function! NumberLine2() abort range
    for l:line in range(a:firstline, a:lastline)
        let l:sLine = getline(l:line)
        let l:sLine = l:line . ' ' . l:sLine
        call setline(l:line, l:sLine)
    endfor
endfunction

finish

测试行
测试行
测试行
测试行
测试行
