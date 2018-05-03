
if !exists('s:load_first')
    command -nargs=* MYcmd  call DT_foo(<f-args>)
    nnoremap <F12> :call DT_foo()<CR>
    execute 'autocmd FuncUndefined DT_* source ' . expand('<sfile>')
    let s:load_first = 1
    finish
endif

if exists('s:load_second')
    finish
endif

function! DT_foo() abort
    " TODO:
endfunction
function! DT_bar() abort
    " TODO:
endfunction

let s:load_second = 1

execute 'autocmd FuncUndefined *#*  call MyAutoFunc()'

function! MyAutoFunc() abort
    echo 'in MyAutoFunc()'
    " TODO:
    source ~/.vim/vimllearn/autoload/delaytwice.vim
endfunction
