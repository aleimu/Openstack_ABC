python部分{
1.传值与传引用
    python中变量都被视为对象的引用。python函数调用传递参数的时候,不允许程序员选择传值还是传引用,python参数传递采用的都是"传对象引用"的方式。
    这种方式相当于传值和传引用的结合,如果函数收到的是一个可变对象(比如字典或者列表)的引用,就能修改对象的原始值——相当于通过"传引用"来传递对象；如果函数收到的是一个不可变对象(比如数字、字符串或元组)的引用,就不能直接修改原始对象——相当于"传值"来传递对象。
    python一般内部赋值变量的话,都是个引用变量,和c语言的传地址概念差不多。可以通过id(x)来查询x的内存地址。
    如果 a=b的话,a和b的地址相同；如果只是想拷贝,就要用 a = b[:]

2.LEGB 法则
    python引用变量的顺序： 当前作用域局部变量->外层作用域变量->当前模块中的全局变量->python内置变量

3.深浅拷贝
    Python中对象的赋值都是进行对象引用(内存地址)传递
    使用copy.copy(),可以进行对象的浅拷贝,它复制了对象,但对于对象中的元素,依然使用原始的引用.
    如果需要复制一个容器对象,以及它里面的所有元素(包含元素的子元素),可以使用copy.deepcopy()进行深拷贝


4.生成器与列表解析的区别，分别写一个样例
    # 列表解析
    print(sum([i for i in range(100000)]))  # 内存占用大,机器容易卡死
    # 生成器表达式
    print(sum(i for i in range(100000)))  # 几乎不占内存

5.装饰器的理解与实现，需要几个return？

6.类中各种方法、各种变量和装饰器
    内置的装饰器有三个,分别是staticmethod、classmethod和property,作用分别是把类中定义的实例方法变成 静态方法、类方法和类属性

7.装饰器的理解与实现，需要几个return？

8.简单介绍os模块与sys模块

9.python中常用的数据类型，dict如何排序

10.了解PEP8

11.pip的使用，常用库、requests、paramiko、subprocess、traceback、from multiprocessing.pool import ThreadPool

12.调试python代码的方法

13.异常处理
    def dome():
        try:
            a=7
            print(1)
        except Exception:
            print(2)
        else:
            print(3)
            return a
        a=8
        print(5)
        return a

    print(dome())

    #result
    '''
    1
    3
    7
    '''

    def dome(x,y):
        try:
            x = int(x)
            y = int(y)
            print('x/y = ',x / y)
            #return x / y
        except ZeroDivisionError: #捕捉除0异常
            print("ZeroDivision")
        except (TypeError,ValueError) as e: #捕捉多个异常,并将异常对象输出
            print("输入的值类型有误:",e)
        except: #捕捉其余类型异常
            print("反正你就是错了")
        else: #没有异常时执行
            print('good')
            return 2
        finally: #不管是否有异常都会执行
            return 3


    print(dome(1,0))
    print("----------")
    print(dome('a',0))
    print("----------")
    print(dome(1,1))
    print("----------")
    """
    ZeroDivision
    3
    ----------
    输入的值类型有误: invalid literal for int() with base 10: 'a'
    3
    ----------
    x/y =  1.0
    good
    3
    ----------

    """


14.不使用自带的工厂类型转换方法，实现int与str的互转，如："-123456" 转成 -123456,说说思路，考察是否看过源码，有无研究精神



15.有没有关注python3.5、python3.6中的新特性asyncio、typing

}

shell部分{
1.几个常用命令
awk
ps
grep
nohup

2.网络配置
3.如何学习一个新命令，man、--help、查博客
4.一个linux机器，能ping通但登录不上，如何处理？
5.端口映射
6.VMware的使用创建修改虚拟机
}
