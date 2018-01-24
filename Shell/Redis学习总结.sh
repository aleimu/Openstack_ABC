Redis支持五种数据类型：string（字符串），hash（哈希），list（列表），set（集合）及zset（sorted set：有序集合）。

#Redis 原生常用命令
{
# String（字符串）
String是Redis的最基本的类型，可以理解成与memcached一模一样的类型，一个key对应一个value。String类型是二进制安全的，也就是说Redis的string可以包含任何数据，比如jpg图片或者序列化对象等。
常用命令:
命令	说明
SET key value	设置指定key的值
GET key	获取指定key的值
GETRANGE key start end	返回key中字符串值的子字符串
GETSET key value	将给定key设为value，并返回key的旧值
MGET key1 [key2..]	获取所有（一个或多个）给定key的值
SETEX key seconds value	将值value关联到key，并将key的过期时间设为seconds
SETNX key value	只有在key不存在时设置key的值
INCR key	将key中存储的数字值增一
DECR key	将key中存储的数字值减一
APPEND key value	如果key已经存在并且是一个字符串，APPEND命令将value追加到key原来的值的末尾
 
 
# Hash（哈希）
Redis hash是一个string类型的field和value的映射表，hashtebie适合于存储对象。Redis中每个hash可以存储232-1个键值对。
常用命令:
命令	描述
HDEL key field1 [field2..]	删除一个或多个哈希表字段
HEXISTS key field	查看哈希表key中，指定的字段是否存在
HGET key field	获取存储在哈希表中指定字段的值
HGETALL key	获取在哈希表中指定key的所有字段的和值
HKEYS key	获取所有哈希表中的字段
HLEN key	获取哈希表中字段的数量
HMGET key field1 [field2..]	获取所有给定字段的值
HSET key field value	将哈希表key中的字段field的值设为value
HMSET key field1 value1 [field2 value2..]	同时将多个field-value对设置到哈希表key中
HVALS key	获取哈希表中所有值
 
# List（列表）
Redis列表是简单的字符串列表，按照插入顺序排序。可以添加一个元素到列表的头部（左边）或者尾部（右边），一个列表最多可以包含232-1个元素。
常用命令:
命令	描述
LPUSH key value1 [value2..]	将一个或多个值插入到列表头部
RPUSH key value1 [value2..]	将一个或多个值插入到列表尾部
LPOP key	移出并获取列表的第一个元素
RPOP key	移出并获取列表的最后一个元素
LINDEX key index	通过索引获取列表中的元素
LLEN key	获取列表长度
LRANGE key start stop	获取列表指定范围内的元素
LSET key index value	通过索引设置列表元素的值
 
 
# Set（集合）
Redis的Set是string类型的无序集合。集合成员是唯一的，这就意味着集合中不能出现重复的数据。Redis中集合是通过哈希表实现的，所以添加，删除，查找的复杂度都是O(1)。集合中最大的成员数为232-1。
常用命令:
命令	描述
SADD key member1 [member..]	向集合添加一个或多个成员
SCARD key	获取集合的成员数
SREM key member1 [member2..]	移除集合中一个或多个成员
SUNION key1 [key2..]	返回所有给定集合的并集
SDIFF key1 [key2..]	返回给定所有集合的差集
SINTER key1 [key2..]	返回所有给定集合的交集
SISMEMBER key member	判断member元素是否是集合key的成员
SMEMBERS key	返回集合中所有成员
SPOP key	移除并返回集合中一个随机元素
 
# Zset（有序集合）
Redis有序集合和集合一样，也是string类型元素的集合，且不允许重复。不同的是每个元素都会关联一个double类型的分数，redis正是通过分数来为集合中的成员进行从小到大的排序。有序集合的成员是唯一的，但分数是可以重复的。集合是通过哈希表实现的，所以添加，删除，查找的复杂度都是O(1)。集合中最大的成员数为232-1。
常用命令:
命令	描述
ZADD key score1 member1 [score2 member2..]	向有序集合中添加一个或多个成员，或者更新已存在成员的分数
ZCARD key	获取有序集合的成员数
ZCOUNT key min max	计算在有序集合中指定区间分数的成员数
ZREM key member1 [member2..]	移除集合中一个或多个成员
ZRANK key member	返回有序集合中指定成员的索引
ZREMRANGEBYSCORE key min max	移除有序集合中给定的分数区间的所有成员
ZREVRANGE key start stop [WITHSCORES]	返回有序集中指定区间内的成员，通过索引，分数从高到低排序
 
# 键管理
Redis键相关的命令用于管理redis的键。
Redis提供的键命令见下表：
命令	描述
DEL key	删除key
EXISTS key	检查key是否存在
EXPIRE key seconds	为给定key设置过期时间
EXPIREAT key timestamp	与expire的不同之处在于此命令接受的时间参数是UNIX时间戳
PEXPIRE key milliseconds	设置key的过期时间，以毫秒计
PEXPIREAT key milliseconds-timestamp	设置key过期时间的时间戳，以毫秒计
KEYS pattern	查找所有符合给定模式的key
MOVE key db	将当前数据库中的key移动到给定的数据库db中
PERSIST key	移除key的过期时间，key将持久保持
PTTL key	以毫秒为单位，返回key的剩余过期时间
TTL	以秒为单位，返回key的剩余过期时间
RANDOMKEY	从当前数据库中随机返回一个key
RENAME key newkey	修改key的名称
RENAMENX key newkey	仅当key不存在时，将key改名为newkey
}

