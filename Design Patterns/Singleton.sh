python单例模式
# https://www.cnblogs.com/huchong/p/8244279.html
单例模式：保证一个类仅有一个实例，并提供一个访问他的全局访问点，避免内存浪费！
 
实现方式：
1，让一个全局变量使得一个对象被访问，但是他不能防止外部实例化多个对象。
2，让类自身保存他的唯一实例，这个类可以保证没有其他实例可以被创建。

多线程时的单例模式：加锁 --> 双重锁定

饿汉式单例类：在类被加载时就将自己实例化（静态初始化）。其优点是躲避了多线程访问的安全性问题，缺点是提前占用系统资源。
懒汉式单例类：在第一次被引用时，才将自己实例化。避免开始时占用系统资源，但是有多线程访问安全性问题。

# 线程不安全的单例模式
{
class Singleton(object):

    def __init__(self):
        import time
        # 模拟IO操作，触发延迟，才能证明线程安全
        time.sleep(1)

    @classmethod
    def instance(self, *args, **kwargs):
        if not hasattr(Singleton, "_instance"):
            Singleton._instance = Singleton(*args, **kwargs)
        return Singleton._instance

import threading

def task(arg):
    obj = Singleton.instance()
    print(obj)

for i in range(10):
    t = threading.Thread(target=task,args=[i,])
    t.start()
}

# 使用模块
{
#Python 的模块就是天然的单例模式，因为模块在第一次导入时，会生成 .pyc 文件，当第二次导入时，就会直接加载 .pyc 文件，而不会再次执行模块代码。

class Singleton(object):
    def foo(self):
        pass
singleton = Singleton()
#将上面的代码保存在文件 mysingleton.py 中，要使用时，直接在其他文件中导入此文件中的对象，这个对象即是单例模式的对象

from a import singleton
}

# 使用类+线程锁
{
# @classmethod --线程安全
import time
import threading
class Singleton(object):
    _instance_lock = threading.Lock()
    def __init__(self):
        time.sleep(1)

    @classmethod
    def instance(cls, *args, **kwargs):
        if not hasattr(Singleton, "_instance"):
            with Singleton._instance_lock:
                if not hasattr(Singleton, "_instance"):
                    Singleton._instance = Singleton(*args, **kwargs)
        return Singleton._instance

def task(arg):
    obj = Singleton.instance()
    print(obj)
for i in range(10):
    t = threading.Thread(target=task,args=[i,])
    t.start()

# @staticmethod --线程安全
import threading
# 单例类
class Singleton():
    instance = None
    mutex = threading.Lock()
    def _init__(self):
        import time
        # 模拟IO操作，触发延迟，才能证明线程安全
        time.sleep(1)
    @staticmethod
    def GetInstance():
        if (Singleton.instance == None):
            Singleton.mutex.acquire()
            if (Singleton.instance == None):
                print('初始化实例')
                Singleton.instance = Singleton()
            else:
                print('单例已经实例化1')
            Singleton.mutex.release()
        else:
            print('单例已经实例化2')

        return Singleton.instance

def task(arg):
    obj = Singleton()
    print(obj.GetInstance)

for i in range(10):
    t = threading.Thread(target=task,args=[i,])
    t.start()
# 不加线程锁 ---也是线程安全的啊
import threading

class Singleton():
    instance = None
    #mutex = threading.Lock()
    def __init__(self):
        import time
        time.sleep(2)
    @staticmethod
    def GetInstance():
        if (Singleton.instance == None):
            #Singleton.mutex.acquire()
            if (Singleton.instance == None):
                print('初始化实例')
                Singleton.instance = Singleton()
            else:
                print('单例已经实例化1')
            #Singleton.mutex.release()
        else:
            print('单例已经实例化2')
        return Singleton.instance

def task(arg):
    obj = Singleton()
    print(obj.GetInstance)

for i in range(10):
    t = threading.Thread(target=task,args=[i,])
    t.start()    

}

# 基于__new__方法实现（推荐使用，方便）
{
# 基于__new__方法实现（推荐使用，方便）
import threading
import time
# 使用了线程锁 --线程安全
class Singleton(object):
    _instance_lock = threading.Lock()
    def __init__(self):
        time.sleep(1)
    def __new__(cls, *args, **kwargs):
        if not hasattr(Singleton, "_instance"):
            with Singleton._instance_lock:
                if not hasattr(Singleton, "_instance"):
                    Singleton._instance = object.__new__(cls, *args, **kwargs)
        return Singleton._instance

def task1(arg):
    obj = Singleton()
    print(obj)

for i in range(10):
    t = threading.Thread(target=task1, args=[i, ])
    t.start()

time.sleep(2)
print("================")

# 不使用线程锁 --也是线程安全的
class MyClass(object):
    _instance = None
    def __init__(self):
        time.sleep(1)
    def __new__(cls, *args, **kwargs):
        if not cls._instance:
            cls._instance = super(MyClass, cls).__new__(cls, *args, **kwargs)
            #cls._instance = object.__new__(cls, *args, **kwargs)
        return cls._instance

def task2(arg):
    obj = MyClass()
    print(obj)

for i in range(10):
    t = threading.Thread(target=task2,args=[i,])
    t.start()

"""
对比可以看出，使用__new__ 方法并不需要加锁。
"""
 
}
 
# 基于metaclass方式实现
{
import threading

class SingletonType(type):
    _instance_lock = threading.Lock()
    def __call__(cls, *args, **kwargs):
        if not hasattr(cls, "_instance"):
            with SingletonType._instance_lock:
                if not hasattr(cls, "_instance"):
                    cls._instance = super(SingletonType,cls).__call__(*args, **kwargs)
        return cls._instance

class Foo(metaclass=SingletonType):
    def __init__(self,name):
        self.name = name

def task(arg):
    obj = Foo(arg)
    print(obj)

for i in range(10):
    t = threading.Thread(target=task,args=[i,])
    t.start()
# 不加线程锁 --也是线程安全的啊
class SingletonType(type):
    def __init__(self, *args, **kwargs):
        import time
        time.sleep(1)
    def __call__(self, *args, **kwargs):
        if not hasattr(self, "_instance"):
            self._instance = super(SingletonType,self).__call__(*args, **kwargs)
        return self._instance

class Foo(metaclass=SingletonType):
    def __init__(self,name):
        self.name = name

def task(arg):
    obj = Foo(arg)
    print(obj)

for i in range(10):
    t = threading.Thread(target=task,args=[i,])
    t.start() 
# 没有区别，并不需要加线程锁    
}

#总结
classmethod 装饰的自定义函数都需要手动加上线程锁，才能保证线程安全。class自带的方法都不用手动加锁。
