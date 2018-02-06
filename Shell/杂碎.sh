#判断IP地址冲突的方法
发个arp的广播请求包，回复的包中有多个mac地址的，肯定是IP冲突了
TestServer66:~ # arping -I eth2 10.71.170.166
ARPING 10.71.170.166 from 10.71.170.135 eth2
Unicast reply from 10.71.170.166 [70:F3:95:0C:7A:EB] 10.505ms
Unicast reply from 10.71.170.166 [70:F3:95:0C:45:8C] 537.857ms


#有两种方法可以从超时实用程序向进程发送SIGKILL信号.一种是SIGTERM信号SIGKILL，另一种是SIGTERM信号的序号
timeout -s SIGKILL 1m slow-command arg1 arg2;
timeout -k 9 1m slow-command arg1 arg2;
该过程在60秒后发送一个SIGTERM信号。如果它仍在运行，那么SIGKILL信号会在30秒后发送。
如果timeout超时工具不可用，则可以使用下面的1-liner作为替代。
slow-command arg1 arg2＆sleep 60;kill $!;
慢速命令作为后台进程启动。休眠命令将暂停，直到超时持续时间。在我们的情况下，它会睡60秒。一旦60秒过去，kill命令将发送一个SIGTERM信号给慢速命令进程。 '$！'shell变量将给出最后一个后台作业的PID。
#例子
timeout -s SIGKILL 1 bash -c 'sleep 5';
timeout -k 9 1 bash -c 'sleep 5';
timeout -s SIGKILL 1 sleep 5;
sleep 5 & sleep 10;kill $!;ps -ef|grep sleep;

#windows下打开.ipynb文件
1.首先要下载python，设置环境变量
2.下载pip，设置环境变量
3.打开命令行，进入到python的Scripts文件中，按顺序执行下面三个命令
pip install ipython
pip install 'ipython[notebook]'
ipython notebook

#构造10G的大文件，有什么速度比较快的好方法吗?
dd if=/dev/zero of=hello.log bs=2048M count=5 这样做大概 5分钟
truncate -s 10G bigfile 这样做一秒，但是并不实际占用block
dd if=/dev/zero of=test bs=1M count=0 seek=100000  这样也是一秒，同上

# python json.load和json.loads的区别
load和loads都是实现“反序列化”，区别在于（以Python为例）：

1. loads针对内存对象，即将Python内置数据序列化为字串
如使用json.dumps序列化的对象d_json=json.dumps({'a':1, 'b':2})，在这里d_json是一个字串'{"b": 2, "a": 1}'
d=json.loads(d_json)  #{ b": 2, "a": 1}，使用load重新反序列化为dict

2. load针对文件句柄
如本地有一个json文件a.json则可以d=json.load(open('a.json'))
相应的，dump就是将内置类型序列化为json对象后写入文件

with open(path, 'rw') as cfg:
    cfg_json = json.load(cfg)
    LOG.info("old cfg_json:%s" % cfg_json)
    wraps = json.loads(cfg_json["wrap_list"])
    LOG.info("old wraps:%s " % wraps)
    wraps["wraps"]["auth"][0]["wrap"]=wraps["wraps"]["crypt"][0]["wrap"]
    LOG.info("new wraps:%s " % wraps)
    cfg_json["wrap_list"] = json.dumps(wraps)
    LOG.info("new cfg_json:%s" % cfg_json)
    cfg.write(json.dumps(cfg_json))

#读取配置，有时候是字符串形式的，但不方便处理，可以eval转化成字典来操作，这样就不用管那么多转义字符
{
import ConfigParser
import json

def change_key_cfg(path='server.conf.bak'):
    LOG.info("change_key_cfg start")
    with open(path, 'r+') as cfg:
        parser = ConfigParser.ConfigParser()
        parser.readfd(cfg)
        content = parser.get("DEFAULT", "wrap_list")
        LOG.info("old content:%s " % content)
        if content:
            wraps = json.loads(content)["wraps"]
            LOG.info("old wraps:%s" % wraps)
            wraps["auth"][0]["wrap"] = \
                wraps["crypt"][0]["wrap"]
            LOG.info("new wraps:%s " % wraps)
            parser.set("DEFAULT", "wrap_list", json.dumps(wraps))
            content = parser.get("DEFAULT", "wrap_list")
            LOG.info("new content:%s" % content)
            parser.write(cfg)
        else:
            raise Exception("config %s analyze error!" % path)
    LOG.info("change_key_cfg end")

# 改变配置文件中的秘钥
def change_key_cfg(path):
    LOG.info("change_key_cfg start")
    with open(path, 'r+') as cfg:
        parser = ConfigParser.ConfigParser()
        parser.readfp(cfg)
        wrap_list_str = parser.get("DEFAULT", "wrap_list")
        LOG.info("old wrap_list:%s " % wrap_list_str)
        wrap_list_dict = eval(wrap_list_str)
        if wrap_list_dict:
            wrap_list_dict["wraps"]["auth"][0]["wrap"] = \
                wrap_list_dict["wraps"]["crypt"][0]["wrap"]
            parser.set("DEFAULT", "wrap_list", json.dumps(wrap_list_dict))
            parser.write(open(path, "w"))
            wrap_list_str = parser.get("DEFAULT", "wrap_list")
            LOG.info("new wrap_list:%s" % wrap_list_str)
        else:
            raise Exception("config %s analyze error!" % path)
    LOG.info("change_key_cfg end")
 }

