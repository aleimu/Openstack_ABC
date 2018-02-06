进程与线程的区别？
1.线程是执行的指令集，进程是资源的集合
2.线程的启动速度要比进程的启动速度要快
3.两个线程的执行速度是一样的
4.进程与线程的运行速度是没有可比性的
5.线程共享创建它的进程的内存空间，进程的内存是独立的。
6.两个线程共享的数据都是同一份数据，两个子进程的数据不是共享的，而且数据是独立的;
7.同一个进程的线程之间可以直接交流，同一个主进程的多个子进程之间是不可以进行交流，如果两个进程之间需要通信，就必须要通过一个中间代理来实现;
8.一个新的线程很容易被创建，一个新的进程创建需要对父进程进行一次克隆
9.一个线程可以控制和操作同一个进程里的其他线程，线程与线程之间没有隶属关系，但是进程只能操作子进程
10.改变主线程，有可能会影响到其他线程的行为，但是对于父进程的修改是不会影响子进程

#在python中，主线程语句结束后，会默认等待子线程全部结束后，主线程才退出。join和setDaemon的功能基本是相反的；join主要是设置主线程语句等待的程度，而setDamon主要是设置主线程或某子线程是否等待
{
#setDaemon()方法
主线程A中，创建了子线程B，并且在主线程A中调用了B.setDaemon(),这个的意思是，把主线程A设置为守护线程，这时候，要是主线程A执行结束了，就不管子线程B是否完成,一并和主线程A退出.这就是setDaemon方法的含义，这基本和join是相反的。此外，还有个要特别注意的：必须在start() 方法调用之前设置，如果不设置为守护线程，程序会被无限挂起。

#join()方法的例子

#!/usr/bin/env python
# -*- coding: utf-8 -*-
import threading
import time

t1 = time.time()

def task(n):
    print("sleep:", n, "start!")
    time.sleep(20 - n)
    print("sleep:", n, "end!")
for i in range(20):
    t = threading.Thread(target=task, args=(i,))
    #t.setDaemon(True)  # 必须在t.start()之前设置
    t.start()
    #t.join() # 当前线程执行完毕之后在执行后面的线程
#t.join() # 当i=19时在执行后面的线程,主线程后面的语句并不会等到0-18的线程结束就会执行，但主线程还是会等到全部的子线程结束后再退出
t2 = time.time()
print(t2 - t1)
#在python中，主线程语句结束后，会默认等待子线程全部结束后，主线程才退出。与第19行的join效果一样。

import threading
import time
def task(n):
    print("sleep:", n, "start!")
    time.sleep(20 - n)
    print("sleep:", n, "end!")
# 执行子线程的时间
start_time = time.time()
# 存放线程的实例
t_objs = []
for i in range(20):
    t = threading.Thread(target=task, args=(i,))
    t.start()
    # 为了不让后面的子线程阻塞，把当前的子线程放入到一个列表中
    t_objs.append(t)
# 循环所有子线程实例，等待所有子线程执行完毕
for t in t_objs:
    t.join() #主线程一直等
    #t.join(0.5) #7.017472028主线程就会接着执行后面的语句print
# 当前时间减去开始时间就等于执行的过程中需要的时间
print(time.time() - start_time)
}
