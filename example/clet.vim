" File: ~/.vim/vimllearn/clet.vim
" custom VimL grammar command

function! ParseLet(args)
    let l:lsMatch = split(a:args, '\s*=\s*')
    if len(l:lsMatch) < 2
        return ''
    endif
    let l:value = remove(l:lsMatch, -1)
    let l:lsCmd = []
    for l:var in l:lsMatch
        let l:cmd = 'let ' . l:var . ' = ' . l:value
        call add(l:lsCmd, l:cmd)
    endfor
    return join(l:lsCmd, ' | ')
endfunction

command! -nargs=+ LET execute ParseLet(<q-args>)

function! TestLet()
    LET l:x = y = z = 'abc'
    echo 'l:x =' l:x 'x =' x
    echo 'l:y =' l:y 'y =' y
    echo 'l:z =' l:z 'z =' z
endfunction
call TestLet()
echo 'x =' x 'y =' y 'z =' z

function! ParseBreak(args)
    if empty(a:args)
        return 'break'
    endif
    let l:cmd = 'if ' . a:args
    let l:lsCmd = [l:cmd, 'break', 'endif']
    return join(l:lsCmd, ' | ')
    " return join(l:lsCmd, "\n")
endfunction

command! -nargs=+ BREAKIF execute ParseBreak(<q-args>)

for i in range(10)
    BREAKIF i >= 5
    if i >= 5 | break | endif
    echo i
endfor
" break 用 execute 有问题
