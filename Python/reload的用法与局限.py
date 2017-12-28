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
