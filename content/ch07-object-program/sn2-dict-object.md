+++
title = "7.2 字典即对象 "
weight = 2
+++

<!-- ## 7.2 字典即对象 -->

字典是 VimL 中最复杂全能的数据结构，基于字典，几乎就能实现面向对象风格的编程。
在本章中，我们提到 VimL 中的一个对象时，其实就是指一个字典结构变量。

### 按对象属性方式访问字典键

首先要了解的是一个语法糖。一般来说，访问字典某一元素的索引方法与列表是类似的，
用中括号 `[]` 表示。只不过列表是用整数索引，字典是用字符串（称为字典的键）索引
。例如：

```vim
: echo aList[0]
: echo aDict['str']
```

（这里假设 `aList` 与 `aDict` 分别是已经定义的列表与字典变量）

如果字典的键是常量字符串，则在中括号中还得加引号，这写起来略麻烦。所以如果字典
键是简单字符串，则可以不用中括号与引号，而只用一个点号代替。例如：

```vim
: echo aDict.str
```

这就很像常规面向对象语言中访问对象属性的语法了。所谓简单字符串，就是指可作为标
识符的字符串（比如变量名）。例如：

```vim
: let aDict = {}
: let aDict['*any_key*'] = 1
: let aDict._plain_key_ = 1
: let aDict.*any_key* = 0     |" 肯定语法错误
```

然后要提醒的是，字典键索引也可用字符串变量，那就不能在中括号内用引号了。当要索
引的键是变量时，中括号索引语法是正统，用点号索引则不能达到类似效果，因为点号索
引只是常量键的语法糖。例如：

```vim
: let str_var = 'some_key'
: let aDict[str_var] = 'some value'
: echo aDict[str_var]   |" --> some value
: echo aDict.some_key   |" --> some value
: echo aDict.str_var    |" 未定义键，相当于 aDict['str_var']

: echo aDict.{str_var}   |" 语法错误
: let prefix = 'some_'
: echo aDict.{prefix}key   |" 语法错误
: let prefix = 'a'
: echo {prefix}Dict.some_key |" --> some value
: let midfix = '_'
: echo aDict.some{midfix}key   |" 语法错误
```

上例的后半部分还演示了 VimL 的另一个比较隐晦（但或许有时算灵活有用）的语法，就
是可以用大括号 `{}` 括住字符串变量内插拼接变量名，这可以达到使用动态变量名的效果。
但是，这种拼接语法也只能用于普通变量名，并不能用于字典的键名。键名毕竟与变量名
不是同种概念。（关于大括号内插变量名的语法，请参阅 `:h curly-braces-names`）

总之，将字典当作对象来使用时，建议先创建一个空字典，再用点索引语法逐个添加属性
。可以在用到时动态添加属性，不过从设计清晰的角度看，尽可能集中地在一开始初始化
主要的属性，通过赋初值，还可揭示各属性应保存的值类型。例如，我们创建如下一个对
象：

```vim
: let object = {}
: let object.name = 'bob'
: let object.desc = 'a sample object'
: let object.value = 0
: let object.data = {}
```

从上例中便可望文生义，知道 `object` 有几个属性，其中 `name` 与 `desc` 是字符串
类型，`value` 是一个数字，可能用于保存一个特征值，其他一些复杂数据就暂存 `data` 
属性中吧，这是另一个字典，或也可称之为成员对象。当然了，VimL 是动态类型的语言
，在运行中可以改变保存在这些属性中的值的类型，然而为了对程序员友好，避免这样做
。

### 字典键中保存对象方法

如果在字典中只保存数据，那并不是很有趣。关键是在字典中也能保存函数，实际保存的
是函数引用，因为函数引用才是变量，才能保存在字典的键中，但在用户层面，函数引用
与函数的使用方式几乎一样。

保存在同一个字典内的数据与函数也不是孤立的，而应是有所联系。在函数内可以使用在
同一个字典中的数据。用形象的话，就是保存在字典内的函数可以操作字典本身。这就是
面向对象的封装特性。字典键中的函数引用，就是该对象的方法。

