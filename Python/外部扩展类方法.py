class A():
    def m2():
        print("m2")

    def m0():
        print("m0")


def m1(self):  # 扩展不带参数的方法
    print("m1")


def m11(self, *arg1):   # 扩展带参数的方法
    print(*arg1)


def m0(self):  # 重写已经类中已存在的方法
    print("m00")

_m00 = A.m0     #先固定下来，防止递归调用


def m00(self):  # 继承已经类中已存在的方法并完善部分功能
    _m00()
    print("m00000")

A.m1 = m1
A.m11 = m11
A.m0 = m0

a = A()
a.m1()
a.m11(1, 2, 3)
a.m0()
#############
A.m0 = m00
b = A()
b.m0()
