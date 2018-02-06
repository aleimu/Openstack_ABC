# concurrent.futures模块提供给开发者一个执行异步调用的高级接口.concurrent.futures 基本上就是在Python的 threading 和 multiprocessing 模块之上构建的抽象层,更易于使用.尽管这个抽象层简化了这些模块的使用,但是也降低了很多灵活性,所以如果你需要处理一些定制化的任务,concurrent.futures或许并不适合你.但对于一般任务我们可以将相应的tasks直接放入线程池/进程池，不需要维护Queue来操心死锁的问题，线程池/进程池会自动帮我们调度。

concurrent.futures包括抽象类 Executor,它并不能直接被使用,所以你需要使用它的两个子类：ThreadPoolExecutor 或者 ProcessPoolExecutor.正如你所猜的,这两个子类分别对应着Python的threading和multiprocessing接口.这两个子类都提供了池,你可以将线程或者进程放入其中.

Python标准库中所有执行阻塞型I/O操作的函数,在等待系统返回结果时都会释放GIL(time.sleep()函数也会释放GIL).这意味着I/O密集型Python程序能从中受益：一个Python线程等待网络响应时,阻塞型I/O函数会释放GIL,再运行一个线程.

从Python3.4起,标准库中有两个为Future的类：concurrent.futures.Future 和 asyncio.Future.这两个类作用相同：两个Future类的实例都表示可能已经完成或未完成的延迟计算.
Future 封装待完成的操作,可放入队列,完成的状态可以查询,得到结果（或抛出异常）后可以获取结果（或异常）.


#那么如何使用 concurrent.futures 模块解决不同场景的性能问题呢？
ThreadPoolExecutor(合适I/O密集型工作) 和 ProcessPoolExecutor(合适CPU密集型工作) 都实现了通用的 Executor 接口.
比如下边这样：
from concurrent import futures
# from concurrent.futures import ProcessPoolExecutor,ThreadPoolExecutor
def download_many(cc_list):
    workers = min(MAX_WORKERS, len(cc_list))
    with futures.ThreadPoolExecutor(workers) as executor:
        executor.map(func, *iterables, timeout=None, chunksize=1)
# 改成
def download_many(cc_list):
    with futures.ProcessPoolExecutor() as executor:
        pass
需要注意的是,ThreadPoolExecutor 需要指定 max_workers 参数, 而 ProcessPoolExecutor 的这个参数是可选的默认值是 os.cup_count()(计算机cpu核心数).

>>> dir(futures)
['ALL_COMPLETED', 'CancelledError', 'Executor', 'FIRST_COMPLETED', 'FIRST_EXCEPTION', 'Future', 'ProcessPoolExecutor', 'ThreadPoolExecutor', 'TimeoutError', '__author__', '__builtins__', '__cached__', '__doc__', '__file__', '__loader__', '__name__', '__package__', '__path__', '__spec__', '_base', 'as_completed', 'process', 'thread', 'wait']

>>> dir(futures.ProcessPoolExecutor())
['__class__', '__delattr__', '__dict__', '__dir__', '__doc__', '__enter__', '__eq__', '__exit__', '__format__', '__ge__', '__getattribute__', '__gt__', '__hash__', '__init__', '__le__', '__lt__', '__module__', '__ne__', '__new__', '__reduce__', '__reduce_ex__', '__repr__', '__setattr__', '__sizeof__', '__str__', '__subclasshook__', '__weakref__', '_adjust_process_count', '_broken', '_call_queue', '_max_workers', '_pending_work_items', '_processes', '_queue_count', '_queue_management_thread', '_result_queue', '_shutdown_lock', '_shutdown_thread', '_start_queue_management_thread', '_work_ids', 'map', 'shutdown', 'submit']

>>> dir(futures.ThreadPoolExecutor(2))
['__class__', '__delattr__', '__dict__', '__dir__', '__doc__', '__enter__', '__eq__', '__exit__', '__format__', '__ge__', '__getattribute__', '__gt__', '__hash__', '__init__', '__le__', '__lt__', '__module__', '__ne__', '__new__', '__reduce__', '__reduce_ex__', '__repr__', '__setattr__', '__sizeof__', '__str__', '__subclasshook__', '__weakref__', '_adjust_thread_count', '_max_workers', '_shutdown', '_shutdown_lock', '_threads', '_work_queue', 'map', 'shutdown', 'submit']