在 VimL 中，定义对象的方法也有专门的语法（糖），例如：

```vim
function! object.Hello() abort " dict
    echo 'Hello ' . self.name
endfunction

: call object.Hello()    |" --> Hello bob
```

在上例中，`object` 就是已经定义的字典对象，这段代码为该对象定义了一个名为
`Hello` 的方法，也即属性键，保存的是一个匿名函数的引用；在该方法函数体内，关键
字 `self` 代表着调用时（不是定义时）的对象本身。然后就可以直接调用 `:call
object.Hello()` 了，在执行该调用语句时，`self` 就是 `object` 。

按这种语法定义对象方法时，可以像定义其他函数一样附加函数属性，其中 `dict` 属性
是可选的，即使不指定该属性，也隐含了该属性。之所以说这也像是一个“语法糖”，是因
为这个示例相当于以下写法：

```vim
function! DF_object_Hello() abort dict
    echo 'Hello' . self.name
endfunction
let object.Hello = function('DF_object_Hello')
```

这里函数定义的 `dict` 属性不能省略，否则在函数体内不能用 `self`。不过这仍是伪
语法糖，因为这两者并不完全等效，后者还新增了一个全局函数，污染了函数命名空间。
而上节介绍的点索引属性，`object.name` 才是与 `object['name']` 完全等效的真语法
糖。

从 VimL 的语法上讲，在字典键中保存的函数引用，可以是相关的或无关的函数。但从面
向对象设计的角度看，若往对象中添加并无关联的函数，就很匪夷所思了。例如下面这个
方法：

```vim
function! object.HellowWorld() abort dict
    echo 'Hello World'
endfunction
```

在这个方法内并未用到 `self`，也就是说不需要对象数据的支持，那强行放在对象中就很
没必要了。要实现这个功能，直接定义一个名为 `HelloWorld` 的全局函数（或脚本局部
函数）就可以了。

然而，一个函数方法是否与对象有关，这是一种抽象分析的判断，并非是从语法上函数体
内有无用到 `self` 来判断。假如上面这个 `object` 的用于打招呼的 `Hello()` 方法
另增需求，除了打印自身的名字外，还想附加一些语气符号。我们也将这个附加的需求抽
象为函数，修改如下：

```vim
function! object.EndHi() abort dict
    return '!!!'
endfunction

function! object.Hello() abort dict
    echo 'Hello ' . self.name . self.EndHi()
endfunction

: call object.Hello()    |" --> Hello bob!!!
```

这里的 `EndHi()` 方法也不需要用到 `self`，不过从它的意途上似乎与对象相关，所以
也存在字典对象的键中，也未尝不可。

在一些面向对象的语言中（如 C++），这种用不到对象数据的方法可设计为静态方法，它
是属于类的方法，而不是对象的方法。那么，在 VimL 中，可以如何理解类与对象的区别
呢？

### 复制类字典为对象实例

事实上，VimL 只提供了字典这种数据结构，并没有什么特殊的对象。所以类与对象都只
能由字典来表示，从语法上无从分辨类与对象，这只能是由人（程序员）来管理。通过某
种设计约定把某个字典当作类使用，而把另一些字典当作对象来使用。

这首先是要理解类与对象的关系。类就是一种类型，描叙某类事物所具有的数据属性与操
作方法。对象是某类事物的具体实例，它实体拥有特定的数据，且能对其进行特定的操作
。从代码上看，类是对象的模板，通过这个模板可以创建许多相似的对象。

在上节的示例中，我们只创建了一个对象，名为 `object`。可以调用其 `Hello()` 方法
，效果是根据其名字打印一条欢迎致辞。如果要表达另一个对象，一个笨办法是修改其属
性的值。例如：

```vim
: call object.Hello()    |" --> Hello bob!!!
: let object.name = 'ann'
: call object.Hello()    |" --> Hello ann!!!
```

