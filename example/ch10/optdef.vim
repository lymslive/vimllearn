if !exists('g:plugin_name_argument')
    let g:plugin_name_argument = s:default_argument_value
endif

function! s:optdef(argument, default)
    if !has_key(g:, a:argument)
        let g:{a:argument} = a:default
    end
endfunction
