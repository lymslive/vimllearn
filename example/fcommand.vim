" File: ~/.vim/vimllearn/fcommand.vim

function! NumberLine() abort range
    for l:line in range(a:firstline, a:lastline)
        let l:sLine = getline(l:line)
        let l:sLine = l:line . ' ' . l:sLine
        call setline(l:line, l:sLine)
    endfor
endfunction

command! -range=% NumberLine call NumberLine()

function! NumberRelate(count) abort
    let l:cursor = line('.')
    let l:eof = line('$')
    for l:count in range(0, a:count)
        let l:line  = l:cursor + l:count
        if l:line > l:eof
            break
        endif
        let l:sLine = getline(l:line)
        let l:sLine = l:count . ' ' . l:sLine
        call setline(l:line, l:sLine)
    endfor
endfunction

command! -count NumberRelate call NumberRelate(<count>)
finish

测试行
测试行
测试行
测试行
测试行
