
# 参数的传递
class test():
    def wrap(self, func, a, b=0, *args, **kwargs):
        print("a get a, b:", a, b)
        func(*args, **kwargs)

    def func(self, c, d=0):
        print("b get c, d:", c, d)

    def main(self, a, b, c):
        print("---------1---------")
        print("c get a, b, c:", a, b, c)
        self.wrap(self.func, a=1, b=b, c=c, d=(4, 5, 6, 7))  # ok
        self.wrap(self.func, a=1, b=b, c=c, d=4)             # ok
        self.wrap(self.func, 1, b, c, 4) # ok
        self.wrap(self.func, 1, b, c)    # ok
        #self.wrap(self.func, 1, b)       # error,无法将只有的两个参数正确传给a、c
        self.wrap(self.func, a=1, c=c)   # 这样才可以
        print("---------2---------")

dome = test()
dome.main(1, 2, 3)
"""
1.  func(arg1,arg2,...)
2.  func(arg1,arg2=value2,...)
3.  func(*arg1)
4.  func(**arg1)
先1，后2，再3，最后4，也就是先把方式1中的arg解析，然后解析方式2中的arg=value，再解析方式3，即是把多出来的arg这种形式的实参组成个tuple传进去，最后把剩下的key=value这种形式的实参组成一个dictionary传给带俩个星号的形参，也就方式4。
"""
