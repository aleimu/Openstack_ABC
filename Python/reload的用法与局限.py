#解决：NameError: name 'reload' is not defined 问题
对于 Python 2.X：
import sys
reload(sys)
sys.setdefaultencoding("utf-8")

对于 <= Python 3.3：
import imp
imp.reload(sys)
注意： 
1. Python 3 与 Python 2 有很大的区别，其中Python 3 系统默认使用的就是utf-8编码。 
2. 所以，对于使用的是Python 3 的情况，就不需要sys.setdefaultencoding("utf-8")这段代码。 
3. 最重要的是，Python 3 的 sys 库里面已经没有 setdefaultencoding() 函数了。

对于 >= Python 3.4：
import importlib
importlib.reload(sys)


#mymode.py

import os
import time

class mymode1():
    def a1(self):
        print("this is a1!")
    def b1(self):
        print("this is b1!")

class mymode2():
    def a2(self):
        print("this is a2!")
    def b2(self):
        print("this is b2!")

#mytest.py
import mymode
import subprocess
#try 
a=mymode.mymode1()
a.a1()
print("---------------------")
#change mymode.py
cmd='sed -i "s/this is/here is/g" /home/test/mymode.py'
subprocess.call(cmd,shell=True)
reload(mymode)
a.a1()
print("---------------------")
a=mymode.mymode1()
a.a1()

"""
[root@allinone-centos test]# python mytest.py 
this is a1!
this is a2!
this is a1!
this is a2!

reload
作用：
对已经加载的模块进行重新加载，一般用于原模块有变化等特殊情况，reload前该模块必须已经import过。
import os
reload(os)
说明：
reload会重新加载已加载的模块，但原来已经使用的实例还是会使用旧的模块，而新生产的实例会使用新的模块；reload后还是用原来的内存地址；不能支持from XX import XX 格式的模块进行重新加载。


import A.tank与from A import tank的区别：
相同点：
两者都将A.tank module以及A作为moudle添加到sys.modules集合中
sys.modules['A']
sys.modules['A.tank']

不同点：
import A.tank 在local名称空间中引入符合"A"，并且将其映射到module A
from A import tank Python虚拟机在local名称空间中引入符合"tank"，并将其映射到module A.tank
"""

Python 动态加载模块的3种方法
1，使用系统函数__import_()

stringmodule = __import__('string')
2,使用imp 模块

import imp
stringmodule = imp.load_module('string',*imp.find_module('string'))
3,使用exec

import_string = "import string as stringmodule"
exec import_string

#导入模块的所有方法：
import module_name #表示将模块中的所有代码加载到这个位置并赋值给变量module_name，并执行模块
import libs.module_name #表示从libs目录下导入模块文件module_name，调用方法：libs.module_name.func()
import module1_name,module2_name #同时导入多个模块
from module_name import login,logout #相当于将module_name\login中的代码拿到当前位置执行
from module_name import login as module_name_login #对导入模块中的方法取别名
from libs.module_name import func #从目录下的模块文件中导入方法func，调用：func()

import本质：
　　导入模块的本质就是把Python文件解释一遍。
　　导入包的本质就是执行该包下的__init__.py文件。

导入优化：
　　from module_name import login
　　相比较import module_name，调用时module_name.test()，每次调用时都需要在os.path路径中检索导致效率降低，所以使用from...import...导入，
    这样相当于将方法直接拿到调用者中执行。