#服务端启动
redis-server.exe redis.windows.conf
#客户端连接
redis-cli(.exe) -h host -p port -a password 
#使用 * 号获取所有配置项
CONFIG GET *
#修改配置
CONFIG SET CONFIG_NAME NEW_CONFIG_VALUE
#查看配置
CONFIG GET CONFIG_SETTING_NAME
#去除主从关系
slaveof no one
#增加主从关系
SLAVEOF host port
#查看keys个数
keys *      // 查看所有keys
keys prefix_*     // 查看前缀为"prefix_"的所有keys
#清空数据库
flushdb   // 清除当前数据库的所有keys
flushall    // 清除所有数据库的所有keys
#连接操作命令
quit：关闭连接（connection）
auth：简单密码认证
help cmd： 查看cmd帮助，例如：help quit
#持久化
save：将数据同步保存到磁盘
bgsave：将数据异步保存到磁盘
lastsave：返回上次成功将数据保存到磁盘的Unix时戳
shundown：将数据同步保存到磁盘，然后关闭服务
#远程服务控制
info：提供服务器的信息和统计
monitor：实时转储收到的请求
slaveof：改变复制策略设置
config：在运行时配置Redis服务器
info replication：查看主从信息 

#主备模式总结
Master可读可写，Slaver只能读，不能写
Master可以对应多个Slaver，但是数量越多压力越大，延迟就可能越严重
Master写入后立即返回，几乎同时将写入异步同步到各个Slaver，所以基本上延迟可以忽略
可以通过slaveof no one命令将Slaver升级为Master（当Master挂掉时，手动将某个Slaver变为Master）
可以通过sentinel哨兵模式监控Master，当Master挂掉时自动选举Slaver变为Master，其它Slaver自动重连新的Master

