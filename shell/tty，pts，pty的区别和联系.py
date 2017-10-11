http://blog.csdn.net/leshami/article/details/77101939  #精华博客，内附图解
http://www.cnblogs.com/wi100sh/p/4513245.html
http://www.cnblogs.com/growup/archive/2011/07/12/2104623.html
http://blog.chinaunix.net/uid-28596231-id-3516101.html

tty 是各终端的简称，设备包括虚拟控制台，串口以及伪终端设备。 

#/dev/tty /dev/ttySn /dev/ttyn /dev/pts/n 区别与联系

#在使用Linux的过程中，当我们通过ssh或者telnet等方式连接到服务器之后，会有一个相应的终端来对应。而在直接登陆到Linux服务器的时候也有一个对应的终端。也就是说所有登陆到当前Linux服务器的用户都有一个对应的终端，那他们有什么差异，终端到底是怎么一回事？本文作简要描述如下。

区别与联系{
一、什么是终端(Terminal)

百度百科：终端 Terminal通常是指那些与集中式主机系统相连的“哑”用户设备。
从历史角度看，终端刚开始就是终端机，配有打印机，键盘，带有一个串口，通过串口传送数据到主机端，然后主机处理完交给终端打印出来。
那么现在终端也就是键盘+显示器。但是不同的设备可能协议不同，要操作系统怎么识别呢？简单。就像linux 的虚拟文件系统一样，抽象出一层就可以了。
#tty层横空出世，tty的一边是操作系统，一边是不同的设备驱动。
大家知道，在linux下所有的设备都是文件，那么假设我们要打印到显示器，只要write到显示器对应的tty层的文件，然后它自己去匹配合适的驱动，这部分就不是系统考虑的问题了。
现在的终端还是实体（也就是有实际的硬件），只不过由tty层做了逻辑抽象。
但是随着互联网的兴起，人们有了远程使用计算机的要求，于是终端仿真系统诞生了。把本地PC当成是一个终端，远程的计算机当成是主机。由软件模拟硬件终端的工作过程（无非就是编码格式，电位等等，设计组成原理等）。比如现在嵌入式开发，不就是把个人PC当作输出输出工具，由开发板做主机么？
现在的个人计算机常常被仿真成一个终端与主机相连（虽然没让我发现有什么优点，也许是为了本地用户和远程用户的同等地位？）
人们用终端仿真技术开发了各种的虚拟终端，伪终端等等。相当于PC不在逻辑上处理数据，只是按照行业标准，进行数据传输（应该有编码过程？）和接受显示（解码？）
此时此刻，终端已经不是狭义的硬件了，它更多的被理解为模拟硬件的软件。
所以一台计算机上有很多种不同的终端设备。终端就是为主机提供了人机接口，每个人都通过终端使用主机的资源。终端有字符终端和图形终端两种。同时这些大型计算机还配有控制台。控制台是一种特殊的人机接口, 是人控制主机的第一人机接口。而主机对于控制台的信任度高于其他终端。控制台可以类比为我们操作系统的超级管理员，可以禁用某个用户的权限，禁用用户登陆等等。而普通终端就相当于一个普通用户。

二、终端的模式

1、界面终端 X window

X window环境，即图形界面终端模式，类似于Windows的图形画界面，也就是通过鼠标的点点来完成所有的管理任务。这个通常是在测试环境或者学习环境中被用到。真实的生产环境，一般来说都是使用的非图形界面，因为对与繁忙的生产环境来说，这个图形界面是需要资源开销的，因此省省吧，也就是系统通常运行等级在level 3。对于X window，这个都是鼠标点击，没啥太多可说的。

有图形界面也就有文本界面终端，那对于在命令行窗口想要切换到X window的情形，肿么办呢？可以使用startx 来启动图行界面。 
前提如下： 
    已经安装了X Window system，并且X server是能够顺利启动的； 
    tty7并没有其他的窗口软件正在运行(tty后面会讲到)； 
    启动X所必须要的服务，例如字型服务器(X Font Server, xfs)必须要先启动； 
    系统已安装了GNOME/KDE等桌面环境；

2、文本接口终端

这是Linux服务器常用的模式。如果配置了Linux系统运行等级为3的时候，Linux启动后就直接为文本模式，在这种情况下，当我们登陆到Linux服务器，即表明开启了一个终端模式会话。Linux默认的情况下会提供六个Terminal来让使用者登陆， 切换的方式为使用：[Ctrl] + [Alt] + [F1]~[F6]的组合按钮。那这六个终端接口如何命名呢，系统会将[F1] ~ [F6]命名为tty1 ~ tty6的操作接口环境。 也就是说，当你按下[crtl] + [Alt] + [F1]这三个组合按钮时 (按着[ctrl]与[Alt]不放，再按下[F1]功能键)， 就会进入到tty1的terminal界面中了。同样的[F2]就是tty2啰！那么如何回到刚刚的X窗口接口呢？很简单啊！按下[Ctrl] + [Alt] + [F1]就可以了！ 
总结如下： 
    linux的终端机（文字）界面与图形界面间的切换热键为： 
    进入终端机也就是字符界面（tty1-tty6）：[Ctrl] + [Alt] + [F1] - [F6] 
    进入图形界面（tty7）：[Ctrl] + [Alt] + [F7]

3、tty(终端设备的统称)

tty一词源于Teletypes，或teletypewriters，原来指的是电传打字机，是通过串行线用打印机键盘通过阅读和发送信息的东西，后来这东西被键盘和显示器取代，所以现在叫终端比较合适。终端是一种字符型设备，他有多种类型，通常使用tty来简称各种类型的终端设备。
可以使用命令 ps -ef 来查看进程与哪个控制终端相连。对于你登录的shell，/dev/tty就是你使用的终端。使用命令 tty 可以查看它具体对应哪个实际终端设备。/dev/tty有些类似于到实际所使用终端设备的一个联接。
	tty：
		如果一个进程有控制终端的话，/dev/tty 就是它的控制终端，这个东西不是固定的，不同的程序打开这个设备文件可能指向的终端不同。
		#echo "test" > /dev/tty
		test
	tty0：
		tty1 –tty6等称为虚拟终端，而tty0则是当前所使用虚拟终端的一个别名，系统所产生的信息会发送到该终端上。因此不管当前正在使用哪个虚拟终端，系统信息都会发送到控制台终端上。
		#echo "test" > /dev/tty0
		test
		(注意：好像要在文本模式下才可以)

/dev/tty主要是针对进程来说的，而/dev/tty0是针对整个系统来说的就是说同是/dev/tty文件，对不同的进程来说，其具体指向是不同的。但不管对那个进程来说/dev/tty0指向的都是当前的虚拟终端.

4、pty（虚拟终端):

