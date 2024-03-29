+++
title = "7.1 面向对象的简介"
weight = 1
+++

<!-- ## 7.1 面向对象的简介 -->

在前文中用了比较多的篇幅来介绍函数。如果主要以函数作为基本单元来组织程序（脚本）
代码，函数间的相互调用通过参数传递数据，这种方式或可称之为面向过程的编程。大部
分简单的 VimL 脚本都可以通过这种方式实现。单元函数的定义与复用也算简洁。

但是，如果有更大的野心，想用 VimL 实现较为复杂的功能时，只采用以上基于函数的面
向过程编程方式，可能会遇到一些闹心的事情。比如函数参数过多，需要特别小心各参数
的意义与次序，或许还可能不可避免要定义相当多的全局变量。当然，这可能并不至于影
响程序的功能实现，主要还是对程序员维护代码造成困扰，增加程序维护与复用的困难。

这时，就可考虑面向对象的编程方式。其核心思想是数据与函数的整合与统一，以更接近
人的思维方式去写代码与管理代码。

### 面向对象的基本特征

按一些资料的说法，面向对象包含以下四个基本特征：

* 抽象
* 封装
* 继承
* 多态

严格说来，任何编程都应该从抽象开始。分析现实需求问题的主要关系，归纳出功能单元
组成部分。按面向过程编程方式设计函数时，同样也要求程序员的抽象能力。所以也有些
教程资料说面向对象的基本特征是后面这三个：封装、继承与多态。这又涉及面向对象的
另一个关键概念，类。

类就是将现实诸问题抽象后的封装结果。它包括数据以及操作这些数据的方法，从概念及
表现上将这两部分放在一起视为一个整体，就称之为封装。类往往对应着现实世界的某种
类型的实体或动作。我们一般只用关注某类事物的表面接口，而不必关心其内部构造细节
。反映到程序上，类的封装就是为了隐藏实现，简化用法，一般用户只要理解某个类是什
么或像什么，以及能做什么，则不用深究怎么做。

所以在程序中，类不外是一种可自定义的复杂类型。与之相对应的简单类型就是如数字、
字符串这种在大多数语言都内置支持的。简单类型除了可以用值表示一种意义外，还支持
特定的操作，如数字的加减乘除，字符串的联连、分割、匹配等。类也一样，它用于表示
值的就是被封装（可能多个）数据，也常被称为成员属性，它所支持的操作方法也叫成员
函数。而对象与类的关系，也正如变量与类型的关系。对象是属于某个类的，有时称其为
实例变量。

有些语言的面向对象还对类的封装进行了严格的控制，比如从外部访问对象只能通过类提
供的所谓公有方法（属性），而另外一些私有方法（属性）只能在类内部的实现中使用。

继承是为了拓展封装之后的类代码的复用，将一个类的功能当作一个整体复用到另一个相
关的类中。这也是对现实世界中具有某种从属关系的事件的一种抽象。在被继承与继承的
两端，一般称之为基类与派生类，或通俗点叫父类与子类。子类继承了父类的大部分属性
与方法（具体的语言或由于访问权限另有细节控制），因而可以像操作父类一样操作子类
。

多态是为了进一步完善继承的用途而伴生的一个功能实现概念，使得在一簇继承体系中，
诸派生类各具个性的同时，也保留共性的方法访问接口。即向许多对象发送相同的消息使
其执行某个操作，各对象能依据其类型作不同的响应（功能实现）。

### 面向对象示例分析

先举个概念上的例子。就比如数字，仅管很多语言把数字当作简单的内置类型来处理，却
也不妨用类与对象的角度来思考这个已经被数学抽象过的概念。