#总结         
json.dumps : dict转成str
json.dump  : 将python数据保存成json
json.loads : str转成dict
json.load  : 从文件句柄中读取json数据

# 文件常见的读写模式

r	以只读模式打开文件	光标在文件开头	如果文件不存在，则出错
r+  以读写模式打开文件	光标在文件开头	如果文件不存在，则出错。读写都可以移动光标。写入时，如果光标不在文件末尾，则会覆盖源文件
w	以只写模式打开文件	光标在文件开头	如果文件不存在，则创建文件，如果文件已存在，则从文件头开始覆盖文件。如果写入内容比源文件少，则会保留未覆盖的内容
w+	以读写模式打开文件	光标在文件开头	如果文件不存在，则会创建文件。文件已存在，从光标位置覆盖文件。读写都可以移动光标。
a	以只写模式打开文件	光标在文件结尾，追加模式	文件不存在是，创建文件。文件存在时，打开时，光标在文件末尾，写入不覆盖源文件
a+	以读写模式打开文件	光标在文件结尾，追加模式	文件不存在是，创建文件。文件存在时，打开时，光标在文件末尾，写入不覆盖源文件。
b	与前面六种结合使用，以二进制方式读或者写


f.read([size])：默认一次性读入打开的文件内容。如果有size参数，则指定每次读入字符数。注意，此处按字符来读入，一个汉字为一个字符
f.readline([size])：一次读入一行文件内容
f.readlines([size])：将文件内容全部读入，保存在一个列表中，每行为一个元素。
f.write(str,encoding=)：将str写入文件，可以指定写入的编码格式，默认为utf-8
f.writelines() ：写入一行文件
f.readable() ： 判断是否可读，返回布尔值。如果是在只写模式下打开文件， 也是返回false
f.writable()：判断是否可写
f.tell() ：  返回当前光标位置
f.seek(offset,whence=0)：将光标位置移至所需位置。offset为偏移量。whence定义开始偏移的位置。0为从文件开头偏移。1为从当前位置开始偏移。2为从文件末尾开始偏移，默认为0。注意，此处偏移量是按字节计算，也就是一个汉字最少需要两个偏移量。如果偏移量正好讲一个汉字分开，则会报错。
f.truncate(数值)   从光标位置截断/删除后面内容。
f.flush()  将内存内容立即写入硬盘


实例1：
命令：每隔一秒高亮显示网络链接数的变化情况
watch -n 1 -d netstat -ant
说明：
其它操作：
切换终端： Ctrl+x
退出watch：Ctrl+g
实例2：每隔一秒高亮显示http链接数的变化情况
命令：
watch -n 1 -d 'pstree|grep http'
说明：
每隔一秒高亮显示http链接数的变化情况。 后面接的命令若带有管道符，需要加''将命令区域归整。
实例3：实时查看模拟攻击客户机建立起来的连接数
命令：
watch 'netstat -an | grep:21 | \ grep<模拟攻击客户机的IP>| wc -l' 
说明：
实例4：监测当前目录中 scf 的文件的变化
命令：
watch -d 'ls -l|grep scf' 
实例5：10秒一次输出系统的平均负载
命令：
watch -n 10 'cat /proc/loadavg'
watch -n 1 'ps -ef| grep heartBeat | grep gauss | grep -v watch' 


#python 进程调用查看
hostname:~ # pidstat -p 4213 -t 1
Linux 3.10.0-514.35.4.1_47.x86_64 (0EAD26BC-AA18-7143-853A-8E0EA58B3DAB) 	02/05/2018 	_x86_64_	(16 CPU)

05:26:31 PM   UID      TGID       TID    %usr %system  %guest    %CPU   CPU  Command
05:26:32 PM  1000      4213         -    0.00    0.00    0.00    0.00    13  python2.7
05:26:32 PM  1000         -      4213    0.00    0.00    0.00    0.00    13  |__python2.7
05:26:32 PM  1000         -      4332    0.00    0.00    0.00    0.00     2  |__python2.7
05:26:32 PM  1000         -      1852    0.00    0.00    0.00    0.00     8  |__python2.7


hostname:~ # pstree -p 4213
python2.7(4213)─┬─{python2.7}(4332)
                └─{python2.7}(1852)
                
#命令   作用
iostat  磁盘IO监控
vmstat  虚拟内存监控
prstat  进程监控
mpstat  CPU监控
netstat 网络状态监控
sar     全面监控
pidstat 监控进程与资源
pstree  进程监控

因为HTTPS是加密连接，无法被审计。此时公司Proxy代理会进行HTTPS中间人攻击（Man-in-the-middle-attack），将对方的证书替换成公司IT签发的证书，以确保所有流量可以被解密审计。我们平时试用的Windows都已经预置了公司的“根证书”，所以不会遇到上面的错误。但是Linux机器都是自己装的系统，没有公司“根证书”，这导致了诸多不便。

yum install ca-certificates
update-ca-trust force-enable
cp hw.ca /etc/pki/ca-trust/source/anchors/
update-ca-trust extract
export http_proxy=http://aa:bb%40123456@proxy.XXXX.com:8080/
export https_proxy=http://aa:bb%40123456@proxy.XXXX.com:8080/
curl -I https://github.com
