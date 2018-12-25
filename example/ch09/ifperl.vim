
function! s:execute(a:code) abort
    let l:perl = 'perl ' .  a:code
    let l:ifstdout = ''
    let v:errmsg = ''
    redir => l:ifstdout
    silent! execute l:perl
    redir END
    if v:errmsg
        return ''
    endif
    return l:ifstdout
endfunction

function! s:call(func, ...) abort
    let l:args = join(a:000, ',')
    let l:code = printf('%s(%s);', a:func, l:args)
    return s:execute(l:code)
endfunction
