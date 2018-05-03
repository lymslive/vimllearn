: function! Foo() abort
:     echomsg 'before error'
:     echomsg error
:     echomsg 'after error'
: endfunction
:
: echomsg 'before call Foo()'
: call Foo()
: echomsg 'after call Foo()'

