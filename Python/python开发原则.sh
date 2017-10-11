python开发原则：

1、如果需要交换两个变量的值使用 a,b=b,a 而不是借助中间变量 t=a;a=b;b=t；
>>> from timeit import Timer 
>>> Timer("t=a;a=b;b=t","a=1;b=2").timeit() 
0.25154118749729365 
>>> Timer("a,b=b,a","a=1;b=2").timeit() 
0.17156677734181258 
>>  

2、在循环的时候使用 xrange 而不是 range；使用 xrange 可以节省大量的系统内存。
因为 xrange() 在序列中每次调用只产生一个整数元素。而 range() 將直接返回完整的元素列表，用于循环时会有不必要的开销。
在 python3 中 xrange 不再存在，里面 range 提供一个可以遍历任意长度的范围的 iterator；

3、使用局部变量，避免”global” 关键字。python 访问局部变量会比全局变量要快得多，因此可以利用这一特性提升性能；

4、if done is not None 比语句 if done != None 更快；

5、在耗时较多的循环中，可以把函数的调用改为内联的方式；

6、使用级联比较 “x < y < z” 而不是 “x < y and y < z”；

7、while 1 要比 while True 更快（当然后者的可读性更好）；

8、build in 函数通常较快，add(a,b) 要优于 a+b。
