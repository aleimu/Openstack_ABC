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
http://www.cnblogs.com/cj723/archive/2011/03/05/1971640.html
http://www.cnblogs.com/gaochundong/p/complexity_of_algorithms.html
http://www.cnblogs.com/songQQ/archive/2009/10/20/1587122.html

}

不停的堆砌已有的API........

#python面试题
{

}