但是，这仍然只实际存在了一个对象。如果在程序中要求同时存在两个相似的对象，那该
如何？也很容易想到，只要克隆一个对象，再修改有差异的数据即可。当然了，你不用在
源代码上复制粘贴一遍对 `object` 的定义，只要调用内置函数 `copy()`。因为有关该
对象的所有东西都已经在 `object` 中了，在 VimL 看来它就是一个字典变量而已。如：

```vim
: let another_object = copy(object)    |" 或 deepcopy(object)
: let another_object.name = 'ann'
: call another_object.Hello()    |" --> Hello ann!!!
```

不过要注意的是，由于当初在定义 `object` 时，预设了一个字典成员属性 `data`。如
果用 `copy(object)` 浅拷贝，则新对象 `another_object` 与原对象 `object` 将共享
一份 `data` 数据，即如果改变了一个对象的 `data` 属性，另一个对象的 `data` 属性
也将改变。如果设计需求要求它们相互独立，则应该用 `deepcopy(object)` 深拷贝方法
。

以上用法可行，但不尽合理。因为在实际程序运行中，`object` 的状态经常变化，在一
个时刻由 `object` 复制出来的对象与另一个时刻复制的结果不尽相同，且不可预期。那
么就换一种思路。可以先定义一个特殊的字典对象，其主要作用只是用来“生孩子”，克隆
出其他对象。即它只预定义（设计）必要的属性名称，及提供通用的初值。当在程序中实
际有使用对象的需求时，再复制它创建一个新对象。于是，这个特殊的字典，就可充当类
的作用。类也是一个对象，不妨称之为类对象。

于是，可修改上节的代码如下：

```vim
let class = {}
let class.name = ''
let class.desc = 'a sample class'
let class.value = 0
let class.data = {}

function! class.EndHi() abort dict
    return '!!!'
endfunction

function! class.Hello() abort dict
    echo 'Hello ' . self.name . self.EndHi()
endfunction

: let obj1 = deepcopy(class)
: let obj1.name = 'ann'
: call obj1.Hello()    |" --> Hello ann!!!
: let obj2 = deepcopy(class)
: let obj2.name = 'bob'
: call obj2.Hello()    |" --> Hello bob!!!
```

这里，先定义了一个类对象，取名为 `class`。其数据属性与方法函数定义与上节的
`object` 几乎一样，不过是换了字典变量名而已。另外，既然 `class` 字典是被设计为
当作类的，不是实际的对象实例，那它的 `name` 属性最好留空。当然了，取名为
`noname` 之类的特殊字符串也许也可以，不过用空字符串当作初值足够了，且节省空间
。然后，使用这个类的代码就简单了，由 `deepcopy()` 创建新对象，然后通过对象访问
属性，调用方法。

这就是 VimL 所能提供的面对象支持，用很简单的模型也几乎能模拟类与对象的行为。当
然了，它并不十分完美，毕竟 VimL 设计之初就没打算（似乎也没必要）设计为面向对象
的语言。如果在命令输入以下命令查看这几个字典对象的内部结构：

```vim
: echo class
: echo obj1
: echo obj2
```

可以发现，对象 `obj1` `obj2` 与类 `class` 具有完全一样的键数量（当然了，因为是
用 `copy` 复制的呀）。VimL 本身就没有在对象 `obj1` 与类 `class` 之间建立任何联
系，是我们（程序员）自己用全复制的方式使每个对象获得类中的属性与方法。每个对象
应该有自己独立的数据，这很容易理解与接受。但是，每个对象都仍然保存着应该是通用
的方法，这似乎就有些浪费了。幸好，这只是保存函数引用，不管方法函数定义得多复杂
，每个函数引用都固定在占用很少的空间。不过，蚊子再小也是肉，如果一个类中定义了
很多方法，然后要创建（复制）很多对象，那这些函数引用的冗余也是很可观的浪费了。

另外，直接裸用 `copy()` 或 `deepcopy()` 创建新对象，似乎还是太粗糙了。如果数据
属性较多，还得逐一赋上自己的值，这写起来就比较麻烦。因此，可以再提炼一下，封装
一个创建新对象的方法，如：

