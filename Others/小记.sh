#Linux运维面试题
{
1、Linux如何挂在windows下的共享目录？
mount.cifs //192.168.1.3/server /mnt/server -o user=administrator,pass=123456
linux 下的server需要自己手动建一个,后面的user与pass 是windows主机的账号和密码,注意空格和逗号

2、查看http的并发请求数与其TCP连接状态。
netstat -n | awk '/^tcp/ {++b[$NF]} END {for(a in b) print a, b[a]}'
还有ulimit -n 查看linux系统打开最大的文件描述符，这里默认1024，不修改这里web服务器修改再大也没用。若要用就修改很几个办法，这里说其中一个：
修改/etc/security/limits.conf
* soft nofile 10240
* hard nofile 10240
重启后生效

3、用tcpdump嗅探80端口的访问看看谁最高。
tcpdump -i eth0 -tnn dst port 80 -c 1000 | awk -F"." '{print $1"."$2"."$3"."$4}' | sort | uniq -c | sort -nr |head -5  

4、查看/var/log目录下文件数。
ls /var/log/ -lR| grep "^-" |wc -l

5、查看当前系统每个IP的连接数。
netstat -n | awk '/^tcp/ {print $5}'| awk -F: '{print $1}' |sort | uniq -c | sort -rn

6、shell下32位随机密码生成。
cat /dev/urandom | head -1 | md5sum | head -c 32 >> /pass
将生成的32位随机数 保存到/pass文件里了

7、统计出apache的access.log中访问量最多的5个IP。
cat access_log | awk '{print $1}' | sort | uniq -c | sort -n -r | head -5

8、如何查看二进制文件的内容？
我们一般通过hexdump命令 来查看二进制文件的内容。
hexdump -C XXX(文件名) -C是参数 不同的参数有不同的意义
-C 是比较规范的 十六进制和ASCII码显示
-c 是单字节字符显示
-b 单字节八进制显示
-o 是双字节八进制显示
-d 是双字节十进制显示
-x 是双字节十六进制显示

9、ps aux 中的VSZ代表什么意思，RSS代表什么意思？
VSZ:虚拟内存集,进程占用的虚拟内存空间
RSS:物理内存集,进程战用实际物理内存空间

10、检测并修复/dev/hda5。
fsck用来检查和维护不一致的文件系统。若系统掉电或磁盘发生问题，可利用fsck命令对文件系统进行检查,用法：
umount /dev/hda5 ; e2fsck -p /dev/hda5；mount /dev/hda5

11、Linux系统的开机启动顺序。

开机顺序：
1).BIOS程序读取CMOS上的信息到内存中，取得各项硬件的参数，对硬件进行检测和初始化（POST，Power-on self-test，加电自检），并决定启动设备次序。
2).BIOS读取MBR中的引导装载程序（boot loader）到内存中。
3).引导装载程序将内核文件读入内存，内核加载后，重新检测硬件并加载各硬件的驱动程序，使硬件准备就绪！
4).运行第一个进程initrd，并逐步启动各种服务。
5).此外，如果是多系统主机，还包括引导加载程序和grub的内容。每个分区也会有引导扇区（boot sector），用于完成多重引导功能。

12、符号链接与硬链接的区别。

1).硬连接（实际连接）：在目录的block中将多个文件名对应一个inode，可以理解为文件的别名，不需要占有额外的inode和block，只需要在目录的block下添加点数据。只能对文件使用硬连接，对目录不行。使用命令 ln filename1 filename2，将文件filename1产生一个硬连接（别名）filename2.
2).符号连接（快捷方式）：创建一个文件（inode+block），block记载需连接文件的目录的inode及该文件的文件名，变形成了符号链接，可以理解为快捷方式。符号连接可以针对目录。ln –s filename1 filename2
我们可以把符号链接，也就是软连接 当做是 windows系统里的快捷方式.
硬链接就好像是又复制了一份.
ln 3.txt 4.txt 这是硬链接，相当于复制，不可以跨分区，但修改3,4会跟着变，若删除3,4不受任何影响。
ln -s 3.txt 4.txt 这是软连接，相当于快捷方式。修改4,3也会跟着变，若删除3,4就坏掉了。不可以用了。

13、保存当前磁盘分区的分区表。

dd 命令是以个强大的命令，在复制的同时进行转换
dd if=/dev/sda of=./mbr.txt bs=1 count=512
还可以这样：
sfdisk -d /dev/sdb >/etc/sdbpar.bak ：保存分区表
sfdisk –d /dev/sdb：查看整块硬盘sdb的分区表

14、我自己来个简单的，如何在文本里面进行复制、粘贴，删除行，删除全部，按行查找和按字母查找。

以下操作全部在命令行状态操作，不要在编辑状态操作。
在文本里 移动到想要复制的行 按yy 想复制到哪就移动到哪，然后按P 就黏贴了
删除行 移动到改行 按dd
删除全部 dG 这里注意G一定要大写
按行查找 :90 这样就是找到第90行
按字母查找 /path 这样就是 找到path这个单词所在的位置，文本里可能存在多个,多次查找会显示在不同的位置。

15、手动安装grub。
grub-install /dev/sda

16、修改内核参数。
vim /etc/sysctl.conf 这里修改参数
sysctl -p 刷新后可用

17、在1-39内取随机数。
expr $[$RANDOM%39] + 1
RANDOM 随机数
%39 取余数 范围 0-38

18、限制apache每秒新建连接数为1，峰值为3。

每秒新建连接数 一般都是由防火墙来做，apache本身好像无法设置每秒新建连接数，只能设置最大连接：
iptables -A INPUT -d 172.16.100.1 -p tcp --dport 80 -m limit --limit
1/second -j ACCEPT
硬件防火墙设置更简单，有界面化，可以直接填写数字
最大连接 apache本身可以设置
MaxClients 3 ,修改apache最大连接 前提还是要修改系统默认tcp连接数。我博客里也说了，这就不说了

19、FTP的主动模式和被动模式。
FTP协议有两种工作方式：PORT方式和PASV方式，中文意思为主动式和被动式。
PORT（主动）方式的连接过程是：客户端向服务器的FTP端口（默认是21）发送连接请 求，服务器接受连接，建立一条命令链路。当需要传送数据时，客户端在命令链路上用PORT 命令告诉服务器：“我打开了XX端口，你过来连接我”。于是服务器从20端口向客户端的 XX端口发送连接请求，建立一条数据链路来传送数据。
PASV（被动）方式的连接过程是：客户端向服务器的FTP端口（默认是21）发送连接请 求，服务器接受连接，建立一条命令链路。当需要传送数据时，服务器在命令链路上用PASV 命令告诉客户端：“我打开了XX端口，你过来连接我”。于是客户端向服务器的XX端口 发送连接请求，建立一条数据链路来传送数据。
从上面可以看出，两种方式的命令链路连接方法是一样的，而数据链路的建立方法就完 全不同。

20、显示/etc/inittab中以#开头，且后面跟了一个或者多个空白字符，而后又跟了任意非空白字符的行。
grep "^# \{1,\}[^ ]" /etc/inittab

21、显示/etc/inittab中包含了:一个数字:(即两个冒号中间一个数字)的行。
grep "\:[0-9]\{1\}\:" /etc/inittab

22、怎么把脚本添加到系统服务里，即用service来调用？

在脚本里加入
#!/bin/bash
# chkconfig: 345 85 15
# description: httpd
然后保存
chkconfig httpd –add 创建系统服务
现在就可以使用service 来 start or restart

