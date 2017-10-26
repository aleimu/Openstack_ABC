#参考博文
http://www.cnblogs.com/huanxiyun/articles/5826902.html
http://www.cnblogs.com/huanxiyun/articles/5826902.html

对于计算密集型程序，多进程并发优于多线程并发。计算密集型程序指的程序的运行时间大部分消耗在CPU的运算处理过程，而硬盘和内存的读写消耗的时间很短；
相对地，IO密集型程序指的则是程序的运行时间大部分消耗在硬盘和内存的读写上，CPU的运算时间很短。对于网络通信等IO密集型任务来说，决定程序效率的主要是网络延迟，这时候是使用进程还是线程就没有太大关系了。

http://blog.csdn.net/pirlck/article/details/52296716    # 多进程和多线程的应用场景

#能用多进程方便的解决问题的时候不要使用多线程
