function! Foo()
    let x = 0
    function! Bar() closure
        let x += 1
        return x
    endfunction
    return funcref('Bar')
endfunction

function! Goo()
    let x = 0
    function! Bar() closure
        let x += 2
        return x
    endfunction
    return function('Bar')
endfunction

" funcref 与 function 都有效
" Bar() 也是全局函数

echo 'Fn = Foo()'
let Fn = Foo()
echo Fn()
echo Fn()
echo Bar()
echo Fn()

" 交替使用有效
echo 'Gn = Foo()'
let Gn = Goo()
echo Gn()
echo Gn()
echo Bar()
echo Gn()

function! Bar() 
    return 'Bar() redefined'
endfunction

echo Bar()
echo Fn()
echo Gn()

"
" 重定义对 function() 有影响，对 funcref() 影响

" 对比 s: 变量与函数
"
let s:x = 0
function! s:Bar() " closure 不能放在顶层 E932
    let s:x += 1
    return s:x
endfunction

echo 's:Bar()'
echo s:Bar()
echo s:Bar()
echo s:Bar()

" 工厂函数
" 闭包独立性
"
function! FGoo(base)
    let x = a:base
    function! Bar1_cf() closure
        let x += 1
        return x
    endfunction
    function! Bar2_cf() closure
        let x += 2
        return x
    endfunction
    return [funcref('Bar1_cf'), funcref('Bar2_cf')]
endfunction

echo 'FGoo(base)'
let [Fn, X_] = FGoo(10)
echo Fn()
echo Fn()
echo Fn()
let [X_, Gn] = FGoo(20)
echo Gn()
echo Gn()
echo Gn()
echo Fn()
echo Fn()

" 偏包引用
"
echo 'partial function reference'

function! Full(x, y, z)
    echo 'Full called:' a:x a:y a:z
endfunction

let Part = function('Full', [3, 4])
call Part(5)
echo Part
" call Part()
" call Part(3, 4, 5)

function! FullPartial()
    let x = 3
    let y = 4
    function! Part_cf(z) closure
        let z = a:z
        return Full(x, y, z)
    endfunction
    return funcref('Part_cf')
endfunction

let Part = FullPartial()
call Part(5)
echo Part

function! FuncPartial(fun, arg)
    " let l:arg_closure = a:arg
    function! Part_cf(...) closure
        " let l:arg_passing = a:000
        " let l:arg_all = l:arg_closure + l:arg_passing
        return call(a:fun, a:arg + a:000)
    endfunction
    return funcref('Part_cf')
endfunction

let Part = FuncPartial('Full', [3, 4])
call Part(5)
echo Part

" lambda 表达式
"
echo 'lambda expression'

if 1
function! Distance(point) abort
    let x = a:point[0]
    let y = a:point[1]
    return x*x + y*y
endfunction
else
    let Distance = {pt -> pt[0] * pt[0] + pt[1] * pt[1]}
endif

" echo Distance
echo Distance([3,4])

function! MaxDistance(A, B, C) abort
    let l:Distance = {pt -> pt[0] * pt[0] + pt[1] * pt[1]}
    let [A, B, C] = [a:A, a:B, a:C]
    let e1 = [A[0] - B[0], A[1] - B[1]]
    let e2 = [A[0] - C[0], A[1] - C[1]]
    let e3 = [B[0] - C[0], B[1] - C[1]]
    let d1 = Distance(e1)
    let d2 = l:Distance(e2)
    let d3 = Distance(e3)
    if d1 >= d2 && d1 >= d3
        return d1
    elseif d2 >= d1 && d2 >= d3
        return d2
    else
        return d3
    endif
endfunction

delfunction Distance
echo MaxDistance([2,8], [4,4], [5,10])

finish

"
" 在 MaxDistance 中调用 Distance lambda 时，须定义为局部函数引用变量
" 因 Distance() 调用只搜索 l:Distance 局部变量或全局函数，并不会搜索全局函数引
" 用变量