23、写一个脚本，实现批量添加20个用户，用户名为user01-20，密码为user后面跟5个随机字符。
#!/bin/bash
#description: useradd
for i in `seq -f"%02g" 1 20`;do
    useradd user$i
    echo "user$i:`echo $RANDOM|md5sum|cut -c 1-5`"|passwd –stdinuser$i >/dev/null 2>&1
done

24、写一个脚本，实现判断192.168.1.0/24网络里，当前在线的IP有哪些，能ping通则认为在线。
#!/bin/bash
for ip in `seq 1 255`
do
{
 ping -c 1 192.168.1.$ip > /dev/null 2>&1
 if [ $? -eq 0 ]; then
  echo 192.168.1.$ip UP
 else
  echo 192.168.1.$ip DOWN
 fi
}&
done
wait

25、写一个脚本，判断一个指定的脚本是否是语法错误；如果有错误，则提醒用户键入Q或者q无视错误并退出其它任何键可以通过vim打开这个指定的脚本。
[root@localhost tmp]# cat checksh.sh
#!/bin/bash
read -p "please input check script-> " file
if [ -f $file ]; then
sh -n $file > /dev/null 2>&1
if [ $? -ne 0 ]; then
 read -p "You input $file syntax error,[Type q to exit or 
 Type vim to edit]" answer
 case $answer in
 q | Q)
  exit 0
  ;;
 vim )
  vim $file
  ;;
 *）
  exit 0
  ;;
 esac
fi
else
echo "$file not exist"
exit 1
fi

26、写一个脚本（包括3个小题）。

创建一个函数，能接受两个参数：
1).第一个参数为URL，即可下载的文件；第二个参数为目录，即下载后保存的位置；
2).如果用户给的目录不存在，则提示用户是否创建；如果创建就继续执行，否则，函数返回一个51的错误值给调用脚本；
3).如果给的目录存在，则下载文件；下载命令执行结束后测试文件下载成功与否；如果成功，则返回0给调用脚本，否则，返回52给调用脚本；
[root@localhost tmp]# cat downfile.sh
#!/bin/bash
url=$1
dir=$2
download()
{
cd $dir >> /dev/null 2>&1
if [ $? -ne 0 ];then
 read -p "$dir No such file or directory,create?(y/n)" answer
 if [ "$answer" == "y" ];then
  mkdir -p $dir
  cd $dir
  wget $url 1> /dev/null 2>&1
 else
  return "51"
 fi
fi
if [ $? -ne 0 ]; then
 return "52"
fi
}
download $url $dir
echo $
}

