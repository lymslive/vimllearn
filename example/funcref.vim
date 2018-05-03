function! Sum(x, y, ...)
    let l:sum = a:x + a:y
    for l:arg in a:000
        let l:sum += l:arg
    endfor
    return l:sum
endfunction

function! Prod(x, y, ...)
    let l:prod = a:x * a:y
    for l:arg in a:000
        let l:prod = l:prod * l:arg
    endfor
    return l:prod
endfunction

function! CalculateR(operator, ...)
    if a:operator ==# '+'
        let l:Fnr = function('Sum')
    elseif a:operator ==# '*'
        let l:Fnr = function('Prod')
    endif

    let l:result = call(l:Fnr, a:000)
    return l:result
endfunction

let s:fnrSum = function('Sum')
let s:fnrProd = function('Prod')

function! CalculateRs(operator, ...)
    if a:operator ==# '+'
        let l:Fnr = s:fnrSum
    elseif a:operator ==# '*'
        let l:Fnr = s:fnrProd
    endif

    let l:result = call(l:Fnr, a:000)
    return l:result
endfunction

function! s:sum(...)
    let l:sum = 0
    for l:arg in a:000
        let l:sum += l:arg
    endfor
    return l:sum
endfunction

function! s:prod(...)
    let l:prod = 1
    for l:arg in a:000
        let l:prod = l:prod * l:arg
    endfor
    return l:prod
endfunction

let s:fnrSum = function('s:sum')
let s:fnrProd = function('s:prod')

echo s:fnrSum(1,2,3,4)
echo s:fnrProd(1,2,3,4)

" let s:sum = function('s:sum')
" let s:prod = function('s:prod')

let s:sum = '1+2+3+4'
let s:prod = '1*2*3*4'

echo s:sum(1,2,3,4)
echo s:prod(1,2,3,4)

" 将函数引用保存在列表中
let s:operator = [function('s:sum'), function('s:prod')]
function! CalculateA(...)
    for l:Operator in s:operator
        let l:result = call(l:Operator, a:000)
        echo l:result
    endfor
endfunction

" 将函数引用保存在字典中
let s:dOperator = {'desc': 'some function on varargins'}
let s:dOperator['+'] = function('s:sum')
let s:dOperator['*'] = function('s:prod')

function! CalculateD(operator, ...) abort
    let l:Fnr = s:dOperator[a:operator]
    let l:result = call(l:Fnr, a:000)
    return l:result
endfunction

" 保存在成员键中
let s:dOperator.sumFnr = s:dOperator['+']
let s:dOperator.prodFnr = s:dOperator['*']
echo s:dOperator.sumFnr(1, 2, 3, 4)
echo s:dOperator.prodFnr(1, 2, 3, 4)

" 直接定义函数键
function s:dOperator.sum(...)
    let l:sum = 0
    for l:arg in a:000
        let l:sum += l:arg
    endfor
    return l:sum
endfunction

function! s:dOperator.prod(...)
    let l:prod = 1
    for l:arg in a:000
        let l:prod = l:prod * l:arg
    endfor
    return l:prod
endfunction

echo s:dOperator.sum(1, 2, 3, 4)
echo s:dOperator.prod(1, 2, 3, 4)

" 不能将字典函数引用赋值给普通函数引用
" let g:Fnr = s:dOperator.sum
" echo g:Fnr(1,2,3,4)

" 合法
let g:Fnr = s:dOperator.sumFnr
echo g:Fnr(1,2,3,4)

let s:dOperator.PI = 3.14
function! s:dOperator.area(r)
    return self.PI * a:r * a:r
endfunction

echo s:dOperator.area(2)

let s:Math = {}
let s:Math.PI = 3.14159
let s:Math.Area = s:dOperator.area
echo s:Math.Area(2)

" let g:Fnr = s:dOperator.area
" echo g:Fnr(2)

function! s:area(width, height) dict
    return a:width * a:height
endfunction

" echo s:area(3, 4) |" 出错
echo call('s:area', [5, 6], {})
" echo call('s:area', [5, 6])

let s:Rect = {}
let s:Rect.area = function('s:area')
echo s:Rect.area(3, 4) |" 正确

function! s:area() dict
    return self.width * self.height
endfunction

let s:Rect.width = 3
let s:Rect.height = 4
echo s:Rect.area()

echo call('s:area', [], s:Rect)
echo call(function('s:area'), [], s:Rect)

" 调试信息观察

function! s:Rect.debug1() dict abort
    echo expand('<sfile>')
    Hello Vim, 我在这里就是个错误
endfunction

function! s:debug2() abort
    echo expand('<sfile>')
    Hello Vim, 我来这里也是个错误
endfunction
let s:Rect.debug2 = function('s:debug2')

function! s:Rect.test() dict " abort
    echo expand('<sfile>')
    call self.debug1()
    call self.debug2()
endfunction

function! s:test() abort
    echo expand('<sfile>')
    call s:Rect.test()
endfunction

function! Test() abort
    echo expand('<sfile>')
    call s:test()
endfunction

echo expand('<sfile>')

" echo s:
