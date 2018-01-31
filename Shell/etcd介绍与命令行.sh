# etcd 命令行
比较重要的配置
-name 节点名称，默认是UUID
-data-dir 保存日志和快照的目录，默认为当前工作目录
-addr 公布的ip地址和端口。 默认为127.0.0.1:2379
-bind-addr 用于客户端连接的监听地址，默认为-addr配置
-peers 集群成员逗号分隔的列表，例如 127.0.0.1:2380,127.0.0.1:2381
-peer-addr 集群服务通讯的公布的IP地址，默认为 127.0.0.1:2380.
-peer-bind-addr 集群服务通讯的监听地址，默认为-peer-addr配置

上述配置也可以设置配置文件，默认为/etc/etcd/etcd.conf。

ectdctl介绍
我们可以使用etcdctl这个官方提供的客户端来对etcd进行操作，可以从github.com/coreos/etcd/releases下载。
etcdctl是一个命令行的客户端，它提供了一下简洁的命令，可以方便我们在对服务进行测试或者手动修改数据库内容。建议刚刚接触etcd的同学可以先通过cetdctl来熟悉相关操作。这些操作跟HTTP API基本上是对应的。

etcdctl支持下面列出来的命令，基本上可以分为数据库操作和非数据库操作，可以查看etcdctl README.md来了解更多

etcdctl -h
{
NAME:
   etcdctl - A simple command line client for etcd.

USAGE:
   etcdctl [global options] command [command options] [arguments...]

VERSION:
   2.2.1

COMMANDS:
   backup		backup an etcd directory
   cluster-health	check the health of the etcd cluster
   mk			make a new key with a given value
   mkdir		make a new directory
   rm			remove a key or a directory
   rmdir		removes the key if it is an empty directory or a key-value pair
   get			retrieve the value of a key
   ls			retrieve a directory
   set			set the value of a key
   setdir		create a new or existing directory
   update		update an existing key with a given value
   updatedir		update an existing directory
   watch		watch a key for changes
   exec-watch		watch a key for changes and exec an executable
   member		member add, remove and list subcommands
   import		import a snapshot to a cluster
   user			user add, grant and revoke subcommands
   role			role add, grant and revoke subcommands
   auth			overall auth controls
   help, h		Shows a list of commands or help for one command

GLOBAL OPTIONS:
   --debug			output cURL commands which can be used to reproduce the request
   --no-sync			don't synchronize cluster information before sending request
   --output, -o 'simple'	output response in the given format (`simple`, `extended` or `json`)
   --discovery-srv, -D 		domain name to query for SRV records describing cluster endpoints
   --peers, -C 			a comma-delimited list of machine addresses in the cluster (default: "http://127.0.0.1:4001,http://127.0.0.1:2379")
   --endpoint 			a comma-delimited list of machine addresses in the cluster (default: "http://127.0.0.1:4001,http://127.0.0.1:2379")
   --cert-file 			identify HTTPS client using this SSL certificate file
   --key-file 			identify HTTPS client using this SSL key file
   --ca-file 			verify certificates of HTTPS-enabled servers using this CA bundle
   --username, -u 		provide username[:password] and prompt if password is not supplied.
   --timeout '1s'		connection timeout per request
   --total-timeout '5s'		timeout for the command execution (except watch)
   --help, -h			show help
   --version, -v		print the version
}

命令选项
{
--debug 输出 cURL 命令，显示执行命令的时候发起的请求
--no-sync 发出请求之前不同步集群信息
--output, -o 'simple' 输出内容的格式 (simple 为原始信息，json 为进行json格式解码，易读性好一些)
--peers, -C 指定集群中的同伴信息，用逗号隔开 (默认为: "127.0.0.1:4001")
--cert-file HTTPS 下客户端使用的 SSL 证书文件
--key-file HTTPS 下客户端使用的 SSL 密钥文件
--ca-file 服务端使用 HTTPS 时，使用 CA 文件进行验证
--help, -h 显示帮助命令信息
--version, -v 打印版本信息
}

