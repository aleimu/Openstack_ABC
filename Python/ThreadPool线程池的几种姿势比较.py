from multiprocessing.pool import ThreadPool
#from multiprocessing.dummy import Pool as ThreadPool
#这两个ThreadPool好像区别不大，方法基本一样
import time

def test1(x):
    print("x1:", x)
    try:
        time.sleep(0.1)
        if x == 8:
            time.sleep(10)
        elif x == 12:
            time.sleep(5)
        elif x == 49:
            time.sleep(20)
            print('这里等待时间最长!')
        else:
            return
    except Exception as e:
        print('error1:', e)
    raise Exception('timeout error1 ', x)  # 只要没走return都会触发此异常

def test2(x):
    print("x2:", x)
    try:
        time.sleep(0.1)
        if x == 9:
            time.sleep(1)
        elif x == 11:
            time.sleep(5)
        elif x == 40:
            time.sleep(10)
        else:
            return
    except Exception as e:
        print('error2:', e)
    raise Exception('timeout error2 ', x)

def task(x):
    ret1 = test1(x)
    ret2 = test2(x)
    print('ret1 and ret2: ', ret1, ret2)
    #下面这些条件判断其实是不必要的，因为异常发生前get的结果已经是None了，而异常发生时这里的else语句没机会执行
    if ret1 is None and ret2 is None:
        return
    else:
        return 1
        #raise Exception('test1 or test2 is timeout!')



#apply_async---error
def dome0():
    time1 = time.time()
    result1 = []
    pool = ThreadPool(20)
    for i in range(50):
        result = pool.apply_async(func=task, args=(i,))
        result1.append(result)

    pool.close()
    pool.join()
    time2 = time.time()
    print("time:", time2 - time1)
    # 结果分析
    #无法接收子线程的异常，主线程中不会报错，这样的实现是不合理的


#apply_async
def dome1():
    time1 = time.time()
    result1 = []
    result2 = []
    pool = ThreadPool(20)
    for i in range(50):
        result = pool.apply_async(func=task, args=(i,))
        # 怀疑会在 x==9 处报异常，因为sleep时间最短且可能在同一线程池中被处理，然而实际情况是在x==8处报异常
        # 在 if 后面最小的x 处中断 error is ('timeout error1 ', 8)，而与sleep时间无关
        result1.append(result)

    # 下面两句会影响总时间，只有wait时为10s，加上join时20s，可以看出join会运行所有的子线程
    # pool.close()
    # pool.join()

    # print('=====if====1') #这种方式能检测出子线程的超时异常
    # try:
    #     for i in result1:
    #         i.wait()  # 等待线程函数执行完毕
    #         print('success:',i.successful())
    #         print('ready:',i.ready())
    #         print('get:',i.get())   # 线程函数返回值
    #         if i.ready():  # 线程函数是否已经启动了
    #             if i.successful():  # 线程函数是否执行成功
    #                 result2.append(i.get())
    # except Exception as e:
    #     print("error is %s" % str(e))
    # print('=====if====1')

    print('=====while====2')
    # 与1基本一样，放到tempest中再比较一下，线程的等待情况，基本不要用while，目前来看和if真的没区别
    try:
        for i in result1:
            i.wait(timeout=60)
            while i.ready():
                print("ready %s" % i.ready())
                print("successful %s" % i.successful())
                print("i.get %s" % i.get())
                if i.successful():
                    result2.append(i.get())
                    break
    except Exception as e:
        print("error is %s" % str(e))
    print('=====while====2')

    print("result2 and len: ", (result2, len(result2)))
    time2 = time.time()
    print("time:", time2 - time1)
    # 结果分析
    # error is ('timeout error1 ', 8)
    # result2 and len: ([None, None, None, None, None, None, None, None], 8)
    # time: 20.839099645614624
    # 线程按 x 的进入顺序触发异常，而与sleep时间无关
    # 可以i.get()得到异常发生前的返回，这一点是map类方法无法做到的
    # 异常发生后其他线程并没有中断，还是执行最长的sleep(20)，导致最后time 为20s

