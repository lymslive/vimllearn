
function! OnWorking(job, msg)
    echomsg 'well work doing:' . a:msg
    let g:dir_list .= a:msg . "\n"
endfunction

function! DoneWork(job)
    echomsg 'well work done:'
    echomsg g:dir_list
    " echo g:dir_list
endfunction

function! StartWork()
    let g:dir_list = ''
    let l:option = {'callback': 'OnWorking', 'close_cb': 'DoneWork'}
    let g:job_ls = job_start('ls', l:option)
endfunction
