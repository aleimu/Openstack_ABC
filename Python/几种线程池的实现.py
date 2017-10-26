#参考博文
http://www.cnblogs.com/Mr-Lius/articles/5460817.html
http://www.cnblogs.com/kading/p/5753319.html


http://www.cnblogs.com/xiaozhiqi/articles/5799624.html
http://www.cnblogs.com/wanghzh/p/5607067.html
http://www.cnblogs.com/phennry/articles/5698038.html

#参考多种线程池的实现
https://github.com/search?l=Python&q=threadpool&type=Repositories&utf8=%E2%9C%93

#几种线程池实现

简单线程池 线程不复用
{

import queue
import threading
import time

class ThreadPool:
    def __init__(self,maxsize=5):        #定义构造方法
        self.maxsize = maxsize           #线程池大小为5
        self._q = queue.Queue(maxsize)
        for i in range(maxsize):
            self._q.put(threading.Thread) #先往队列里插入的线程池大小的元素，元素为Threading.Thread类，等待处理请求
    def get_thread(self):                 #定义get_thread方法来去处理请求
        return self._q.get()

    def add_thread(self):                 #定义add_thread方法来请求线程池
        self._q.put(threading.Thread)

def task(arg,p):
    """
    在队列里添加一个元素，线程执行完会自动关闭，需要在重新添加新的线程对象
    :param arg: 循环的数值
    :param p: 线程池的对象
    :return:
    """
    print(arg)
    time.sleep(1)
    p.add_thread()
    
pool = ThreadPool(5)                      #创建线程池
for i in range(100):
    t = pool.get_thread()                #get，threading.Thread类
    obj = t(target=task,args=(i,pool,))
    obj.start()
    
}

复用线程池1
{
#!/usr/bin/env python
#-*- coding:utf-8 -*-


import queue
import contextlib
import threading

WorkerStop = object()                                       #定义一个线程停止的标志，如果在队列里取到这个值，线程停止


class ThreadPool:
    workers = 0                                              #默认workers定义为0
    threadFactory = threading.Thread
    currentThread = staticmethod(threading.currentThread)    #创建静态方法为当前线程活跃的线程个数

    def __init__(self, maxthreads=20, name=None):
        self.q = queue.Queue(0)                                    #这里创建一个队列，如果是0的话表示不限制，现在这个队列里放的是任务
        self.max = maxthreads                                #定义最大线程数
        self.name = name
        self.waiters = []                                    #这两个是用来计数的
        self.working = []                                    #用来记录正在工作的线程数

    def start(self):
        '''
        举例来说：
        while self.workers < min(self.max, needSize):
        这个循环，比如最大线程为20，咱们的任务个数为10，取最小值为10
        每次循环开1个线程，并且workers自增1，那么循环10次后，开了10个线程了workers = 10 ,那么workers就不小于10了
        就不开线程了，我线程开到最大了，你们这10个线程去消耗这10个任务去吧
        并且这里不阻塞，创建完线程就去执行了！
        每一个线程都去执行_worker方法去了
        '''
        needSize = self.q.qsize()                            #获取当前队列的任务长度
        while self.workers < min(self.max, needSize):        #wokers默认为0  【workers = 0】
            self.startAWorker()

    def startAWorker(self):
        self.workers += 1                                                    #每个线程过来自增1
        newThread = self.threadFactory(target=self._worker, name='shuaige')  #创建一个线程并去执行_worker方法
        newThread.start()

    def callInThread(self, func, *args, **kw):
        self.callInThreadWithCallback(None, func, *args, **kw)

    def callInThreadWithCallback(self, onResult, func, *args, **kw):          #提交任务到队列中
        o = (func, args, kw, onResult)
        self.q.put(o)


    @contextlib.contextmanager                                       #提供一种针对函数级别的上下文管理机制
    def _workerState(self, stateList, workerThread):                 #记录线程数量的状态，加到stateList列表里，
        stateList.append(workerThread)
        try:
            yield
        finally:
            stateList.remove(workerThread)

    def _worker(self):
        ct = self.currentThread()                       #当前活跃的线程个数
        o = self.q.get()                                #去队列里取任务,如果有任务就O就会有值，每个任务是个元组，有方法，有参数
        while o is not WorkerStop:                      #如果取出来的值不是WorkerStop就循环
            with self._workerState(self.working, ct):   #上下文切换
                function, args, kwargs, onResult = o
                del o
                try:
                    result = function(*args, **kwargs)
                    success = True
                except:
                    success = False
                    if onResult is None:
                        pass
                    else:
                        pass

                del function, args, kwargs

                if onResult is not None:
                    try:
                        onResult(success, result)
                    except:
                        #context.call(ctx, log.err)
                        pass

                del onResult, result

            with self._workerState(self.waiters, ct):  #当线程工作完闲暇的时候，在去取任务执行
                o = self.q.get()

    def stop(self):                #定义关闭线程方法
        while self.workers:        #循环workers值
            self.q.put(WorkerStop) #在队列中发送一个停止信号
            self.workers -= 1      #workers值-1 直到所有线程关闭


def show(arg):      #每个任务处理间隔1秒
    import time
    time.sleep(1)
    print(arg)


pool = ThreadPool(10)

#创建100个任务，队列里添加了100个任务
#每个任务都是一个元组（方法名，动态参数，动态参数，默认为NoNe）
for i in range(100):
    pool.callInThread(show, i)

pool.start()  #队列添加完成之后，开启线程让线程一个一个去队列里去拿

pool.stop() #当上面的任务都执行完之后，线程中都在等待着在队列里去数据呢！
'''
我们要关闭所有的线程，执行stop方法，首先workers这个值是当前的线程数量，我们给线程发送一个信号“WorkerStop”
在线程的工作里：        while o is not WorkerStop:   如果线程获取到这个值就不执行了，然后这个线程while循环就停止了，等待
python的垃圾回收机制，回收。

然后在self.workers -= 1 ，那么所有的线程收到这个信号之后就会停止！！！
over~
'''

}    

复用线程池2
{
import threading,time,Queue
stop = object()
class Thread(object):
    def __init__(self,max_num):
        self.q = Queue.Queue()
        self.max_num = max_num
        self.terminal = False
        self.generate_list = []
        self.free_list = []

    def generate_thread(self):
        t = threading.Thread(target = self.call)
        t.start()
    def call(self):
        current_thread = threading.currentThread 
        self.generate_list.append(current_thread)
        even = self.q.get()
        while even != stop:
            func,args,callback = even
            try:
                ret = func(args)
                status = True
            except Exception as e:
                status = False
                ret = e
            if callback is not None:
                try:
                    callback(status,ret)
                except Exception as e:
                    pass
            if self.terminal:
                even = stop
            else:
                self.free_list.append(current_thread)
                even = self.q.get()
                self.free_list.remove(current_thread)
        else:
            self.generate_list.remove(current_thread)

    def run(self, func, args, callback=None):
        w = (func, args, callback,)
        self.q.put(w)
        if len(self.free_list) == 0 and len(self.generate_list) < self.max_num:
            self.generate_thread()
    def close(self):
        num = len(self.generate_list)
        while num:
            self.q.put(stop)
            num -= 1
    def terminal(self): 
        self.terminal = True
        max_num = len(self.generate_list)
        while max_num:
            self.q.put(stop)
            max_num -= 1

    def terminall(self):
        self.terminal = True

        while self.generate_list:
            self.q.put(stop)
        self.q.empty()
def work(a):
    print(a)
    time.sleep(10)

    
pool = Thread(10)
for i in range(500):
    pool.run(func=work,args=i)
    
pool.close()
}
