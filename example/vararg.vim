function! UseVarargin(named, ...)
    echo 'named argin: ' . string(a:named)

    if a:0 >= 1
        echo 'first varargin: ' . string(a:1)
    endif
    if a:0 >= 2
        echo 'second varargin: ' . string(a:2)
    endif

    echo 'have varargin: ' . a:0
    for l:arg in a:000
        echo 'iterate varargin: ' . string(l:arg)
    endfor
endfunction

function! Join(list, ...)
    if a:0 > 0
        let l:sep = a:1
    else
        let l:sep = ','
    endif
    return join(a:list, l:sep)
endfunction

function! Calculate(operator, ...)
    echo Join(a:000, a:operator)
    if a:operator ==+ '+'
        " let l:result = Sum(...)
    elseif a:operator ==# '*'
        " let l:result = Prod(...)
    endif
    return l:result
endfunction

function! Calculate(operator, ...)
    if a:0 < 2
        echoerr 'expect at leat 2 operand'
        return
    endif

    echo Join(a:000, a:operator)
    if a:operator ==+ '+'
        let l:result = call('Sum', a:000)
    elseif a:operator ==# '*'
        let l:result = call('Prod', a:000)
    endif

    return l:result
endfunction