我们在使用远程telnet到主机或使用xterm时也会产生一个终端交互，这就是虚拟终端pty(pseudo-tty) 
例如，我们在X Window下打开的终端，以及我们在Windows使用telnet 或ssh等方式登录远程Linux主机，此时均在使用pty设备(准确的说应该是pty从设备，我们Windows本机为主设备)。


5、pts/ptmx(pts/ptmx结合使用，进而实现pty):

伪终端(Pseudo Terminal)是终端的发展，为满足现在需求（比如网络登陆、xwindow窗口的管理）。它是成对出现的逻辑终端设备(即master和slave设备, 对master的操作会反映到slave上。也就是说pts(pseudo-terminal slave)是pty的实现方法，和ptmx(pseudo-terminal master)配合使用实现pty。
/dev/pts/ 目录是远程登陆(telnet,ssh等)后创建的控制台设备文件所在的目录。由于可能有好几千个用户登陆，所以/dev/pts其实是动态生成的，不象其他设备文件是构建系统时就已经产生的硬盘节点.


6、串行端口终端(/dev/ttySn) 
串行端口终端(Serial Port Terminal)是使用计算机串行端口连接的终端设备。计算机把每个串行端口都看作是一个字符设备。有段时间这些串行端口设备通常被称为终端设备，因为 那时它的最大用途就是用来连接终端。这些串行端口所对应的设备名称是/dev/tts/0(或/dev/ttyS0), /dev/tts/1(或/dev/ttyS1)等，设备号分别是(4,0), (4,1)等，分别对应于DOS系统下的COM1、COM2等。若要向一个端口发送数据，可以在命令行上把标准输出重定向到这些特殊文件名上即可。
例如， 在命令行提示符下键入：echo test > /dev/ttyS1会把单词”test”发送到连接在ttyS1(COM2)端口的设备上。

7、控制台终端 (/dev/console)
在Linux 系统中，计算机显示器通常被称为控制台终端 (Console)。它仿真了类型为Linux的一种终端(TERM=Linux)，并且有一些设备特殊文件与之相关联：tty0、tty1、tty2 等。tty1–tty6等称为虚拟终端，而tty0则是当前所使用虚拟终端的一个别名，系统所产生的信息会发送到该终端上（这时也叫控制台终端）。
因此不管当前正在使用哪个虚拟终端，系统信息都会发送到控制台终端上。只有系统或超级用户root可以向/dev/tty0进行写操作.
/dev/console即控制台，是与操作系统交互的设备，系统将一些信息直接输出到控制台上。目前只有在单用户模式下，才允许用户登录控制台。 


只要在终端中执行命令就无法离开shell命令。什么是shell呢？
系统启动时候先启动init，作为一个进程管理器，每个用户登陆的时候，给他一个启动一个虚拟终端程序。
做一个不恰当的类比，可以理解为：输入命令，用终端程序传送给tty层，发送给shell解释程序，shell程序解释执行命令，然后shell把内容返回tty层，返回给终端程序。
}