#常见的算法面试题
{
1、快速排序
import timeit

def quicksort(A, B, ls):
    if A < B:
        a = A
        b = B
        t = ls[A]
        while a < b:
            while t < ls[a] and B > a:
                a += 1
            while ls[b] < t and b > A:
                b -= 1
            if a <= b:
                k = ls[a]
                ls[a] = ls[b]
                ls[b] = k
                a = a + 1
                b = b - 1
        quicksort(a, B, ls)
        quicksort(A, b, ls)

def quicksort(A, B, ls):
    if A < B:
        a = A
        b = B
        t = ls[A]
        while a < b:
            while t < ls[a] and B > a:
                a += 1
            while ls[b] < t and b > A:
                b -= 1
            if a <= b:
                k = ls[a]
                ls[a] = ls[b]
                ls[b] = k
                a = a + 1
                b = b - 1
        if a < B:
            quicksort(a, B, ls)
        if b > A:
            quicksort(A, b, ls)

            
lss = [12, 0, 3, 45, 43, 76, 42, 34, 12, 3, 1, 3, 4, 5]
def test():
    ls = lss[:]
    quicksort(0, len(ls) - 1, ls)
if __name__ == '__main__':
    import timeit
    print(timeit.timeit("test()", setup="from __main__ import test", number=100000))

2、二分法查找
def binary_search(array,key):
    low = 0
    high = len(array) - 1
    while low < high:
        mid = int((low + high)/2)
        if key < array[mid]:
            high = mid - 1
        elif key > array[mid]:
            low = mid + 1
        else:
            return mid
    return False
array = [1,2,3,4,5,6,7,8,9,10,14,15,17,21,24,28,35,35,37,39]
result = binary_search(array,7)

3、希尔排序每趟并不使某些元素有序，而是使整体数据越来越接近有序；最后一趟排序使得所有数据有序。
def shell_sort(li):
    gap = int(len(li)//2)   # 初始把列表分成 gap个组，但是每组最多就两个元素，第一组可能有三个元素
    while gap >0:
        for i in range(gap,len(li)):
            tmp = li[i]
            j = i - gap
            while j>0 and tmp<li[j]:    # 对每一组的每一个数，都和他前面的那个数比较，小的在前面
                li[j+gap] = li[j]
                j -= gap
            li[j+gap] = tmp
        gap = int(gap//2)　　　　# Python3中地板除也是float类型
    return li

4、五大常用算法
    http://www.cnblogs.com/steven_oyj/category/246990.html
    1.分治算法
    分治法在每一层递归上都有三个步骤：
    step1 分解：将原问题分解为若干个规模较小，相互独立，与原问题形式相同的子问题；
    step2 解决：若子问题规模较小而容易被解决则直接解，否则递归地解各个子问题
    step3 合并：将各个子问题的解合并为原问题的解。

    2.贪心算法
    3.动态规划(解公司外包成本问题）
    与分治法最大的差别是：适合于用动态规划法求解的问题，经分解后得到的子问题往往不是互相独立的（即下一个子阶段的求解是建立在上一个子阶段的解的基础上，进行进一步的求解）。
    （1）分析最优解的性质，并刻画其结构特征。
    （2）递归的定义最优解。
    （3）以自底向上或自顶向下的记忆化方式（备忘录法）计算出最优值
    （4）根据计算最优值时得到的信息，构造问题的最优解

    4.回溯算法（解火力网问题）
    （1）针对所给问题，确定问题的解空间：首先应明确定义问题的解空间，问题的解空间应至少包含问题的一个（最优）解。
    （2）确定结点的扩展搜索规则
    （3）以深度优先方式搜索解空间，并在搜索过程中用剪枝函数避免无效搜索。

    5.分支限界算法  
    回溯法以深度优先的方式搜索解空间树T，而分支限界法则以广度优先或以最小耗费优先的方式搜索解空间树T。

5、广度优先搜索算法(Breadth First Search，BSF)
思想是：
1.从图中某顶点v出发，首先访问定点v
2.在访问了v之后依次访问v的各个未曾访问过的邻接点；
3.然后分别从这些邻接点出发依次访问它们的邻接点，并使得“先被访问的顶点的邻接点先于后被访问的顶点的邻接点被访问;
4.直至图中所有已被访问的顶点的邻接点都被访问到;
5.如果此时图中尚有顶点未被访问，则需要另选一个未曾被访问过的顶点作为新的起始点，重复上述过程，直至图中所有顶点都被访问到为止。

6、深度优先搜索(Depth First Search, DFS)，和树的前序遍历非常类似
它的思想：
1.从顶点v出发，首先访问该顶点;
2.然后依次从它的各个未被访问的邻接点出发深度优先搜索遍历图;
3.直至图中所有和v有路径相通的顶点都被访问到。
4.若此时尚有其他顶点未被访问到，则另选一个未被访问的顶点作起始点，重复上述过程，直至图中所有顶点都被访问到为止

7、算法复杂度分析
#推导大O阶
1.用常数1取代运行时间中的所有加法常数。
2.在修改后的运行次数函数中，只保留最高阶项。
3.如果最高阶项存在且不是1，则去除与这个项相乘的常数。
得到的结果就是大O阶。
http://www.cnblogs.com/cj723/archive/2011/03/05/1971640.html #很不错
http://www.cnblogs.com/gaochundong/p/complexity_of_algorithms.html
http://www.cnblogs.com/songQQ/archive/2009/10/20/1587122.html

复杂度	标记符号	描述
常量（Constant）	O(1) 操作的数量为常数，与输入的数据的规模无关。n = 1,000,000 -> 1-2 operations 
对数（Logarithmic）	O(log2 n) 操作的数量与输入数据的规模 n 的比例是 log2 (n)。n = 1,000,000 -> 30 operations
线性（Linear）	 O(n)	操作的数量与输入数据的规模 n 成正比。n = 10,000 -> 5000 operations
平方（Quadratic）	 O(n2)	操作的数量与输入数据的规模 n 的比例为二次平方。n = 500 -> 250,000 operations
立方（Cubic）	 O(n3)	操作的数量与输入数据的规模 n 的比例为三次方。n = 200 -> 8,000,000 operations
指数（Exponential）	O(2n) O(kn) O(n!)指数级的操作，快速的增长。n = 20 -> 1048576 operations

常用对数 log10 N 简写做 lg N
自然对数 loge N 简写做 ln N
在算法导论中，采用记号 lg n = log2 n ，也就是以 2 为底的对数。

#对数阶
int count = 1;
while (count < n)
{
   count = count * 2;
   /*时间复杂度为O(1)的程序步骤序列*/
}
#由于每次count乘以2之后，就距离n更近了一分。也就是说，有多少个2相乘后大于n，则会退出循环。由2x=n得到x=log2n。所以这个循环的时间复杂度为O(logn)。



}

不停的堆砌已有的API........

#python面试题
{

}

linux下通过进程名查看其占用端口：

1、先查看进程pid
ps -ef | grep 进程名

2、通过pid查看占用端口
netstat -nap | grep 进程pid

程序＝数据结构＋算法

编译的本质就是：
把程序翻译成OS(或虚拟机)认识的数据结构和算法！
把程序里的“数据”分离出来，保存在“符号表（SymbolTable）”中；
把程序里的“算法”分离出来，保存在“中间代码表（CodeTable）”中。

首先把代码文件读进来，然后调用词法分析器，依次读出每个记号（token），例如“int num;”就是由“int ”、“num”、“;”三个记号组成。
再调用语法分析器分析记号，并翻译成中间代码（类似汇编的字节码）。理论上把这一步骤又细分成“语法分析、语义分析、中间代码生成、代码优化、目标代码生成”几个步骤，我觉得没有必要这么细分，直接生成中间代码就行了，因为运行在虚拟机上，也没有必要生成目标代码。
最后调用虚拟机执行中间代码。虚拟机说白了就是模拟OS执行目标代码的过程执行中间代码。

#语法制导

#等效转化
虚拟机不懂“if、for、while、do...shilw、switch”
虚拟值只懂“goto和if...goto”

#上下文无关文法

if (a > 5)
{
    str=“big”;
}
else
{
    str=“small”;
}

001  goto (line:003) //因为下一行是出口
002  goto (line:007) //if结构的出口
003  if !(a > 5) goto (line:006)
004  str=“big”;
005  goto (line:002) //true分支完成退出
006  str=“small”;
007  //fasle分支完成退出


#为什么需要三次握手
“三次握手”的目的是“为了防止已失效的连接请求报文段突然又传送到了服务端，因而产生错误”。在另一部经典的《计算机网络》一书中讲“三次握手”的目的是为了解决“网络中存在延迟的重复分组”的问题。这两种不用的表述其实阐明的是同一个问题。
 信道不可靠, 但是通信双发需要就某个问题达成一致. 而要解决这个问题,  无论你在消息中包含什么信息, 三次通信是理论上的最小值. 所以三次握手不是TCP本身的要求, 而是为了满足"在不可靠信道上可靠地传输信息"这一需求
 
#为什么需要四次分手
TCP是双向的，所以需要在两个方向分别关闭，每个方向的关闭又需要请求和确认，所以一共就4次。

seq:序列号，什么意思呢？当发送一个数据时，数据是被拆成多个数据包来发送，序列号就是对每个数据包进行编号，这样接受方才能对数据包进行再次拼接。
初始序列号是随机生成的，这样不一样的数据拆包解包就不会连接错了。（例如：两个数据都被拆成1，2，3和一个数据是1，2，3一个是101，102，103，很明显后者不会连接错误）
ack:这个代表下一个数据包的编号，这也就是为什么第二请求时，ack是seq+1

change_cc={'a':2,'b':1}
class test():
    def __init__(self):
        self.a=1
        self.b=[1,2,3,4,[6,7,8]]
        self.c={'a':self.a,'b':self.b} #--->初始化后，在单独改变self.a而不是通过self.c[
        # 'a']来改变，都是改变不了self.c的
    def aa(self):
        for x in range(10):
            self.c[x]=x
            if x==3:
                self.cc()
                print("self.a,self.b:",self.a,self.b)
                print("self.c:",self.c)
                print("change_cc:",change_cc)
                self.dd(self.c)
        print("self.c:",self.c)

    def cc(self):
        self.a = 'aaaaaa' #改变self.a/self.b 并没有影响c中的值
        self.b = 'bbbbbb'
        print("cc_self.c:", self.c)
        self.c['a'] = 'cccc' #这样改变才能改变self.c中的值
        self.c['b'] = 'cccc'
        change_cc['a'] = 'change_a'

    def dd(self, ee):
        print("dd:", ee)

dd = test()
print("dd.c:", dd.c)
dd.aa()


def ee():
    for x in range(10):
        print(x)
        if x==5:
            return x #return 会直接打断循环
            
当你老了，回顾一生，就会发觉：什么时候出国读书、什么时候决定做第一份职业、何时选定了对象而恋爱、什么时候结婚，其实都是命运的巨变。
只是当时站在三岔路口，眼见风云千樯，你作出抉择的那一日，在日记上，相当沉闷和平凡，当时还以为是生命中普通的一天。
—— 《杀鹌鹑的少女》



#面试准备
{

你熟悉哪些设计模式？ 
（答的单例，Builder，abstract工厂，策略，适配器，代理）

单例用了面向对象的什么特性？ 
（封装。。。）

你会写几种单例？ 
（这个问题答的还算不错，总共回答了4种写法，前段时间刚好做了总结，详情可以看博客 
单例模式学习总结）

线程有哪几种实现方式？ 
（一直没懂他问的是什么意思，事后想想可能是想问 
1. 继承runnable 
2. 继承Thread 
3. 利用线程池 
） 

知道线程池吗？ 
（不熟悉，如实告诉面试官。只知道是线程管理的方式，比如Android的AsyncTask）

HTTP和HTTPS的区别？ 
（不熟悉，如实告知..但是也提到了https是加密传输的，安全性更可靠。但是监听端口不同，https需要ssl证书之类的没说）

GET和POST的区别？ 
（GET直接在url后面，相当于明文传输；POST在报文实体，相当于暗文。两者限制的长度不一样。POST的长度限制远大于POST，具体长度忘记了，面试官也没多问）

说一下ArrayList的实现？ 
（数组封装，主要讲了下add的时候扩容1.5倍的问题）

一般大家都知道ArrayList和LinkedList的大致区别：
1.ArrayList是实现了基于动态数组的数据结构，LinkedList基于链表的数据结构。
2.对于随机访问get和set，ArrayList觉得优于LinkedList，因为LinkedList要移动指针。
3.对于新增和删除操作add和remove，LinedList比较占优势，因为ArrayList要移动数据。

线程互斥的方法？
四种进程或线程同步互斥的控制方法
1、临界区:通过对多线程的串行化来访问公共资源或一段代码，速度快，适合控制数据访问。 
2、互斥量:为协调共同对一个共享资源的单独访问而设计的。 
3、信号量:为控制一个具有有限数量用户资源而设计。 
4、事 件:用来通知线程有一些事件已发生，从而启动后继任务的开始。

并发

 

用过哪些数据库？ 
（移动端sqlite，写服务端的时候用过MySQL） 
用复杂sql语句的实践经验吗？ 
（没有） 
那一般写过什么？ 
（增插删改...） 
那你写一个，根据字段分组查询的语句 
（用是用了group by，但是太长时间不接触数据库，面试官说语法有问题）

tomcat 运行机制
先不去关技术细节，对一个servlet容器，我觉得它首先要做以下事情：
1:实现Servlet api规范。这是最基础的一个实现，servlet api大部分都是接口规范。如request、response、session、cookie。为了我们应用端能正常使用，容器必须有一套完整实现。

1:实现Servlet api规范。这是最基础的一个实现，servlet api大部分都是接口规范。如request、response、session、cookie。为了我们应用端能正常使用，容器必须有一套完整实现。

2：启动Socket监听端口，等待http请求。

3：获取http请求，分发请求给不同的协议处理器，如http和https在处理上是不一样的。

4：封装请求，构造HttpServletRequest。把socket获取的用户请求字节流转换成java对象httprequest。构造httpResponse。

5：调用(若未创建，则先加载)servlet，调用init初始化，执行servlet.service()方法。

6：为httpResponse添加header等头部信息。

7：socket回写流，返回满足http协议格式的数据给浏览器。

8：实现JSP语法分析器，JSP标记解释器。JSPservlet实现和渲染引擎。

9：JNDI、JMX等服务实现。容器一般额外提供命名空间服务管理。

10：线程池管理，创建线程池，并为每个请求分配线程。

Tcp三次握手

在TCP/IP协议中,TCP协议提供可靠的连接服务,采用三次握手建立一个连接.
第一次握手：建立连接时,客户端发送syn包(syn=j)到服务器,并进入SYN_SEND状态,等待服务器确认； 
SYN：同步序列编号(Synchronize Sequence Numbers)
第二次握手：服务器收到syn包,必须确认客户的SYN（ack=j+1）,同时自己也发送一个SYN包（syn=k）,即SYN+ACK包,此时服务器进入SYN_RECV状态； 
第三次握手：客户端收到服务器的SYN＋ACK包,向服务器发送确认包ACK(ack=k+1),此包发送完毕,客户端和服务器进入ESTABLISHED状态,完成三次握手.
完成三次握手,客户端与服务器开始传送数据


2.写一个排序算法

算法是同花顺比较看重的，算是一个传统了吧，楼主知道必考，但是基础问题有些薄弱，就觉得算是时间比较短，想着能用其他的点弥补一下，失策了，没太准备算是一大失误点，千万不要放弃任何可能性，不然想拿到offer也是很难的

3.聊聊你在所写的项目中框架和所写的最满意的代码

 楼主聊了聊ssh框架的一些基本工作内容和聊了聊公司做的一些东西，感觉这个比较活想，说的get到基本点然后说出大概基本就是可以的。

4.100万人抽奖你该如何设计

我给出的答案是准备过程中答出来的自己准备的关于并发，造成网络瘫痪，还及到如何设计表，避免数据库表全局搜索延缓数据的显示，造成用户体验不佳等，基本说到了内容点，但是一个比较大的问题是感觉面试官没有得到他想要的答案，所以我主动的问了一句是不是自己可能没有get到要点，面试官说出了他的设计想法，比较绝：他说是不是可以自己在服务端先做处理，把该抽到奖全部抽好，然后放到队列里，客户过来抽奖过来即可从队列一端拿走一个，避免了所出现的问题，也不失公平。
 
 
很多公司的面试 基本能答上来，同花顺的要求就是你不紧要答上来，而且要答的合符非常深入彻底，我也承认自己回答的很一般，很水。同花顺有这么一点好，至少让你知道你是当场挂的，哪一点不足，不像其他公司 回去等通知，一回去等通知，基本就没希望了。



#如何使用redis缓存加索引处理数据库百万级并发

1.我的优化方案中只有两种，一种是给查询的字段加组合索引。另一种是给在用户和数据库中增加缓存

2.添加索引方案：面对1~2千的并发是没有压力的，在往上则限制的瓶颈就是数据库最大连接数了，在上面中我用show global status like 'Max_used_connections’查看数据库可以知道数据库最大响应连接数是5700多，超过这个数tomcat直接报错连接被拒绝或者连接已经失效

3.缓存方案：在上面的测试可以知道，要是我们事先把数据库的千万条数据同步到redis缓存中，瓶颈就是我们的设备硬件性能了，假如我们的主机有几百个核心CPU，就算是千万级的并发下也可以完全无压力，带个用户很好的。

4.索引+缓存方案：缓存事先没有要查询的数据，在一万的并发下测试数据库毫无压力，程序先通过查缓存再查数据库大大减轻了数据库的压力，即使缓存不命中在一万的并发下也能正常访问,在10万并发下数据库依然没压力，但是redis服务器设置最大连接数300去处理10万的线程，4核CPU处理不过来，很多redis连接不了。我用show global status like 'Max_used_connections'查看数据库发现最大响应连接数是388，这么低所以数据库是不会挂掉的。

5.使用场景：a.几百或者2000以下并发直接加上组合索引就可以了。b.不想加索引又高并发的情况下可以先事先把数据放到缓存中，硬件设备支持下可解决百万级并发。c.加索引且缓存事先没有数据，在硬件设备支持下可解决百万级并发问题。d.不加索引且缓存事先没有数据，不可取，要80多秒才能得到结果，用户体验极差。

6.原理：其实使用了redis的话为什么数据库不会崩溃是因为redis最大连接数为300，这样数据库最大同时连接数也是300多，所以不会挂掉，至于redis为什么设置为300是因为设置的太高就会报错(连接被拒绝)或者等待超时(就算设置等待超时的时间很长也会报这个错)。'

scoket、ip统计与排序
数据库缓存、优化、主备关系与实现
keystone功能与实现、Keystone的cache机制、证书管理机制、负责身份验证、服务规则和服务令牌的功能，

keystone主要提供四种服务：身份（identity），标识（token），目录（catalog），权限（policy）服务。


Keystone提供两个模块给其他组件：
auth_token模块，认证token的有效性，即判断这个用户是有效的什么角色，用户是这个角色以后能不能执行操作有policy来进行。验证流程中注意到的是，先在缓存中匹配，同时缓存也要维护失效列表。
policy模块，进行访问控制检测，需要三种信息：
    --policy.json 策略配置信息文件，写了访问规则，什么操作 允许什么角色或者符合什么要求的用户执行 
     格式：<api name>:<rule statement>or<match statement>
   --auth_token添加到http头的token
   --用户的请求数据

   Keystone对象模型
	Domain
		V3加入，project，user，group的持有者--命名空间
	Project
		租户，v2里叫tenant，是资源（虚拟机，镜像）的持有者
	user
		用户
	group
		用户组，方便用户管理
	role
		基于角色进行访问控制
	trust
		角色委托给其他人，一般不怎么用
	service
		一个服务，如计算服务，镜像服务，网络服务
	endpoint
		某个服务的访问地址
	region
		可以理解我一个数据中心
	assignment
		（actor，target，role）三元组组成一个assignment
	token
		取代用户名密码，增强型鉴权
	这样，由keystone获得的catalog信息就能知道其他所有服务的地址了
token
	UUID token
		优点
			配置简单好用
		缺点
			访问keystone次数过多
	PKI token
		优点
			客户端就能鉴权
				keystone需要返回CA信息
		缺点
			token的catalog信息过长
				可以通过配置忽略catalog去解决
			有有效期时延问题
				获取token是否有效需要获取revocation list
				获取频率高和UUID就差不多了，获取频率低就会有时延问题。需要平和两者
		python有模块，java需要自己实现
角色访问控制
	policy模块提供
	policy.json各服务自己定义--修改不需要重启，实时生效
	policy写法
apiname : <rule statement>or <match statement>
		"indentity:get_user":"role:admin or userid:%(user_id)s" --- 可用or,and,not
		rule statement：role:admin
		match statement： userid:%(user_id)s  --比对token中和uri中的uerid
<attribute from token>:<constant> or <attribute related to API call>





四种token
#UUID
UUID token 是长度固定为 32 Byte 的随机字符串，由 uuid.uuid4().hex 生成。
def _get_token_id(self, token_data):     
    return uuid.uuid4().hex 
但是因 UUID token 不携带其它信息，OpenStack API 收到该 token 后，既不能判断该 token 是否有效，更无法得知该 token 携带的用户信息，所以需经图一步骤 4 向 Keystone 校验 token，并获用户相关的信息。其样例如下：
UUID token 简单美观，不携带其它信息，因此 Keystone 必须实现 token 的存储和认证，随着集群的规模增大，Keystone 将成为性能瓶颈。

#PKI
在阐述 PKI（Public Key Infrastruction） token 前，让我们简单的回顾公开密钥加密(public-key cryptography)和数字签名。公开密钥加密，也称为非对称加密(asymmetric cryptography，加密密钥和解密密钥不相同)，在这种密码学方法中，需要一对密钥，分别为公钥(Public Key)和私钥(Private Key)，公钥是公开的，私钥是非公开的，需用户妥善保管。
如果把加密和解密的流程当做函数 C(x) 和 D(x)，P 和 S 分别代表公钥和私钥，对明文 A 和密文 B 而言，数学的角度上有以下公式：
B = C(A, S)
A = D(B, P)
其中加密函数 C(x), 解密函数 D(x) 以及公钥 P 均是公开的。采用公钥加密的密文只能用私钥解密，采用私钥加密的密文只能用公钥解密。非对称加密广泛运用在安全领域，诸如常见的 HTTPS，SSH 登录等。

数字签名又称为公钥数字签名，首先采用 Hash 函数对消息生成摘要，摘要经私钥加密后称为数字签名。接收方用公钥解密该数字签名，并与接收消息生成的摘要做对比，如果二者一致，便可以确认该消息的完整性和真实性。

PKI 的本质就是基于数字签名，Keystone 用私钥对 token 进行数字签名，各个 API server 用公钥在本地验证该 token。相关代码简化如下：

def _get_token_id(self, token_data):     
    try:         
        token_json = jsonutils.dumps(token_data, cls=utils.PKIEncoder)         
        token_id = str(cms.cms_sign_token(token_json, CONF.signing.certfile, CONF.signing.keyfile))         
        return token_id 

其中 cms.cms_sign_token 调用 openssl cms –sign 对 token_data 进行签名，token_data 的样式如下：

{"token":{"methods":["password"],"roles":[{"id":"5642056d336b4c2a894882425ce22a86","name":"admin"}],"expires_at":"2015-12-25T09:57:28.404275Z","project":{"domain":{"id":"default","name":"Default"},"id":"144d8a99a42447379ac37f78bf0ef608","name":"admin"},"catalog":[{"endpoints":[{"region_id":"RegionOne","url":"http://controller:5000/v2.0","region":"RegionOne","interface":"public","id":"3837de623efd4af799e050d4d8d1f307"},......]}],"extras":{},"user":{"domain":{"id":"default","name":"Default"},"id":"1552d60a042e4a2caa07ea7ae6aa2f09","name":"admin"},"audit_ids":["ZCvZW2TtTgiaAsVA8qmc3A"],"issued_at":"2015-12-25T08:57:28.404304Z"}}
token_data 经 cms.cms_sign_token 签名生成的 token_id 如下，共 1932 Byte：

#PKIZ
PKIZ 在 PKI 的基础上做了压缩处理，但是压缩的效果极其有限，一般情况下，压缩后的大小为 PKI token 的 90 % 左右，所以 PKIZ 不能友好的解决 token size 太大问题。
def _get_token_id(self, token_data):     
    try:         
        token_json = jsonutils.dumps(token_data, cls=utils.PKIEncoder)         
        token_id = str(cms.pkiz_sign(token_json, CONF.signing.certfile, CONF.signing.keyfile))
    return token_id 
其中 cms.pkiz_sign() 中的以下代码调用 zlib 对签名后的消息进行压缩级别为 6 的压缩。
compressed = zlib.compress(token_id, compression_level=6) 
PKIZ token 样例如下，共 1645 Byte，比 PKI token 减小 14.86 %：


用户可能会碰上这么一个问题，当集群运行较长一段时间后，访问其 API 会变得奇慢无比，究其原因在于 Keystone 数据库存储了大量的 token 导致性能太差，解决的办法是经常清理 token。为了避免上述问题，社区提出了Fernet token，它采用 cryptography 对称加密库(symmetric cryptography，加密密钥和解密密钥相同) 加密 token，具体由 AES-CBC 加密和散列函数 SHA256 签名。Fernet 是专为 API token 设计的一种轻量级安全消息格式，不需要存储于数据库，减少了磁盘的 IO，带来了一定的性能提升。为了提高安全性，需要采用 Key Rotation 更换密钥。

如何选择 Token
Token 类型	UUID	PKI	PKIZ	Fernet
大小	32 Byte	KB 级别	KB 级别	约 255 Byte
支持本地认证	不支持	支持	支持	不支持
Keystone 负载	大	小	小	大
存储于数据库	是	是	是	否
携带信息	无	user, catalog 等	user, catalog 等	user 等
涉及加密方式	无	非对称加密	非对称加密	对称加密(AES)
是否压缩	否	否	是	否
版本支持	D	G	J	K




SQL注入式
使用参数化的过滤性语句
使用预编译的方式
写SQL最好是用参数化传变量，不要拼接SQL字符串会导致SQL注入的风险
因为参数化查询可以重用执行计划，并且如果重用执行计划的话，SQL所要表达的语义就不会变化，所以就可以防止SQL注入,如果不能重用执行计划，就有可能出现SQL注入，
存储过程也是一样的道理，因为可以重用执行计划。
查找密码是(____) 并且用户名是(____)的用户。
不管你填的是什么值，我所表达的就是这个意思。


collections 模块在熟悉一下，常用数据结构，树

6.什么是事务？什么是锁？

答：事务就是被绑定在一起作为一个逻辑工作单元的SQL语句分组，如果任何一个语句操作失败那么整个操作就被失败，以后操作就会回滚到操作前状态，或者是上有个节点。为了确保要么执行，要么不执行，就可以使用事务。要将有组语句作为事务考虑，就需要通过ACID测试，即原子性，一致性，隔离性和持久性。
事务是作为一个逻辑单元执行的一系列操作，一个逻辑工作单元必须有四个属性，称为 ACID（原子性、一致性、隔离性和持久性）属性，


锁：在所以的DBMS中，锁是实现事务的关键，锁可以保证事务的完整性和并发性。与现实生活中锁一样，它可以使某些数据的拥有者，在某段时间内不能使用某些数据或数据结构。当然锁还分级别的。


8.你能向我简要叙述一下SQL Server 中使用的一些数据库对象吗?

答:表、索引、视图、存储过程、触发器、用户定义函数、数据库关系图、全文索引。


11.什么是主键?什么是外键?

主键是表格里的(一个或多个)字段，只用来定义表格里的行;主键里的值总是唯一的。外键是一个用来建立两个表格之间关系的约束。这种关系一般都涉及一个表格里的主键字段与另外一个表格(尽管可能是同一个表格)里的一系列相连的字段。那么这些相连的字段就是外键。

1.sql语句应该考虑哪些安全性？
    1.防止sql注入，对特殊字符进行转义，过滤或者使用预编译的sql语句绑定变量。
    2.最小权限原则，特别是不要用root账户，为不同的类型的动作或者组建使用不同的账户。
    3.当sql运行出错时，不要把数据库返回的错误信息全部显示给用户，以防止泄漏服务器和数据库相关信息

2.简单描述mysql中，索引，主键，唯一索引，联合索引的区别，对数据库的性能有什么影响。

    索引是一种特殊的文件（InnoDB数据表上的索引是表空间的一个组成部分），它们包含着对数据表里所有记录的引用指针。
    普通索引（由关键字KEY或INDEX定义的索引）的唯一任务是加快对数据的访问速度。
    普通索引允许被索引的数据列包含重复的值，如果能确定某个数据列只包含彼此各不相同的值，在为这个数据索引创建索引的时候就应该用关键字UNIQE把它定义为一个唯一所以，唯一索引可以保证数据记录的唯一性。
    
    主键，一种特殊的唯一索引，在一张表中只能定义一个主键索引，逐渐用于唯一标识一条记录，是用关键字PRIMARY KEY来创建。
    索引可以覆盖多个数据列，如像INDEX索引，这就是联合索引。
    索引可以极大的提高数据的查询速度，但是会降低插入删除更新表的速度，因为在执行这些写操作时，还要操作索引文件。
    
    
3.一张表,里面有ID自增主键,当insert了17条记录之后,删除了第15,16,17条记录,再把Mysql重启,再insert一条记录,这条记录的ID是18还是15 ？

    如果表的类型是MyISAM，那么是18。 
    因为MyISAM表会把自增主键的最大ID记录到数据文件里，重启MySQL自增主键的最大ID也不会丢失。 
    如果表的类型是InnoDB，那么是15。 
    InnoDB表只是把自增主键的最大ID记录到内存中，所以重启数据库或者是对表进行OPTIMIZE操作，都会导致最大ID丢失。

    
4.请简述项目中优化sql语句执行效率的方法，从哪些方面。sql语句性能如何分析？
    1.尽量选择较小的列
    2.将where中用的比较频繁的字段建立索引
    3.select子句中避免使用‘*’
    4.避免在索引列上使用计算，not，in和<>等操作
    5.当只需要一行数据的时候使用limit 1
    6.保证表单数据不超过200w，适时分割表
    　　针对查询较慢的语句，可以使用explain来分析该语句具体的执行情况   

}

SQL常用命令：
CREATE TABLE Student( 
ID NUMBER PRIMARY KEY, 
NAME VARCHAR2(50) NOT NULL);//建表 

CREATE VIEW view_name AS 
Select * FROM Table_name;//建视图 
Create UNIQUE INDEX index_name ON TableName(col_name);//建索引 
INSERT INTO tablename {column1,column2,…} values(exp1,exp2,…);//插入 
INSERT INTO Viewname {column1,column2,…} values(exp1,exp2,…);//插入视图实际影响表 
UPDATE tablename SET name=’zang 3’ condition;//更新数据 
DELETE FROM Tablename WHERE condition;//删除 
GRANT (Select,delete,…) ON (对象) TO USER_NAME [WITH GRANT OPTION];//授权 
REVOKE (权限表) ON(对象) FROM USER_NAME [WITH REVOKE OPTION] //撤权 
列出工作人员及其领导的名字： 
Select E.NAME, S.NAME FROM EMPLOYEE E S 
WHERE E.SUPERName=S.Name

show create table Student; #查看建表语句
desc Student; #查看表结构

内联接,外联接区别？ 
内连接是保证两个表中所有的行都要满足连接条件，而外连接则不然。 
在外连接中，某些不满条件的列也会显示出来，也就是说，只限制其中一个表的行，而不限制另一个表的行。分左连接、右连接、全连接三种


http://www.cnblogs.com/wangqiaomei/p/5682669.html
https://www.cnblogs.com/huchong/p/8491107.html

# http://www.cnblogs.com/iathena/p/dc31039501c74404ee674624ab38351d.html
守护进程英文为daemon，像httpd、mysqld、vsftpd最后个字母d其实就是表示daemon的意思。
守护进程的编写步骤：
fork子进程，而后父进程退出，此时子进程会被init进程接管。
修改子进程的工作目录、创建新进程组和新会话、修改umask。
子进程再次fork一个进程，这个进程可以称为孙子进程，而后子进程退出。
重定向孙子进程的标准输入流、标准输出流、标准错误流到/dev/null。
完成上面的4个步骤，那么最终的孙子进程就称为守护进程。



signal
{
import os
import signal
import time

def signal_usr1(signum, frame):
    "Callback invoked when a signal is received"
    pid = os.getpid()
    print ('Received USR1 in process %s' % pid)

print ('Forking...')
child_pid = os.fork()
if child_pid:
    print ('PARENT: Pausing before sending signal...')
    time.sleep(10)
    print ('PARENT: Signaling %s' % child_pid)
    os.kill(child_pid, signal.SIGUSR1)
else:
    print ('CHILD: Setting up a signal handler')
    signal.signal(signal.SIGUSR1, signal_usr1)
    print ('CHILD: Pausing to wait for signal')
    time.sleep(20)


import signal
import time

def received_alarm(signum, stack):
    print ('Alarm:', time.ctime())

# Call receive_alarm in seconds
signal.signal(signal.SIGALRM, received_alarm)
signal.alarm(2)

print ('Before:', time.ctime())
time.sleep(4)
print ('After:', time.ctime())

"""
[root@allinone-centos lgj]# python bb.py
Before: Mon Mar  5 14:44:17 2018
Alarm: Mon Mar  5 14:44:19 2018
After: Mon Mar  5 14:44:19 2018
"""
import time
import traceback
import signal

# Define signal handler function
def myHandler(signum, frame):
    print('I received: ', signum)

# register signal.SIGTSTP's handler
signal.signal(signal.SIGTSTP, myHandler)
signal.pause()
print('End of Signal Demo')

}


python笔记之psutil模块{

1. psutil是一个跨平台库（http://code.google.com/p/psutil/），能够轻松实现获取系统运行的进程和系统利用率（包括CPU、内存、磁盘、网络等）信息。它主要应用于系统监控，分析和限制系统资源及进程的管理。它实现了同等命令行工具提供的功能，如ps、top、lsof、netstat、ifconfig、who、df、kill、free、nice、ionice、iostat、iotop、uptime、pidof、tty、taskset、pmap等。目前支持32位和64位的Linux、Windows、OS X、FreeBSD和Sun Solaris等操作系统.

2.安装
wget https://pypi.python.org/packages/source/p/psutil/psutil-2.0.0.tar.gz
tar -xzvf psutil-2.0.0.tar.gz
cd psutil-2.0.0
python setup.py install

3.使用
{
获取系统性能信息（CPU,内存，磁盘，网络）

3.1CPU相关
查看cpu信息

import psutil
查看cpu所有信息
>>> psutil.cpu_times()
scputimes(user=11677.09, nice=57.93, system=148675.58, idle=2167147.79, iowait=260828.48, irq=7876.28, softirq=0.0, steal=3694.59, guest=0.0, guest_nice=0.0)
显示cpu所有逻辑信息

>>> psutil.cpu_times(percpu=True)
[scputimes(user=11684.17, nice=57.93, system=148683.01, idle=2168982.08, iowait=260833.18, irq=7882.35, softirq=0.0, steal=3697.3, guest=0.0, guest_nice=0.0)]
查看用户的cpu时间比

>>> psutil.cpu_times().user
11684.4
查看cpu逻辑个数

>>> psutil.cpu_count()
1
查看cpu物理个数

>>> psutil.cpu_count(logical=False)
1
3.2查看系统内存

>>> import psutil
>>> mem = psutil.virtual_memory()
>>> mem
#系统内存的所有信息
svmem(total=1040662528, available=175054848, percent=83.2, used=965718016, free=74944512, active=566755328, inactive=59457536, buffers=9342976, cached=90767360)
系统总计内存

>>> mem.total
1040662528
系统已经使用内存

>>> mem.used
965718016
系统空闲内存

>>> mem.free
112779264
获取swap内存信息

>>> psutil.swap_memory()
sswap(total=0, used=0, free=0, percent=0, sin=0, sout=0)
读取磁盘参数

磁盘利用率使用psutil.disk_usage方法获取，

磁盘IO信息包括read_count(读IO数)，write_count(写IO数)
read_bytes(IO写字节数)，read_time(磁盘读时间)，write_time(磁盘写时间),这些IO信息用

psutil.disk_io_counters()
获取磁盘的完整信息

psutil.disk_partitions()
获取分区表的参数

psutil.disk_usage('/')   #获取/分区的状态
获取硬盘IO总个数

psutil.disk_io_counters()
获取单个分区IO个数

psutil.disk_io_counters(perdisk=True)    #perdisk=True参数获取单个分区IO个数
读取网络信息

网络信息与磁盘IO信息类似,涉及到几个关键点，包括byes_sent(发送字节数),byte_recv=xxx(接受字节数),
pack-ets_sent=xxx(发送字节数),pack-ets_recv=xxx(接收数据包数),这些网络信息用

获取网络总IO信息

psutil.net_io_counters()  
输出网络每个接口信息

psutil.net_io_counters(pernic=True)     #pernic=True
获取当前系统用户登录信息

psutil.users()
获取开机时间

psutil.boot_time() #以linux时间格式返回

datetime.datetime.fromtimestamp(psutil.boot_time ()).strftime("%Y-%m-%d %H: %M: %S") #转换成自然时间格式

系统进程管理
获取当前系统的进程信息,获取当前程序的运行状态,包括进程的启动时间,查看设置CPU亲和度,内存使用率,IO信息
socket连接,线程数等
获取进程信息

查看系统全部进程

psutil.pids()
查看单个进程

p = psutil.process(2423) 
p.name()   #进程名
p.exe()    #进程的bin路径
p.cwd()    #进程的工作目录绝对路径
p.status()   #进程状态
p.create_time()  #进程创建时间
p.uids()    #进程uid信息
p.gids()    #进程的gid信息
p.cpu_times()   #进程的cpu时间信息,包括user,system两个cpu信息
p.cpu_affinity()  #get进程cpu亲和度,如果要设置cpu亲和度,将cpu号作为参考就好
p.memory_percent()  #进程内存利用率
p.memory_info()    #进程内存rss,vms信息
p.io_counters()    #进程的IO信息,包括读写IO数字及参数
p.connectios()   #返回进程列表
p.num_threads()  #进程开启的线程数
听过psutil的Popen方法启动应用程序，可以跟踪程序的相关信息
from subprocess import PIPE
p = psutil.Popen(["/usr/bin/python", "-c", "print('hello')"],stdout=PIPE)
p.name()
p.username()
}
}


数据库基础知识{

https://www.cnblogs.com/Java3y/p/8505242.html

#存储过程
http://www.cnblogs.com/lxs1314/p/5945428.html

笛卡尔积简单来说就是两个集合相乘的结果。
可以使用等值连接(emp.deptno=dept.deptno)来消除笛卡尔积

MySQL创建存储过程 
“pr_add” 是个简单的 MySQL 存储过程，这个存储过程有两个 int 类型的输入参数 “a”、“b”，返回这两个参数的和。


mysql> 
drop procedure if exists pr_add;
create procedure pr_add
(
   a int,
   b int
)
begin
   declare c int;
   if a is null then
      set a = 0;
   end if;
   if b is null then
      set b = 0;
   end if;
   set c = a + b;
   select c as sum;
end;
Query OK, 0 rows affected

mysql> call pr_add(10,20);
+-----+
| sum |
+-----+
|  30 |
+-----+
1 row in set

Query OK, 0 rows affected

mysql> 

mysql> set @a=100;
Query OK, 0 rows affected

mysql> set @b=200;
Query OK, 0 rows affected

mysql> call pr_add(@a,@b);
+-----+
| sum |
+-----+
| 300 |
+-----+
1 row in set

Query OK, 0 rows affected

mysql> 

show procedure status 显示数据库所有存储过程基本信息。
show create procedure zyd_name 显示一个存储过程详细信息。





http://blog.csdn.net/v_JULY_v/article/details/6530142/
#B树、B+树、B*树
动态查找树主要有：二叉查找树（Binary Search Tree），平衡二叉查找树（Balanced Binary Search Tree），红黑树(Red-Black Tree )，B-tree/B+-tree/ B*-tree (B~Tree)。前三者是典型的二叉查找树结构，其查找的时间复杂度O(log2N)与树的深度相关，那么降低树的深度自然会提高查找效率。

二叉查找树结构由于树的深度过大而造成磁盘I/O读写过于频繁，进而导致查询效率低下
B树的各种操作能使B树保持较低的高度，从而达到有效避免磁盘过于频繁的查找存取操作，从而有效提高查找效率
B-tree（B-tree树即B树，B即Balanced，平衡的意思）

B 树是为了磁盘或其它存储设备而设计的一种多叉（相对于二叉，B树每个内结点有多个分支，即多叉）平衡查找树。





}


#使用 .vimrc 文件，创建新文件时能够快速的生成开头的注释信息
cat  ~/.vimrc 

autocmd BufNewFile *.py,*.cc,*.sh,*.java exec ":call SetTitle()"
func SetTitle()
    if expand("%:e") == 'sh'
        call setline(1,"#!/bin/bash")
        call setline(2, "##############################################################")
        call setline(3, "# File Name: ".expand("%"))
        call setline(4, "# Version: V1.0")
        call setline(5, "# Author: clsn")
        call setline(6, "# Organization: http://www.cnblogs.com/clsn/p/7992981.html")
        call setline(7, "# Created Time : ".strftime("%F %T"))
        call setline(8, "# Description:")
        call setline(9, "##############################################################")
        call setline(10, "")
    endif
endfunc

# http://www.cnblogs.com/wfwenchao/p/6139039.html  Linux set、env、declare、export显示shell变量的区别
env/declare/set/export -p 命令查看系统中的环境变量

env 这是一个工具，或者说一个Linux命令，显示用户的环境变量。
set 显示用户的局部变量和用户环境变量。
export 显示导出成用户变量的shell局部变量，并显示变量的属性；就是显示由局部变量导出成环境变量的那些变量 （比如可以 export WWC导出一个环境变量，也可通过 declare -X LCY导出一个环境变量）
declare 跟set一样，显示用户的shell变量 （局部变量和环境变量）

local 一般用于局部变量声明，多在在函数内部使用。
export:将自定义变量设定为系统环境变量（仅限于该次登陆操作，当前shell中有效）



使用${} 打印变量的时候防止出现歧义的问题
[root@clsn scripts]# time=`date`
[root@clsn scripts]# echo $time_day

[root@clsn scripts]# echo ${time}_day
2017年 12月 05日 星期二 09:02:06 CST_day
[root@clsn scripts]# echo $time-day
2017年 12月 05日 星期二 09:02:06 CST-day


# 字符串比较是放置在[...]中，有以下的几种：
str1 = str2，字符串1匹配字符串2
str1 != str2，字符串1不匹配字符串2
str1 > str2，字符串1大于字符串2
str1 < str2，字符串1小于字符串2
-n str，字符串不为null，长度大于零
-z str，字符串为null，长度为零

# >或者<或者=是用于字符串的比较，如果用于整数比较，使用：
-lt，小于
-le，小于等于
-eq，等于
-ge，大于等于
-gt，大于
-ne，不等于

#整数比较的三种方式
[root@allinone-centos .pip]# if [[ 11 < 111 ]]; then echo "a"; else echo 'b'; fi
a
[root@allinone-centos .pip]# if [[ 11 > 111 ]]; then echo "a"; else echo 'b'; fi
b
[root@allinone-centos .pip]# if (( 11 < 111 )); then echo "a"; else echo 'b'; fi
a
[root@allinone-centos .pip]# if (( 11 > 111 )); then echo "a"; else echo 'b'; fi
b
[root@allinone-centos .pip]# if [ 11 -lt 111 ]; then echo "a"; else echo 'b'; fi
a
[root@allinone-centos .pip]# if [ 11 -gt 111 ]; then echo "a"; else echo 'b'; fi
b

# 在[]结构中"<"需要被转义
[root@allinone-centos .pip]# if [ 1 \> 2 ]; then echo "a"; else echo 'b'; fi
b
[root@allinone-centos .pip]# if [ 1 \< 2 ]; then echo "a"; else echo 'b'; fi
a


#整数加上引号也是可以比较数值大小的
[root@allinone-centos .pip]# if [ '11' -gt '111' ]; then echo "a"; else echo 'b'; fi
b
[root@allinone-centos .pip]# if [ '11' -lt '111' ]; then echo "a"; else echo 'b'; fi
a
[root@allinone-centos .pip]# if [ '11' -lt '11' ]; then echo "a"; else echo 'b'; fi
b
[root@allinone-centos .pip]# if [ '11' -lt '1' ]; then echo "a"; else echo 'b'; fi
b
[root@allinone-centos .pip]# if [ '11' -lt '111' ]; then echo "a"; else echo 'b'; fi
a
[root@allinone-centos .pip]# if [ '11' -lt '22' ]; then echo "a"; else echo 'b'; fi
a
[root@allinone-centos .pip]# if [ '11' -lt '10' ]; then echo "a"; else echo 'b'; fi
b

[root@allinone-centos .pip]# if [[ '11' > '10' ]]; then echo "a"; else echo 'b'; fi
a
[root@allinone-centos .pip]# if [[ '11' < '10' ]]; then echo "a"; else echo 'b'; fi
b

# == 等于,如:if [ "$a" == "$b" ],与=等价，但在[[]]和[]中的行为是不同的,如下:
[[ $a == z* ]]   # 如果$a以"z"开头(模式匹配)那么将为true   
[[ $a == "z*" ]] # 如果$a等于z*(字符匹配),那么结果为true   
[ $a == z* ]     # File globbing 和word splitting将会发生   
[ "$a" == "z*" ] # 如果$a等于z*(字符匹配),那么结果为true   


[root@allinone-centos .pip]# if [ 'aa' = b* ]; then echo "a"; else echo 'b'; fi
b
[root@allinone-centos .pip]# if [ 'aa' == b* ]; then echo "a"; else echo 'b'; fi
b
[root@allinone-centos .pip]# if [[ 'aa' == a* ]]; then echo "a"; else echo 'b'; fi
a
[root@allinone-centos .pip]# if [ 'aa' == a* ]; then echo "a"; else echo 'b'; fi
b
[root@allinone-centos .pip]# if [ 'aa' = a* ]; then echo "a"; else echo 'b'; fi
b



#linux中产生随机数的方法
echo $RANDOM 

#彩色字体
echo -e "\033[30m 黑色字 clsn \033[0m"
echo -e "\033[31m 红色字 clsn \033[0m"
echo -e "\033[32m 绿色字 clsn \033[0m"
echo -e "\033[33m 黄色字 clsn \033[0m"
echo -e "\033[34m 蓝色字 clsn \033[0m"
echo -e "\033[35m 紫色字 clsn \033[0m"
echo -e "\033[36m 天蓝字 clsn \033[0m"
echo -e "\033[37m 白色字 clsn \033[0m"
# 特效字体
\033[0m 关闭所有属性
\033[1m 设置高亮度
\033[4m 下划线
\033[5m 闪烁
\033[7m 反显
\033[8m 消隐
\033[30m — \033[37m 设置前景色
\033[40m — \033[47m 设置背景色
\033[nA 光标上移 n 行
\033[nB 光标下移 n 行
\033[nC 光标右移 n 行
\033[nD 光标左移 n 行
\033[y;xH 设置光标位置
\033[2J 清屏
\033[K 清除从光标到行尾的内容
\033[s 保存光标位置
\033[u 恢复光标位置
\033[?25l 隐藏光标
\033[?25h 显示光标

#使用dos2unix 把windows上的脚本转化linux格式
dos2unix windowe.sh 


# for的几种方式

for x in a b c d e f g; do echo $x; done
for ((i=0;i<=5;i++)); do echo $i; done
for x in {1..10}; do echo $x; done


# 批量创建用户并设置随机密码（不使用shell循环）
方法一
echo user{1..20}|xargs -n1|sed -r 's#(.*)#useradd \1 \&\& echo \1 >>/tmp/passwd.txt \&\& echo $RANDOM |md5sum |cut -c 1-5>>/tmp/passwd.txt \&\& echo `tail -1 /tmp/passwd.txt`|passwd --stdin \1#g'|bash
方法二
echo user{1..20}|xargs -n1|sed -r 's#(.*)#useradd \1 \&\& pass=`echo $RANDOM |md5sum |cut -c 1-5` \&\& echo $pass |passwd --stdin \1 \&\& echo \1 $pass>>/tmp/user_passwd.txt#g'|bash
方法三
echo user{1..20}|xargs -n1|sed -r 's#(.*)#useradd \1 \&\& pass=`echo $RANDOM |md5sum |cut -c 1-5` \&\& echo \1:$pass>>/tmp/user_passwd.txt \&\& chpasswd</tmp/user_passwd.txt#g'|bash


# 使用expr 计算字符串长度
expr length '111'

# 计算1-100的和
echo `seq -s + 1 100`|bc


# 网络基础知识-网络协议
http://www.cnblogs.com/wj-1314/p/8298025.html




“线程池”旨在减少创建和销毁线程的频率，其维持一定合理数量的线程，并让空闲的线程重新承担新的执行任务。“连接池”维持连接的缓存池，尽量重用已有的连接、减少创建和关闭连接的频率。
“线程池”和“连接池”技术也只是在一定程度上缓解了频繁调用IO接口带来的资源占用
# 几个不错的博客
http://www.cnblogs.com/wj-1314/p/8309118.html
http://www.cnblogs.com/wj-1314/p/8490822.html
http://www.cnblogs.com/wj-1314/p/8263328.html







