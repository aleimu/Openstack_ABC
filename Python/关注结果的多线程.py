from multiprocessing.dummy import Pool as ThreadPool
import time
class duojincheng():
    def task_1(self,x):
        print('task_1', x)
        time.sleep(2)
        #raise Exception('2')
        return
        raise Exception('2')

    def task_2(self,x):
        print('task_2',x)
        if x==5:
            time.sleep(5)
            raise Exception('5')
        else:
            time.sleep(0.2)
            return

    def check_other_comps_ssl(self):
        templates = range(40)

        def task(template):
            ret1 = self.task_1(template)
            ret2 = self.task_2(template)

        def count(arg):
            self.counts = self.counts + 1
            print('self.count:%s ' % self.counts)

        pool = ThreadPool(10)
        results = []
        result2=[]
        for template in templates:
            result = pool.apply_async(func=task, args=(template,))
            results.append(result)
        for i in results:
            i.wait()  # 等待线程函数执行完毕
        for i in results:
            if i.ready():  # 线程函数是否已经启动了
                if i.successful():  # 线程函数是否执行成功
                    print(i.get())  # 线程函数返回值
                    result2.append(i.get())
        pool.close()
        pool.join()
        print('templates:%s ' % len(templates))
        print("result2:",result2)
        print(len(result2))
        assert len(result2)==len(templates)

a=duojincheng()
a.check_other_comps_ssl()