演示{
root@ubuntu10:~# cat  /etc/os-release 
NAME="Ubuntu"
VERSION="14.04.5 LTS, Trusty Tahr"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 14.04.5 LTS"
VERSION_ID="14.04"
HOME_URL="http://www.ubuntu.com/"
SUPPORT_URL="http://help.ubuntu.com/"
BUG_REPORT_URL="http://bugs.launchpad.net/ubuntu/"

root@ubuntu10:~# ps -ef|grep ssh
root      1174     1  0 Oct09 ?        00:00:00 /usr/sbin/sshd -D
root      1524  1174  0 Oct09 ?        00:00:00 sshd: root@pts/0,pts/2,pts/3,pts/4
root      3921  1174  0 14:48 ?        00:00:00 sshd: root@notty    
root      4030  3921  0 14:48 ?        00:00:00 /usr/lib/openssh/sftp-server
root      4044  3921  0 14:50 ?        00:00:00 /usr/lib/openssh/sftp-server
root      4416  4400  0 16:09 pts/4    00:00:00 grep ssh #本终端使用的 pts/4
root@ubuntu10:~# echo "test" > /dev/pts/0   ----->这些都会发送到开得其他窗口上
root@ubuntu10:~# echo "test" > /dev/pts/1
root@ubuntu10:~# echo "test" > /dev/pts/2
root@ubuntu10:~# echo "test" > /dev/pts/3
root@ubuntu10:~# echo "test" > /dev/pts/4
test
root@ubuntu10:~# tty 
/dev/pts/4
root@ubuntu10:~# echo "test" > /dev/tty  
test

###演示环境
[root@desktop ~]# cat /etc/redhat-release 
Red Hat Enterprise Linux Server release 7.2 (Maipo)

###从虚拟机直接登陆到shell，此时产生tty1，如下
[root@desktop ~]# tty
/dev/tty1     
[root@desktop ~]# ps -ef|grep tty
root       1796   1719  0 15:23 tty1     00:00:00 -bash
root       1886   1843  0 15:24 pts/0    00:00:00 grep --color=auto tty

###切换到Documents目录
[root@desktop ~]# cd Documents/
[root@desktop Documents]# pwd
/root/Documents

###从SecureCRT ssh登陆到shell，此时产生一个伪终端，为pts/0
[root@desktop ~]# tty
/dev/pts/0
[root@desktop ~]# ps -ef|grep tty
root       1796   1719  0 15:23 tty1     00:00:00 -bash
root       1886   1843  0 15:24 pts/0    00:00:00 grep --color=auto tty

###在虚拟机切换tty，此时同时按下CTRL+ALT+F2，出现一个新的登陆提示
[root@desktop ~]# tty
/dev/tty2

###如下，可以看到有2个tty，一个是tty1，一个是tty2
[root@desktop ~]# ps -ef|grep tty |grep -v grep
root       1796   1719  0 15:23 tty1     00:00:00 -bash
root       1930   1912  0 15:27 tty2     00:00:00 -bash
root       1997   1930  0 15:24 tty2     00:00:00 ps -ef

###按下CTRL+ALT+F1，此时回到tty1终端，如下，回到tty1的Documents目录下
[root@desktop Documents]#

###再开几个tty终端，如下，出现了tty3，tty6等。
[root@desktop Documents]# ps -ef|grep tty
root       1796   1719  0 15:23 tty1     00:00:00 -bash
root       1930   1912  0 15:27 tty2     00:00:00 -bash
root       2056   2050  0 15:33 tty3     00:00:00 -bash
root       2187   2172  0 15:38 tty6     00:00:00 -bash
root       2230   1843  0 15:38 pts/0    00:00:00 grep --color=auto tty

[root@desktop ~]# tty
/dev/tty6

###在tty6切换到X window
[root@desktop ~]# startx

### 在SecureCRT 虚拟终端下查看，可以看到tty6调用了X window
[root@desktop Documents]# ps -ef|grep tty6
[root@desktop Documents]# ps -ef|grep tty6 |grep -v grep
root       2187   2172  0 15:38 tty6     00:00:00 -bash
root       2242   2187  0 15:39 tty6     00:00:00 /bin/sh /bin/startx
root       2280   2242  0 15:40 tty6     00:00:00 xinit /etc/X11/xinit/xinitrc -- 
      /usr/bin/X :0 vt6 -keeptty -auth /root/.serverauth.2242
root       2281   2280  0 15:40 tty6     00:00:00 /usr/bin/X :0 vt6 -keeptty -auth 
      /root/.serverauth.2242

[root@desktop ~]# ### Author : Leshami QQ/Weixin : 645746311
[root@desktop ~]# ### Blog   : http://blog.csdn.net/leshami

###查看当前系统登陆用户终端使用情形
[root@desktop ~]# who
root     tty1         2017-08-11 15:23
root     pts/0        2017-08-11 15:23 (192.168.81.1)
root     tty2         2017-08-11 15:27
root     tty3         2017-08-11 15:33
root     tty6         2017-08-11 15:38
root     pts/1        2017-08-11 15:40 (:0)

###查看伪终端使用的情形
[root@desktop ~]# ps -ef|grep pts|grep -v grep
root       1839   1645  0 15:23 ?        00:00:00 sshd: root@pts/0
root       1843   1839  0 15:23 pts/0    00:00:00 -bash
root       2784   2777  0 15:40 pts/1    00:00:00 /bin/bash
root       4313   1843  0 17:31 pts/0    00:00:00 ps -ef

###查看虚拟终端设备，如下，当前有2个伪终端对应到ptmx
[root@desktop ~]# ls /dev/pt*
/dev/ptmx

/dev/pts:
0  1  ptmx

###在SecureCRT再启动一个连接，再次查看多出了一个，即在ptmx多出了一个为2的slave
[root@desktop ~]# ls /dev/pt*
/dev/ptmx

/dev/pts:
0  1  2  ptmx
}
