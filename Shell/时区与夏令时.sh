#修改时区
cp -af /usr/share/zoneinfo/UTC /etc/localtime 
vi /etc/sysconfig/clock 写入UTC=true
date 
cp -af /usr/share/zoneinfo/Asia/Shanghai /etc/localtime 
vi /etc/sysconfig/clock  写入UTC=false

cp -af /usr/share/zoneinfo/UTC /etc/localtime 
vi /etc/sysconfig/clock 写入UTC=true
date 
cp -af /usr/share/zoneinfo/Asia/Shanghai /etc/localtime 
vi /etc/sysconfig/clock  写入UTC=false

#夏时令（Daylight Saving Time：DST）
Europe/Paris
#跳入
进入夏令时时，系统时间提前一个小时，以法国为例，2016年3月27号凌晨2点进入夏令时，所以时间从凌晨01:59:59会直接跳变成03:00:00。
#跳出
跳出夏令时时，系统时间向后调一个小时，还是以法国为例，2016年10月30号凌晨3点跳出夏令时，所以时间从凌晨02:59:59会又跳变成02:00:00。
#操作系统时间查询
使用 date -R 命令查询操作系统时间，可以查看到当前系统时间、时区信息
[root@allinone-centos cloud-01]# date -R
Tue, 19 Dec 2017 11:10:12 +0800

当跳入夏令时时，操作系统查询到的时区会加1。
以法国巴黎为例，巴黎的时区是+0100，非夏令时查询系统时间时，时区信息为+0100，但是当进入夏令时时，系统的时区信息就变成了+0200.

Europe/Berlin

#时区修改
1.找到国家代码
cat /usr/share/zoneinfo/iso3166.tab |grep China
CN	China

2.根据因家代码获取时区
cat /usr/share/zoneinfo/zone.tab|grep CN

[root@allinone-centos ~]# cat /usr/share/zoneinfo/zone.tab|grep CN
AR	-3124-06411	America/Argentina/Cordoba	most locations (CB, CC, CN, ER, FM, MN, SE, SF)
CN	+3114+12128	Asia/Shanghai	Beijing Time
CN	+4348+08735	Asia/Urumqi	Xinjiang Time

3.执行 zdump -v Asia/Shanghaii 可以查看该时区夏令时规则
例如：
/usr/share/zoneinfo # zdump -v Asia/Shanghai
Asia/Shanghai  -9223372036854775808 = NULL
Asia/Shanghai  -9223372036854689408 = NULL
Asia/Shanghai  Sat Dec 31 15:54:07 1927 UTC = Sat Dec 31 23:59:59 1927 CST isdst=0 gmtoff=29152
Asia/Shanghai  Sat Dec 31 15:54:08 1927 UTC = Sat Dec 31 23:54:08 1927 CST isdst=0 gmtoff=28800
Asia/Shanghai  Sun Jun  2 15:59:59 1940 UTC = Sun Jun  2 23:59:59 1940 CST isdst=0 gmtoff=28800
Asia/Shanghai  9223372036854689407 = NULL

4.修改时区
a.修改/etc/sysconfig/clock文件中 的 TIMEZONE = "Asia/Shanghai"
b.将对应的/usr/share/zoneinfo的文件copy到 /etc/localtime 
cp /usr/share/zoneinfo/Asia/Shanghai   /etc/localtime
不需要重新启动,修改后即生效
也可以通过tzselect命令来选择设置或是通过YaST来设置


方式一： ln /usr/share/zoneinfo/Europe/Berlin /etc/localtime rm /etc/localtime ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime 
方式二： cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime
注意：/etc/localtime本身记录的是系统本地时区（此处默认为亚洲上

在中国可以使用：
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

将当前时间和日期写入BIOS，避免重启后失效
hwclock -w

cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime
date -R
zdump -v Europe/Berlin
Europe/Berlin  Sun Oct 25 01:00:00 2499 UTC = Sun Oct 25 02:00:00 2499 CET isdst=0 gmtoff=3600


#针对两条，怎么构造date命令，触发时间跳变呢
Europe/Berlin  Sun Oct 25 00:59:59 2499 UTC = Sun Oct 25 02:59:59 2499 CEST isdst=1 gmtoff=7200
Europe/Berlin  Sun Oct 25 01:00:00 2499 UTC = Sun Oct 25 02:00:00 2499 CET isdst=0 gmtoff=3600

date -s "2017-10-25 00:59:50" 

Europe/Paris  Sun Mar 29 01:00:00 2499 UTC = Sun Mar 29 03:00:00 2499 CEST isdst=1 gmtoff=7200

[root@allinone-centos ~]# date
Wed Oct 25 01:10:27 CEST 2017
[root@allinone-centos ~]# date -R
Wed, 25 Oct 2017 01:10:29 +0200
[root@allinone-centos ~]# date -s "2016-3-27 01:59:58"
Sun Mar 27 01:59:58 CET 2016
[root@allinone-centos ~]# 
[root@allinone-centos ~]# 
[root@allinone-centos ~]# date 
Sun Mar 27 03:00:13 CEST 2016
[root@allinone-centos ~]# 
[root@allinone-centos ~]# 
[root@allinone-centos ~]# date -R
Sun, 27 Mar 2016 03:00:27 +0200

#isdst=1 表示进行了使用了夏令时

[root@allinone-centos ~]# zdump -v Europe/Berlin |grep 2017
Europe/Berlin  Sun Mar 26 00:59:59 2017 UTC = Sun Mar 26 01:59:59 2017 CET isdst=0 gmtoff=3600
Europe/Berlin  Sun Mar 26 01:00:00 2017 UTC = Sun Mar 26 03:00:00 2017 CEST isdst=1 gmtoff=7200
Europe/Berlin  Sun Oct 29 00:59:59 2017 UTC = Sun Oct 29 02:59:59 2017 CEST isdst=1 gmtoff=7200
Europe/Berlin  Sun Oct 29 01:00:00 2017 UTC = Sun Oct 29 02:00:00 2017 CET isdst=0 gmtoff=3600

#这个是按列来看的,如果本地时间是UTC就按UTC的时间设置，是CET的就按CET设置，就能触发跳变
date -s "2017-3-26 01:59:57"

[root@allinone-centos ~]# date 
Sun Mar 26 01:04:27 CET 2017
[root@allinone-centos ~]# date -s "2017-3-26 01:59:57"
Sun Mar 26 01:59:57 CET 2017
[root@allinone-centos ~]# date
Sun Mar 26 03:00:00 CEST 2017


date -s "2017-10-29 02:59:50"
date -s "2017-10-29 00:59:58"

zdump命令可以根据时区名查看夏令时切换时间
返回信息的格式如下：

时区名称 UTC时间 本地时间 isdst=0/1
isdst=0表示非夏令时，isdst=1表示处于夏令时。
说明
1、夏令时规则一般都是固定为每年X月第X个星期X开始，每年X月第X个星期X结束。即周的固定的，日期是不固定的。如US/Alaska是每年3月第2个星期天开始，11月的第1个星期天结束。
2、建议使用zdump -v命令连续查看三年（今年、明年及后年），即可知道其夏令时规则。
