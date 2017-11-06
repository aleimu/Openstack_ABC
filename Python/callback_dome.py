from multiprocessing.dummy import Pool as ThreadPool
import time
class duojincheng():
    counts=0
    def task_1(self,x):
        time.sleep(2)
        #raise Exception('2')
        return
        raise Exception('2')

    def task_2(self,x):
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

            print('ret1 and ret2:%s ' % (ret1 and ret2))
            if (ret1 and ret2) is None:
                return
            else:
                raise Exception('Child process of task exception, may be timeout')

        def count(arg):
            self.counts = self.counts + 1
            print('self.count:%s ' % self.counts)

        pool = ThreadPool(10)
        for template in templates:
            pool.apply_async(func=task, args=(template,), callback=count)
        pool.close()
        pool.join()
        #time.sleep(10)
        print("counts: %s " % self.counts)
        print('templates:%s ' % len(templates))
        if len(templates) != self.counts:
            raise Exception('process of task exception, may be timeout')

a=duojincheng()
a.check_other_comps_ssl()