```vim
function! class.new(name) abort dict
    let object = deepcopy(self)
    let object.name = a:name
    return object
endfunction

: let obj3 = class.new('Ann')
: call obj3.Hello()    |" --> Hello Ann!!!
: let obj4 = class.new('Bob')
: call obj4.Hello()    |" --> Hello Bob!!!
```

不过，仍然有上面提及的小问题，`class` 中的 `new()` 方法也会被复制到每个新建的
对象如 `obj3` 与 `obj4` 中。若说在类中提供一个 `new()` 方法很有意义，那在对象
实例中也混入 `new()` 方法就颇有点奇葩了，只能选择性忽略，不用它就假装它不存在
。当然了，如果只是想封装“创建对象”这个功能，也可用其他方式回避，这在后文再叙。

这里要再提醒一点是，由于 `new()` 方法是后来添加进去 `class` 类对象中的。在这之
前创建的 `obj1` `obj2` 对象是基于原来的类定义复制的，所以它并不会有 `new()` 方
法，在这之后创建的 `obj3` `obj4` 才有该方法。如果在之后给类对象添加新的属性或
（实用）方法，也将呈现这种行为，原来的旧对象实例并不能自动获得新属性或方法。有
时固然可以有意利用这种动态修改类定义的灵活特性，但更多的时候应该是注意避免这种
无意的陷阱。这也再次说明了，VimL 语法本身并不能保证对象与类之间的任何联系，其
间的联系都是“人为的假想”，或者说是程序员的设计。

### 复制字典也是继承

上文已经讲了，通过在字典中同时保存数据与函数（引用），就基本能实现（模拟）面向
对象的封装特征。然后，面向对象的另一个重要特征，继承，该如何实现呢？其实一句话
点破也很简单，也就是用 `copy()` 复制，复制，再复制。

接上节的例子，我们打算从 `class` 类中继承两个子类 `CSubA` 与 `CSubB` ，示例代
码如下：

```vim
let CSubA = deepcopy(class)
function! CSubA.EndHi() abort dict
    return '$$$'
endfunction

let CSubB = deepcopy(class)
function! CSubB.EndHi() abort dict
    return '###'
endfunction

: let obj5 = CSubA.new('Ann')
: call obj5.Hello()    |" --> Hello Ann$$$
: let obj6 = CSubB.new('Bob')
: call obj6.Hello()    |" --> Hello Bob###
```

在这两个子类中，我们只重写覆盖了 `EndHi()` 方法，让每个子类使用不同的语气符号
后缀。而基类 `class` 中的 `new()` 方法与 `Hello()` 方法，自动被继承（就是复制
啦）。其实 `EndHi()` 方法也是先复制继承了，只是立刻被覆盖了（所以必须用
`:function!` 命令，加叹号）。在使用时，也就可以直接用子类调用 `new()` 方法创建
子类对象，再子类对象调用 `Hello()` 方法。

至于面向对象的多态特征，对于弱类型脚本语言而言，只要实现了继承的差异化与特例化
，是天然支持多态的。例如上面的 `obj5` 与 `obj6` 虽属于不同类型，但可直接放在
一个集合（如列表）中，然后调用统一的方法：

```vim
: let lsObject = [obj5, obj6]
: for obj in lsObject
:     call obj.Hello()
: endfor
```

但是对于其他强类型语言（如 C++），却不能直接将不同类型的 `obj5` 与 `obj6` 放在
同一个数组中，才需要其他语法细节来支持多态的用法。


### 小结

VimL 提供的字典数据结构，允许程序员写出面向对象风格的程序代码。在字典内，可同
时保存数据与函数（引用），并且在这种函数中可以用关键字 `self` 访问字典本身，因
而可以将字典视为一个对象。类、继承子类与实例化对象，都可以简单通过复制字典来达
成。只是这种全复制的方式，效率未必高，因为会将类中的方法即函数引用都复制到子类
与实例中，即使函数引用所占空间很小，也会造成一定的浪费。然而，从另一方面想，光
脚的不怕穿鞋的，VimL 本来就不讲究效率，这也不必太纠结。几乎所有的语言，面向对
象设计在给程序员带来友好的同时，都会有一定的实现效率的代价交换。