#map_async
def dome2():
    result2 = []
    time1 = time.time()
    pool = ThreadPool(20)
    my_iter = range(50)
    try:
        result = pool.map_async(task, my_iter)
        # 怀疑会在 x==9 处报异常，因为sleep时间最短且可能在同一线程池中被处理
        # 在 if 后面时间最短处中断 error is ('timeout error2 ', 9)，而与sleep时间有关
        # map和map_async 不按 x 的进入顺序处理
        #下面两句加不加好像不影响，wait已经等待了
        pool.close()
        pool.join()
        result.wait()  # 等待所有线程函数执行完毕

        #放在这里打印可以提前预警，知道错误产生的原因
        print("ready %s" % result.ready())
        print("successful %s" % result.successful())
        print("i.get %s" % result.get())

        print('=====if====1')
        if result.ready():  # 线程函数是否已经启动了
            if result.successful():  # 线程函数是否执行成功
                result2.append(result.get())
                # 以下函数在全部线程都执行成功时可以重复执行,返回值相同，但异常时只能执行一次successful/get
                print("ready %s" % result.ready())
                print("successful %s" % result.successful())
                print("i.get %s" % result.get())
                print("ready %s" % result.ready())
                print("successful %s" % result.successful())
                print("i.get %s" % result.get())
                # error is ('timeout error2 ', 9)
                # result2 and len:  ([], 0)
        print('=====if====1')

        # print('=====while====2')
        # while result.ready():
        #     if result.successful():
        #         result2.append(result.get())
        #         break
        #         #while 并不合适在map类的方法中,因为map类是完成全部线程的运行后才返回数据
        #         #如果非要使用，while外面需要有 result.successful()、result.get()的提前调用
        #         #来结束线程结果不能返回的异常。(因为线程一直是ready==True状态)
        # print('=====while====2')

    except Exception as e:
        print("error is %s" % str(e))
    print("result2 and len: ", (result2, len(result2)))
    time2 = time.time()
    print("time:", time2 - time1)
    # 结果分析
    # result2 and len: ([], 0)
    # time: 20.790918588638306
    # map会跑全部的线程，x==9时触发异常的等待时间最短
    # 异常发生后其他线程并没有中断，还是执行最长的sleep(20)，导致最后time 为20s
    # 一旦有线程异常，result.get()就得不到数据了

#map
def dome3():
    time1 = time.time()
    pool = ThreadPool(20)
    my_iter = range(50)
    try:
        result = pool.map(task, my_iter)
        pool.close()
        pool.join()
        print('result : ', result)
    except Exception as e:
        print("error is %s" % str(e))
    time2 = time.time()
    print("time:", time2 - time1)
    # 结果分析
    #error is ('timeout error2 ', 9)
    #time: 20.84999394416809
    # 也是并发执行，x==9时触发异常的等待时间最短
    # 异常发生后其他线程并没有中断，还是执行最长的sleep(20)，导致最后time 为20s
    # 一旦有线程异常，result = pool.map(task, my_iter)就会Exception,得不到返回数据

# apply
def dome4():
    time1 = time.time()
    pool = ThreadPool(20)
    results = []
    try:
        for i in range(50):
            result = pool.apply(task, (i,))
            results.append(result)
        print(results)
    except Exception as e:
        print("error is %s" % str(e))
    time2 = time.time()
    print("time:", time2 - time1)
    #结果分析
    #error is ('timeout error1 ', 8)
    #time: 11.943454027175903
    #一步一步执行，并没有并发，基本和单线程一样，异常发生后就不再往下执行

#map_async---上面的map_async其实不需要if判断的
def dome5():
    result2 = []
    time1 = time.time()
    pool = ThreadPool(20)
    my_iter = range(50)
    try:
        result = pool.map_async(task, my_iter)
        # 怀疑会在 x==9 处报异常，因为sleep时间最短且可能在同一线程池中被处理
        # 在 if 后面时间最短处中断 error is ('timeout error2 ', 9)，而与sleep时间有关
        # map和map_async 不按 x 的进入顺序处理
        #下面两句加不加好像不影响，wait已经等待了
        pool.close()
        pool.join()
        result.wait()  # 等待所有线程函数执行完毕
        #放在这里打印可以触发异常，不然就算子线程异常了，主线程也不会知道
        print("ready %s" % result.ready())
        print("successful %s" % result.successful())
        print("i.get %s" % result.get())
    except Exception as e:
        print("error is %s" % str(e))
    print("result2 and len: ", (result2, len(result2)))
    time2 = time.time()
    print("time:", time2 - time1)
    # 结果分析
    #对比dome2，这里的更简洁一些，不需要多余的if判断，子线程有异常直接接收就好

if __name__ == "__main__":
    dome0()
#总结:
# 1. 不建议使用while，因为和if基本一样的功能，主线程会等待子线程，不需要轮询
# 2. apply_async中加上join会增加异常发生时总的时间(会把全部的线程都运行了，异常发生时会中断异常线程，其他线程不影响，但get的结果只收集异常发生前的线程返回)。
#    异常会发生在最快进入sleep的线程中，get返回结果是x最先进入sleep触发异常前的线程(x=8,sleep(10))的结果，总消耗时间在不加join情况下也以此x为准，但当加join后总消耗时间会以最长sleep的为参考，也就是说会运行所有的线程，但get的结果还是第一个异常触发前的x<8的其他线程的结果
# 3. map_async中加不加join一样。map总是把全部线程都执行，异常会发生在sleep最短(x=9,sleep(1))的线程中，返回结果时以sleep最短的异常为准，但总消耗时间以sleep最长的为准，发生异常就get不到结果
# 4. 无论是map还是apply，若只是多线程发送请求不关注结果，可以不用加result.wait()、result.successful(
    # )、result.get()，如果要关注就必须加上，这样才能接收子线程的异常，这就是异步。