数据库操作
{
数据库操作围绕对键值和目录的 CRUD （符合 REST 风格的一套操作：Create）完整生命周期的管理。

etcd 在键的组织上采用了层次化的空间结构（类似于文件系统中目录的概念），用户指定的键可以为单独的名字，如 testkey，此时实际上放在根目录 / 下面，也可以为指定目录结构，如 cluster1/node2/testkey，则将创建相应的目录结构。

注：CRUD 即 Create, Read, Update, Delete，是符合 REST 风格的一套 API 操作。

set

指定某个键的值。例如

# etcdctl set /testdir/testkey "Hello world"
Hello world
支持的选项包括：

--ttl '0'            该键值的超时时间（单位为秒），不配置（默认为 0）则永不超时
--swap-with-value value 若该键现在的值是 value，则进行设置操作
--swap-with-index '0'    若该键现在的索引值是指定索引，则进行设置操作
get

获取指定键的值。例如

# etcdctl get /testdir/testkey
Hello world
当键不存在时，则会报错。例如

# etcdctl get /testdir/testkey2
Error:  100: Key not found (/testdir/testkey2) [18]
支持的选项为

--sort    对结果进行排序
--consistent 将请求发给主节点，保证获取内容的一致性
update

当键存在时，更新值内容。例如

# etcdctl update /testdir/testkey "Hello"
Hello
当键不存在时，则会报错。例如

# etcdctl update /testdir/testkey2 "Hello"
Error:  100: Key not found (/testdir/testkey2) [19]
支持的选项为

--ttl '0'    超时时间（单位为秒），不配置（默认为 0）则永不超时
rm

删除某个键值。例如

# etcdctl rm /testdir/testkey
PrevNode.Value: Hello
当键不存在时，则会报错。例如

# etcdctl rm /testdir/testkey
Error:  100: Key not found (/testdir/testkey) [20]
支持的选项为

--dir        如果键是个空目录或者键值对则删除
--recursive        删除目录和所有子键
--with-value     检查现有的值是否匹配
--with-index '0'    检查现有的 index 是否匹配
mk

如果给定的键不存在，则创建一个新的键值。例如

# etcdctl mk /testdir/testkey "Hello world"
Hello world
当键存在的时候，执行该命令会报错，例如

# etcdctl mk /testdir/testkey "Hello world"
Error:  105: Key already exists (/testdir/testkey) [21]
支持的选项为

--ttl '0'    超时时间（单位为秒），不配置（默认为 0）则永不超时
mkdir

如果给定的键目录不存在，则创建一个新的键目录。例如

# etcdctl mkdir testdir2
当键目录存在的时候，执行该命令会报错，例如

# etcdctl mkdir testdir2
Error:  105: Key already exists (/testdir2) [22]
支持的选项为

--ttl '0'    超时时间（单位为秒），不配置（默认为 0）则永不超时
setdir

创建一个键目录，无论存在与否。

支持的选项为

--ttl '0'    超时时间（单位为秒），不配置（默认为 0）则永不超时
updatedir

更新一个已经存在的目录。 支持的选项为

--ttl '0'    超时时间（单位为秒），不配置（默认为 0）则永不超时
rmdir

删除一个空目录，或者键值对。

# etcdctl setdir dir1
# etcdctl rmdir dir1
若目录不空，会报错

# etcdctl set /dir/testkey hi
hi
# etcdctl rmdir /dir
Error:  108: Directory not empty (/dir) [29]
ls

列出目录（默认为根目录）下的键或者子目录，默认不显示子目录中内容。

例如

# etcdctl ls
/testdir
/testdir2
/dir
# etcdctl ls dir
/dir/testkey
支持的选项包括

--sort    将输出结果排序
--recursive    如果目录下有子目录，则递归输出其中的内容
-p        对于输出为目录，在最后添加 `/` 进行区分

}

非数据库操作
{
backup

备份 etcd 的数据。

支持的选项包括

--data-dir         etcd 的数据目录
--backup-dir     备份到指定路径
watch

监测一个键值的变化，一旦键值发生更新，就会输出最新的值并退出。

例如，用户更新 testkey 键值为 Hello watch。

# etcdctl get /testdir/testkey
Hello world
# etcdctl set /testdir/testkey "Hello watch"
Hello watch
# etcdctl watch testdir/testkey
Hello watch
支持的选项包括

--forever        一直监测，直到用户按 `CTRL+C` 退出
--after-index '0'    在指定 index 之前一直监测
--recursive        返回所有的键值和子键值
exec-watch

监测一个键值的变化，一旦键值发生更新，就执行给定命令。

例如，用户更新 testkey 键值。

# etcdctl exec-watch testkey -- sh -c 'ls'
default.etcd
Documentation
etcd
etcdctl
etcd-migrate
README-etcdctl.md
README.md
支持的选项包括

--after-index '0'    在指定 index 之前一直监测
--recursive        返回所有的键值和子键值
member

通过 list、add、remove 命令列出、添加、删除 etcd 实例到 etcd 集群中。

例如本地启动一个 etcd 服务实例后，可以用如下命令进行查看。

$ etcdctl member list
ce2a822cea30bfca: name=default peerURLs=http://localhost:2380,http://localhost:7001 clientURLs=http://localhost:2379,http://localhost:4001

}