>>> dir(futures.Future)
['_Future__get_result', '__class__', '__delattr__', '__dict__', '__dir__', '__doc__', '__eq__', '__format__', '__ge__', '__getattribute__', '__gt__', '__hash__', '__init__', '__le__', '__lt__', '__module__', '__ne__', '__new__', '__reduce__', '__reduce_ex__', '__repr__', '__setattr__', '__sizeof__', '__str__', '__subclasshook__', '__weakref__', '_invoke_callbacks', 'add_done_callback', 'cancel', 'cancelled', 'done', 'exception', 'result', 'running', 'set_exception', 'set_result', 'set_running_or_notify_cancel']

# Future方法
cancel()：尝试去取消调用。如果调用当前正在执行,不能被取消。这个方法将返回False,否则调用将会被取消,方法将返回True
cancelled()：如果调用被成功取消返回True
running()：如果当前正在被执行不能被取消返回True
done()：如果调用被成功取消或者完成running返回True
result(Timeout = None)：拿到调用返回的结果。如果没有执行完毕就会去等待,这时会阻塞调用方所在的线程,直到有结果返回.此时result 方法还可以接收 timeout 参数,如果在指定的时间内 Future 没有运行完毕,会抛出 TimeoutError 异常.
exception(timeout=None)：捕获程序执行过程中的异常
add_done_callback(fn)：将fn绑定到future对象上。当future对象被取消或完成运行时,fn函数将会被调用

以下的方法是在unitest中
set_running_or_notify_cancel()
set_result(result)
set_exception(exception) 

# Executor对象
1、抽象类,提供异步调用的方法。不能被直接使用,而是通过构建子类,ProcessPoolExecutor、ThreadPoolExecutor 就是分别实现了Executor中使用进程池、线程池来异步执行调用的子类。
ProcessPoolExecutor使用multiprocessing模块，不受GIL锁的约束，意味着只有可以pickle的对象才可以执行和返回.
2、方法
提交任务方式一：submit(fn, *args, **kwargs)：调度函数fn(*args **kwargs)返回一个Future对象代表调用的执行。
提交任务方式二：map(func, *iterables, timeout=None, chunksize=1)：和map(func, *iterables)相似。但是该map方法的执行是异步的。多个func的调用可以同时执行。当Executor对象是 ProcessPoolExecutor,才可以使用chunksize,将iterable对象切成块,将其作为分开的任务提交给pool,默认为1。对于很大的iterables,设置较大chunksize可以提高性能（切记）。
shutdown(wait=True)：给executor发信号,使其释放资源,使用with语句,就可以避免必须调用本函数
相当于进程池的pool.close()+pool.join()操作,wait=True，等待池内所有任务执行完毕回收完资源后才继续,wait=False，立即返回，并不会等待池内的任务执行完毕但不管wait参数为何值，整个程序都会等到所有任务执行完毕,submit和map必须在shutdown之前