我们知道数字有很多种：整数、实数、有理数、复数等。每种数都可以抽象为一个类，还
可以在这之上再抽象出一种虚拟的“数字”类，当作这些数类的统一基类。这些类簇之间就
形成了一个继承体系。凡是数字都有一些通用方法，比如说加法操作。用户使用时，只需
对一个数字调用加法操作，而不必关心其是哪类数，每类数会按它自己的方式相加（如有
理数的相加与复数的相加就有显著不同）。这就是使用上的多态意义。整数一般可以用少
数几个字节（四或八字节）来表示，但如果有时要用到非常大的整数，可能需要单独再定
义一个无限制的大整数类。但对一般用户来说，也不必关心大整数在底层如何表示，只需
按普通小整数一样使用即可，这就是封装的便利性。

再举个切近 Vim 主题的例子。Vim 是文本编辑器，它主要处理的业务就是纯文本文件。
那么就不妨将文本文件抽象为一个类。其实从操作系统的角度讲，文件包括文本文件与二
进制文件，若按“一切皆文件”的 linux 思想，其他许多设备也算文件。然而，以 Vim 的
功能目的而言，可不必关心这些可扩大化的概念，就从它能处理的文本文件作为抽象的开
始吧。

Vim 将它能编辑的文件分为许多文件类型，典型的就如各种编程语言的源代码文件。于是
每种文件类型都可视为文本文件这个“基类”的“派生类”。然后，Vim 所关注的只是编辑源
码，并不能编译源码，它只能处理表面上的语法（或文法）用于着色、缩进、折叠等美化
显示或格式化的工作。所以不妨再把一些“语法类似”的语言再归为同一类，比如 C/C++、
java、C#、javascript 等（都以大括号作为层次定界符），就可以在其上再抽象一个
`C-Family` 的基类，它处于最基本的文本文件之下，而在各具体的文件类型之上。显然
，类的抽象与设计，是与特定的功能目标有关的。若在其他场合，将 C++、java、
javascript 等傻傻分不清混为一谈就可能不适合了。

若再继续分析，C 语言与 C++ 语言还算是不同的语言，总有些细节差异需要注意，尤其
是人为规定的源码编程风格问题。至于是否真要再细分为两个类，那得看需求的权衡了。
另外，C/C++ 语言还有个特别的东西，它要分为头文件与实现文件。这也得看需求是否要
再划分为两个类设计。如果在编写 C/C++ 代码时需要经常在头文件声明与实现文件的实
现时来回跳转，甚至想保持实现文件的顺序与头文件声明一致以便于对照阅读，那么再继
承两个类分别设计或许是有意义的呢。

对所有这些语言源码文件，Vim 都提供了一个缩进重格式化的功能（即 `=` 命令）。只
要为每个类实现重缩进的操作（实际上利用了继承后，也只要在那些有差异需求文件类型
上额外处理），就可以让 Vim 用统一的一键命令完成这个工作了。这就相当于多态带来
的便利。

当然了，以上的举例，只是概念上的虚拟示例。Vim 编程器本身是用 C 语言写的，并没
有用到面向对象的方式，因而也不会为文件类型设计什么类。而且既然它主要是为处理文
本，VimL 也只要处理简单的整数与实数（浮点数）即可，不会去设计其他复杂的数字类
。这主要是说明如何采用面向对象的思想分析问题，提供一种思路与角度，顺便结合示例
再说明下面向对象的几个特征。

### 面向对象的优劣提示

上文介绍了面向对象的特征，由此带来代码易维护易管理的优点。同时上面的例子也说明
面向对象并不是必要，不用面向对象也能做出很好的应用产品。

其实，面向对象主要不是针对程序，而是针对程序员而言的。如果简单功能，单人维护，
尤其是一次性功能，基本就不必涉及面向对象，因为要实现对象的封装会增加许多复杂代
码。面向对象适合的是复杂需求，尤其涉及多人协作或需要长期维护的项目。此外，在实
际使用面向对象编程时，也要注意避免类的过度设计，增加不必要复杂度。

本章剩下的内容旨在探讨如何使用 VimL 实现基本的面向对象。从学习的角度而言，也可
据此更深入地了解 VimL 的语言特性。至于在实践中，开发什么样的 Vim 功能插件值得
使用面向对象编程，那就看个人的需求分析与习惯喜好了。