应用场景
{
场景一：服务发现（Service Discovery）
服务发现要解决的也是分布式系统中最常见的问题之一，即在同一个分布式集群中的进程或服务，要如何才能找到对方并建立连接。本质上来说，服务发现就是想要了解集群中是否有进程在监听udp或tcp端口，并且通过名字就可以查找和连接。

场景二：消息发布与订阅
在分布式系统中，最适用的一种组件间通信方式就是消息发布与订阅。即构建一个配置共享中心，数据提供者在这个配置中心发布消息，而消息使用者则订阅他们关心的主题，一旦主题有消息发布，就会实时通知订阅者。通过这种方式可以做到分布式系统配置的集中式管理与动态更新。

场景三：分布式通知与协调
这里说到的分布式通知与协调，与消息发布和订阅有些相似。都用到了etcd中的Watcher机制，通过注册与异步通知机制，实现分布式环境下不同系统之间的通知与协调，从而对数据变更做到实时处理。实现方式通常是这样：不同系统都在etcd上对同一个目录进行注册，同时设置Watcher观测该目录的变化（如果对子目录的变化也有需要，可以设置递归模式），当某个系统更新了etcd的目录，那么设置了Watcher的系统就会收到通知，并作出相应处理。

场景四：分布式锁
因为etcd使用Raft算法保持了数据的强一致性，某次操作存储到集群中的值必然是全局一致的，所以很容易实现分布式锁。锁服务有两种使用方式，一是保持独占，二是控制时序。
保持独占即所有获取锁的用户最终只有一个可以得到。etcd为此提供了一套实现分布式锁原子操作CAS（CompareAndSwap）的API。通过设置prevExist值，可以保证在多个节点同时去创建某个目录时，只有一个成功。而创建成功的用户就可以认为是获得了锁。
控制时序，即所有想要获得锁的用户都会被安排执行，但是获得锁的顺序也是全局唯一的，同时决定了执行顺序。etcd为此也提供了一套API（自动创建有序键），对一个目录建值时指定为POST动作，这样etcd会自动在目录下生成一个当前最大的值为键，存储这个新的值（客户端编号）。同时还可以使用API按顺序列出所有当前目录下的键值。此时这些键的值就是客户端的时序，而这些键中存储的值可以是代表客户端的编号。
}

参考博客
{
http://www.cnblogs.com/shhnwangjian/p/7560460.html
http://www.cnblogs.com/zhenyuyaodidiao/p/6237019.html
集群搭建有三种方式，分布是静态配置，etcd发现，dns发现

Static，etcd Discovery，DNS Discovery。 
● Static适用于有固定IP的主机节点 
● etcd Discovery适用于DHCP环境 
● DNS Discovery依赖DNS SRV记录 

http://www.cnblogs.com/breg/p/5756558.html
etcd 命令行


# 192.168.2.253
etcd --name infra0 --initial-advertise-peer-urls http://192.168.2.253:2380 --listen-peer-urls http://192.168.2.253:2380 --listen-client-urls http://192.168.2.253:2379,http://127.0.0.1:2379 --advertise-client-urls http://192.168.2.253:2379 --initial-cluster-token etcd-cluster-1 --initial-cluster infra0=http://192.168.2.253:2380,infra1=http://192.168.0.100:2380 --initial-cluster-state new

# 192.168.0.100
etcd --name infra1 --initial-advertise-peer-urls http://192.168.0.100:2380 --listen-peer-urls http://192.168.0.100:2380 --listen-client-urls http://192.168.0.100:2379,http://127.0.0.1:2379 --advertise-client-urls http://192.168.0.100:2379 --initial-cluster-token etcd-cluster-1 --initial-cluster infra1=http://192.168.0.100:2380,infra0=http://192.168.2.253:2380 --initial-cluster-state new
}


