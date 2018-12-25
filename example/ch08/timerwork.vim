function! SlowWork()
    call timer_start(5*1000, 'DoneWork')
endfunction

function! DoneWork(timer)
    echo "done!!"
endfunction

call SlowWork()
