# from gevent import monkey;monkey.patch_all() #这个库不能随便导入，导入的话会导致部分库被修改
# 但，要是不导入的话，下面的多线程和多协程就必须这样顺序运行，并且协程需要加join，阻塞主线程
import gevent
import time
import threading

def test(x):
    while True:
        time.sleep(x)
        print(("x:",x))

t1 = threading.Thread(target=test,args=(1,))
t2 = threading.Thread(target=test,args=(2,))
# 多线程一定要启动在 gevent 前,不然会被阻塞
t1.start()
t2.start()
def eat(x):
    while True:
        if x==1:
            print('eat food 1')
            gevent.sleep(x)
        if x==3:
            print('eat food 2')
            gevent.sleep(x)

g1=gevent.spawn(eat,1)
g2=gevent.spawn(eat,3)
gevent.joinall([g1,g2]) # 一定要放在这里,缺点是阻塞后面的程序了

while True:
    print("mian sleep 2:",time.time())
    time.sleep(2)

# watchdog与gevent共用时的报错
Exception in thread Thread-9:
Traceback (most recent call last):
  File "/usr/lib64/python2.7/threading.py", line 811, in __bootstrap_inner
    self.run()
  File "/usr/lib/python2.7/site-packages/watchdog-0.8.3-py2.7.egg/watchdog/observers/api.py", line 199, in run
    self.dispatch_events(self.event_queue, self.timeout)
  File "/usr/lib/python2.7/site-packages/watchdog-0.8.3-py2.7.egg/watchdog/observers/api.py", line 368, in dispatch_events
    handler.dispatch(event)
  File "/usr/lib/python2.7/site-packages/watchdog-0.8.3-py2.7.egg/watchdog/events.py", line 330, in dispatch
    _method_map[event_type](event)
  File "tttt.py", line 418, in on_modified
    self.re_files_changes(event.src_path)
  File "tttt.py", line 339, in re_files_changes
    project_id_body[0], project_id_body[1])
TypeError: 'NoneType' object has no attribute '__getitem__'


# gevent程序员指南
http://www.cnblogs.com/dhcn/p/7106424.html
http://www.cnblogs.com/blockcipher/p/3450351.html
## gevent 和watchdog不能同时使用
主要是因为 猴子补丁
import gevent.monkey
gevent.monkey.patch_all()
会修改select库，影响watchdog
猴子补丁gevent能够修改标准库里面大部分的阻塞式系统调用，包括socket、ssl、threading和 select等模块，而变为协作式运行。


#主线程sleep 2超时的原因
线程切换只有遇到IO才会发生，如果子线程是计算密集型的任务，且执行时间超过2秒，切回主线程的时候就已经过2秒了
当一个greenlet遇到IO操作时，比如访问网络，就自动切换到其他的greenlet，等到IO操作完成，再在适当的时候切换回来继续执行。
由于IO操作非常耗时，经常使程序处于等待状态，有了gevent为我们自动切换协程，就保证总有greenlet在运行，而不是等待IO。