举几个例子
{
#ProcessPoolExecutor/进程池用法
from concurrent.futures import ThreadPoolExecutor,ProcessPoolExecutor

import os,time,random
#定义一个函数
def task(n):
    print('%s is runing' %os.getpid())
    time.sleep(random.randint(1,3))
    return n**2

if __name__ == '__main__':
    #配置线程池里的线程,不写默认cpu*5,默认20
    executor=ProcessPoolExecutor(max_workers=3)

    futures=[]
    for i in range(11):
        #往线程池里面提交任务,就是函数名和参数
        future=executor.submit(task,i)
        futures.append(future)
    #主进程等待进程池里的进程运行结束后再结束
    executor.shutdown(True)
    print('+++>')
    for future in futures:
        print(future.result())    

#ThreadPoolExecutor/线程池
from concurrent.futures import ProcessPoolExecutor,ThreadPoolExecutor
import time,random,os
import threading

def work(n):
    print('%s is running' %threading.current_thread().getName())
    time.sleep(random.randint(1,3))
    return n**2
if __name__ == '__main__':
    executor=ThreadPoolExecutor()
    futrues=[]
    for i in range(30):
        future=executor.submit(work,i)
        futrues.append(future)
    executor.shutdown(wait=True)
    print('主')
    for obj in futrues:
        print(obj.result())


#map方法的使用
from concurrent.futures import ProcessPoolExecutor,ThreadPoolExecutor
import time,random,os

def work(n):
    print('%s is running' %os.getpid())
    time.sleep(random.randint(1,3))
    return n**2
if __name__ == '__main__':
    executor=ProcessPoolExecutor()
    # futures=[]
    # for i in range(10):
    #     future=executor.submit(work,i)
    #     futures.append(future)

    executor.map(work,range(10))
    executor.shutdown(wait=True)
    print('主')


#回调函数
from concurrent.futures import ThreadPoolExecutor,ProcessPoolExecutor
import requests
import os
import time,random
def get(url):
    print('%s GET %s' %(os.getpid(),url))
    response=requests.get(url)
    time.sleep(random.randint(1,3))
    if response.status_code == 200:
        print('%s DONE %s' % (os.getpid(), url))
        return {'url':url,'text':response.text}

def parse(future):
    dic=future.result()
    print('%s PARSE %s' %(os.getpid(),dic['url']))
    time.sleep(1)
    res='%s:%s\n' %(dic['url'],len(dic['text']))
    with open('db.txt','a') as f:
        f.write(res)

if __name__ == '__main__':
    urls=[
        'https://www.baidu.com',
        'https://www.python.org',
        'https://www.openstack.org',
        'https://help.github.com/',
        'http://www.sina.com.cn/'
    ]
    p=ProcessPoolExecutor()
    start_time=time.time()
    objs=[]
    for url in urls:
        # obj=p.apply_async(get,args=(url,),callback=parse) #主进程负责干回调函数的活
        p.submit(get,url).add_done_callback(parse) #parse_page拿到的是一个future对象obj，需要用obj.result()拿到结果

    # p.close()
    # p.join()
    print('主',(time.time()-start_time))


#信号量
from threading import Semaphore,Thread,current_thread
import time,random
def task():
    with sm:
        print('%s 正在上厕所' %current_thread().getName())
        time.sleep(random.randint(1,3))

if __name__ == '__main__':
    sm=Semaphore(5)
    for i in range(11):
        t=Thread(target=task)
        t.start()

#线程池与信号量的区别-还不是很清晰
信号量限制最大链接数与线程池/进程池不一样,信号量是创建一堆线程/进程去抢定义好的信号量
而池是规定好只能有多少进程或者线程,通俗点就是一个定义有几个茅坑,一个定义同是只能有几个人排队而且不能有新人加入

线程池着重于减小线程创建的代价，创建一个线程的代价较高，因此我们使用线程池设法复用线程
信号量着重于对公共资源或者临界区的访问的控制。维护着一个计数器，指定可同时访问资源或者进入临界区的线程数。 

#事件Event
import threading,time
event = threading.Event()    #实例化一个事件对象
def light():
    count = 0
    event.set()      #设置红灯
    while True:
        if 0 < count <= 5 :   #0到5秒，绿灯，清除设置
            event.clear()
            print("\033[1;32m现在是绿灯,可以通行\033[0m")
        elif 5 < count <10:    #5s后，绿灯变红灯，设置
            event.set()
            print("\033[1;35m现在是红灯,禁止通行\033[0m")
        elif count == 10:    #10s后，红灯结束，count设置为0重新开始
            count = 0
        time.sleep(1)
        count += 1
 
def car(name):
    while True:
        if event.is_set():        
            print(name,"红灯，等待。。。。。。。。。。")
            time.sleep(2)
        else:
            print(name,"绿灯，可以通行。。。。。。。。")
            time.sleep(2)
 
L = threading.Thread(target=light,)    #红绿灯线程
L.start()
C = threading.Thread(target=car,args=("兰博基尼",))   #车辆通行线程
C.start()
event = threading.Event() 事件需先实例化
event.wait()    等待标志位被设置
event.set()    设置一个标志位
event.clear()  清楚已设置的标志位

#定时器Timer
from threading import Timer

def hello():
    print("hello, world")
 
t = Timer(1, hello)
t.start()  # after 1 seconds, "hello, world" will be printed

}
