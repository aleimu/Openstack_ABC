from multiprocessing.dummy import Pool as ThreadPool
import time

"""
python multiprocessing.Pool 中map、map_async、apply、apply_async的区别
#进程池/线程池有共同的方法

区别         多参数       并发           阻塞         结果有序
map          no           yes            yes          yes
apply        yes          no             yes          no
map_async    no           yes            no           yes
apply_async  yes          yes            no           no

PS:上面的总结好像有点问题，主要是在阻塞和结果有序上不太准确,不清楚是否和python版本有关系

from multiprocessing import Pool as ProcessPool
from multiprocessing.dummy import Pool as ThreadPool

前者是多个进程，后者使用的是线程，之所以dummy（中文意思“假的”）
（一般CPU密集型的选择用多进程，IO密集型的可以选择多线程）

进程池的使用有四种方式：apply_async、apply、map_async、map。
其中apply_async和map_async是异步的，也就是启动进程函数之后会继续执行后续的代码不用等待进程函数返回。
apply_async和map_async方式提供了一写获取进程函数状态的函数：ready()、successful()、get()。
PS：join()语句要放在close()语句后面。


阻塞与非阻塞，同步与异步的区别
{
#参考博客
http://www.cnblogs.com/rama/p/4362593.html
http://www.cnblogs.com/peter1994/p/7645338.html
http://www.cnblogs.com/Anker/p/5965654.html
https://www.ibm.com/developerworks/cn/linux/l-async/

在进行网络编程时,我们常常见到同步(Sync)/异步(Async)，阻塞(Block)/非阻塞(Unblock)四种调用方式。这些方式彼此概念并不好理解。下面是我对这些术语的理解。


同步: 所谓同步,就是在发出一个功能调用时,在没有得到结果之前,该调用就不返回。按照这个定义,其实绝大多数函数都是同步调用.

异步: 当一个异步过程调用发出后,调用者不能立刻得到结果。实际处理这个调用的部件在完成后,通过状态、通知和回调来通知调用者。

阻塞: 阻塞调用是指调用结果返回之前,当前线程会被挂起（线程进入非可执行状态,在这个状态下,cpu不会给线程分配时间片,即线程暂停运行,把计算资源让给其他活动线程，当I/O操作结束，该线程阻塞状态解除，重新变成活动线程，继续争用CPU）。函数只有在得到结果之后才会返回。有人也许会把阻塞调用和同步调用等同起来,实际上它们是不同的。对于同步调用来说,很多时候当前线程还是激活的,只是从逻辑上当前函数没有返回而已。

非阻塞: 非阻塞和阻塞的概念相对应,指在不能立刻得到结果之前,该函数不会阻塞当前线程,而会立刻返回。

对象的阻塞模式和阻塞函数调用
对象是否处于阻塞模式和函数是不是阻塞调用有很强的相关性,但是并不是一一对应的。阻塞对象上可以有非阻塞的调用方式,我们可以通过一定的API去轮询状态,在适当的时候调用阻塞函数,就可以避免阻塞。而对于非阻塞对象,调用特殊的函数也可以进入阻塞调用。函数select就是这样的一个例子。

1. 同步: 就是我调用一个功能，该功能没有结束前，我死等结果。
2. 异步: 就是我调用一个功能，不需要知道该功能结果，该功能有结果后通知我（回调通知）
3. 阻塞: 就是调用我（函数），我（函数）没有接收完数据或者没有得到结果之前，我不会返回。
4. 非阻塞: 就是调用我（函数），我（函数）立即返回，通过select通知调用者

同步IO和异步IO的区别就在于：数据拷贝的时候进程是否阻塞！
阻塞IO和非阻塞IO的区别就在于：应用程序的调用是否立即返回！

同步和异步,阻塞和非阻塞,有些混用,其实它们完全不是一回事,而且它们修饰的对象也不相同。 阻塞和非阻塞是指当进程访问的数据如果尚未就绪,进程是否需要等待,简单说这相当于函数内部的实现区别,也就是未就绪时是直接返回还是等待就绪;

而同步和异步是指访问数据的机制,同步一般指主动请求并等待I/O操作完毕的方式,当数据就绪后在读写的时候必须阻塞(区别就绪与读写二个阶段,同步的读写必须阻塞),异步则指主动请求数据后便可以继续处理其它任务,随后等待I/O,操作完毕的通知,这可以使进程在数据读写时也不阻塞。(等待"通知")
}

#函数

apply(func[, args[, kwds]]) ：使用arg和kwds参数调用func函数，结果返回前会一直阻塞，由于这个原因，apply_async()更适合并发执行，另外，func函数仅被pool中的一个进程运行。

apply_async(func[, args[, kwds[, callback[, error_callback]]]]) ： apply()方法的一个变体，会返回一个结果对象。如果callback被指定，那么callback可以接收一个参数然后被调用，当结果准备好回调时会调用callback，调用失败时，则用error_callback替换callback。 Callbacks应被立即完成，否则处理结果的线程会被阻塞。

close() ： 阻止更多的任务提交到pool，待任务完成后，工作进程会退出。

terminate() ： 不管任务是否完成，立即停止工作进程。在对pool对象进程垃圾回收的时候，会立即调用terminate()。

join() : wait工作线程的退出，在调用join()前，必须调用close() or terminate()。这样是因为被终止的进程需要被父进程调用wait（join等价与wait），否则进程会成为僵尸进程。
"""


def fun(msg):
    print('msg: ', msg)
    time.sleep(1)
    print('********')
    return 'fun_return %s' % msg

# map_async
def map_async_test():

    print('\n------map_async-------')
    arg = range(100)
    async_pool = ThreadPool(processes=10)
    result = async_pool.map_async(fun, arg)
    print(result.ready())  # 线程函数是否已经启动了
    print('map_async: 不堵塞')
    result.wait()  # 等待所有线程函数执行完毕
    print('after wait')
    if result.ready():  # 线程函数是否已经启动了
        if result.successful():  # 线程函数是否执行成功
            print(result.get())  # 线程函数返回值

# map
def map_test():

    print('\n------map-------')
    arg = range(100)
    pool = ThreadPool(processes=10)
    return_list = pool.map(fun, arg)
    print('map: 堵塞')
    pool.close()
    pool.join()
    print(return_list)

# apply_async
def apply_async_test():

    print('\n------apply_async-------')
    async_pool = ThreadPool(processes=10)
    results = []
    for i in range(100):
        msg = 'msg: %d' % i
        result = async_pool.apply_async(fun, (msg, ))
        results.append(result)

    print('apply_async: 不堵塞')
    # async_pool.close()
    # async_pool.join()
    for i in results:
        i.wait()  # 等待线程函数执行完毕

    for i in results:
        if i.ready():  # 线程函数是否已经启动了
            if i.successful():  # 线程函数是否执行成功
                print(i.get())  # 线程函数返回值

# apply
def apply_test():

    print('\n------apply-------')
    pool = ThreadPool(processes=10)
    results = []
    for i in range(100):
        msg = 'msg: %d' % i
        result = pool.apply(fun, (msg, ))
        results.append(result)

    print('apply: 堵塞')
    print(results)


print('-----map*-------')
map_test()
map_async_test()
print('-----apply*-------')
apply_test()
apply_async_test()
print('-----end!-------')