/etc/redis.conf 配置项说明如下：
{
1. Redis默认不是以守护进程的方式运行，可以通过该配置项修改，使用yes启用守护进程
daemonize no
2. 当Redis以守护进程方式运行时，Redis默认会把pid写入/var/run/redis.pid文件，可以通过pidfile指定
pidfile /var/run/redis.pid
3. 指定Redis**端口，默认端口为6379，6379在手机按键上MERZ对应的号码，而MERZ取自意大利歌女Alessia Merz的名字
port 6379
4. 绑定的主机地址
bind 127.0.0.1
5.当 客户端闲置多长时间后关闭连接，如果指定为0，表示关闭该功能
timeout 300
6. 指定日志记录级别，Redis总共支持四个级别：debug、verbose、notice、warning，默认为verbose
loglevel verbose
7. 日志记录方式，默认为标准输出，如果配置Redis为守护进程方式运行，而这里又配置为日志记录方式为标准输出，则日志将会发送给/dev/null
logfile stdout
8. 设置数据库的数量，默认数据库为0，可以使用SELECT 命令在连接上指定数据库id
databases 16
9. 指定在多长时间内，有多少次更新操作，就将数据同步到数据文件，可以多个条件配合
save 
Redis默认配置文件中提供了三个条件：
save 900 1
save 300 10
save 60 10000
分别表示900秒（15分钟）内有1个更改，300秒（5分钟）内有10个更改以及60秒内有10000个更改。
10. 指定存储至本地数据库时是否压缩数据，默认为yes，Redis采用LZF压缩，如果为了节省CPU时间，可以关闭该选项，但会导致数据库文件变的巨大
rdbcompression yes
11. 指定本地数据库文件名，默认值为dump.rdb
dbfilename dump.rdb
12. 指定本地数据库存放目录
dir ./
13. 设置当本机为slav服务时，设置master服务的IP地址及端口，在Redis启动时，它会自动从master进行数据同步
slaveof 
14. 当master服务设置了密码保护时，slav服务连接master的密码
masterauth 
15. 设置Redis连接密码，如果配置了连接密码，客户端在连接Redis时需要通过AUTH 命令提供密码，默认关闭
requirepass foobared
16. 设置同一时间最大客户端连接数，默认无限制，Redis可以同时打开的客户端连接数为Redis进程可以打开的最大文件描述符数，如果设置 maxclients 0，表示不作限制。当客户端连接数到达限制时，Redis会关闭新的连接并向客户端返回max number of clients reached错误信息
maxclients 128
17. 指定Redis最大内存限制，Redis在启动时会把数据加载到内存中，达到最大内存后，Redis会先尝试清除已到期或即将到期的Key，当此方法处理 后，仍然到达最大内存设置，将无法再进行写入操作，但仍然可以进行读取操作。Redis新的vm机制，会把Key存放内存，Value会存放在swap区
maxmemory 
18. 指定是否在每次更新操作后进行日志记录，Redis在默认情况下是异步的把数据写入磁盘，如果不开启，可能会在断电时导致一段时间内的数据丢失。因为 redis本身同步数据文件是按上面save条件来同步的，所以有的数据会在一段时间内只存在于内存中。默认为no
appendonly no
19. 指定更新日志文件名，默认为appendonly.aof
appendfilename appendonly.aof
20. 指定更新日志条件，共有3个可选值： 
no：表示等操作系统进行数据缓存同步到磁盘（快） 
always：表示每次更新操作后手动调用fsync()将数据写到磁盘（慢，安全） 
everysec：表示每秒同步一次（折衷，默认值）
appendfsync everysec 
21. 指定是否启用虚拟内存机制，默认值为no，简单的介绍一下，VM机制将数据分页存放，由Redis将访问量较少的页即冷数据swap到磁盘上，访问多的页面由磁盘自动换出到内存中（在后面的文章我会仔细分析Redis的VM机制）
vm-enabled no
22. 虚拟内存文件路径，默认值为/tmp/redis.swap，不可多个Redis实例共享
vm-swap-file /tmp/redis.swap
23. 将所有大于vm-max-memory的数据存入虚拟内存,无论vm-max-memory设置多小,所有索引数据都是内存存储的(Redis的索引数据 就是keys),也就是说,当vm-max-memory设置为0的时候,其实是所有value都存在于磁盘。默认值为0
vm-max-memory 0
24. Redis swap文件分成了很多的page，一个对象可以保存在多个page上面，但一个page上不能被多个对象共享，vm-page-size是要根据存储的 数据大小来设定的，作者建议如果存储很多小对象，page大小最好设置为32或者64bytes；如果存储很大大对象，则可以使用更大的page，如果不 确定，就使用默认值
vm-page-size 32
25. 设置swap文件中的page数量，由于页表（一种表示页面空闲或使用的bitmap）是在放在内存中的，，在磁盘上每8个pages将消耗1byte的内存。
vm-pages 134217728
26. 设置访问swap文件的线程数,最好不要超过机器的核数,如果设置为0,那么所有对swap文件的操作都是串行的，可能会造成比较长时间的延迟。默认值为4
vm-max-threads 4
27. 设置在向客户端应答时，是否把较小的包合并为一个包发送，默认为开启
glueoutputbuf yes
28. 指定在超过一定的数量或者最大的元素超过某一临界值时，采用一种特殊的哈希算法
hash-max-zipmap-entries 64
hash-max-zipmap-value 512
29. 指定是否激活重置哈希，默认为开启（后面在介绍Redis的哈希算法时具体介绍）
activerehashing yes
30. 指定包含其它的配置文件，可以在同一主机上多个Redis实例之间使用同一份配置文件，而同时各个实例又拥有自己的特定配置文件
include /path/to/local.conf

set key_name value
}
