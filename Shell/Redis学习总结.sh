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

#Redis常用命令速查 <第二篇>
{
Redis常用命令速查 <第二篇>
一、Key
　　Key命令速查：

命令	说明
DEL	删除给定的一个或多个 key，不存在的 key 会被忽略，返回值：被删除 key 的数量
DUMP	序列化给定 key，返回被序列化的值，使用 RESTORE 命令可以将这个值反序列化为 Redis 键
EXISTS	检查给定 key 是否存在
EXPIRE	为给定key设置有效时间，接受时间点
EXPIREAT	为给定key设置有效时间，接受时间戳timestamp
KEYS	查找所有符合给定模式 pattern 的 key；KEYS * 匹配数据库中所有 key；KEYS h?llo 匹配 hello，hallo等。KEYS h[ae]llo匹配hello和hallo
MIGRATE	将 key 原子性地从当前实例传送到目标实例的指定数据库上，一旦传送成功， key 保证会出现在目标实例上，而当前实例上的 key 会被删除。执行的时候会阻塞进行迁移的两个实例
MOVE	将当前数据库的 key 移动到给定的数据库 db 当中
OBJECT	从内部察看给定 key 的 Redis 对象
PERSIST	移除给定 key 的有效时间
PEXPIRE	以毫秒为单位设置 key 的有效时间
PEXPIREAT	以毫秒为单位设置 key 的有效时间(timespan)
PTTL	以毫秒为单位返回key的剩余有效时间
RANDOMKEY	从当前数据库中随机返回(已使用的)一个key
RENAME	将Key改名
RENAMENX	当且仅当 newkey 不存在时，将 key 改名为 newkey
RESTORE	反序列化给定的序列化值，并将它和给定的 key 关联
SORT	返回或保存给定列表、集合、有序集合 key 中经过排序的元素
TTL		以秒为单位，返回给定 key 的剩余有效时间
TYPE	返回 key 所储存的值的类型
SCAN	增量迭代
 

二、String
　　String命令速查：

命令	说明
APPEND	将值追加到指定key的值末尾，如果key不存在，则相当于增加操作。
BITCOUNT	计算给定字符串中，被设置为 1 的Bit位的数量。
BITOP	对一个或多个保存二进制位的字符串 key 进行位元操作
DECR	将 key 中储存的数字值减一。Key不存在，则将值置0，key类型不正确返回一个错误。
DECRBY	将key所储存的值减去指定数量
GET	返回key所关联的字符串值，如果Key储存的值不是字符串类型，返回一个错误。
GETBIT	对key所储存的字符串值，获取指定偏移量上的位
GETRANGE	返回key中字符串值的子字符串，字符串的截取范围由start和end两个偏移量决定
GETSET	将给定key的值设为value，并返回key的旧值。非字符串报错。
INCR	将 key 中储存的数字值增一。不能转换为数字则报错。
INCRBY	将key所储存的值加上指定增量
INCRBYFLOAT	为key中所储存的值加上指定的浮点数增量
MGET	返回所有(一个或多个)给定key的值
MSET	同时设置一个或多个key-value对
MSETNX	同时设置一个或多个key-value对，若一个key已被占用，则全部的执行取消。
PSETEX	以毫秒为单位设置 key 的有效时间
SET	    将字符串值value关联到key 
SETBIT	对key所储存的字符串值，设置或清除指定偏移量上的位(bit)
SETEX	将值value关联到 key，并将key的有效时间(秒)
SETNX	当key未被使用时，设置为指定值
SETRANGE	用value参数覆写(overwrite)给定key所储存的字符串值，从偏移量 offset 开始
STRLEN	返回key所储存的字符串值的长度
 

三、Hash
　　Hash命令速查：

命令	说明
HDEL	删除哈希表 key 中的一个或多个指定域，不存在的域将被忽略。
HEXISTS	查看哈希表 key 中，给定域 field 是否存在
HGET	返回哈希表 key 中给定域 field 的值
HGETALL	返回哈希表 key 中，所有的域和值
HINCRBY	为哈希表 key 中的域 field 的值加上指定增量
HINCRBYFLOAT	为哈希表 key 中的域 field 加上指定的浮点数增量
HKEYS	返回哈希表 key 中的所有域
HLEN	返回哈希表 key 中域的数量
HMGET	返回哈希表 key 中，一个或多个给定域的值
HMSET	同时将多个 field-value (域-值)对设置到哈希表 key 中
HSET	将哈希表 key 中的域 field 的值设为 value
HSETNX	当且仅当域 field 不存在时，将哈希表 key 中的域 field 的值设置为 value
HVALS	返回哈希表 key 中所有域的值
HSCAN	增量迭代
 

四、List
　　List命令速查：

命令	说明
BLPOP	它是 LPOP 命令的阻塞版本，当给定列表内没有任何元素可供弹出的时候，连接将被 BLPOP 命令阻塞，直到等待超时或发现可弹出元素为止
BRPOP	与BLPOP同义，弹出位置不同
BRPOPLPUSH	当列表 source 为空时， BRPOPLPUSH 命令将阻塞连接，直到等待超时
LINDEX	返回列表 key 中，下标为 index 的元素
LINSERT	将值 value 插入到列表 key 当中
LLEN	返回列表 key 的长度
LPOP	移除并返回列表 key 的头元素
LPUSH	将一个或多个值 value 插入到列表 key 的表头
LPUSHX	将值 value 插入到列表 key 的表头，当且仅当 key 存在并且是一个列表
LRANGE	返回列表 key 中指定区间内的元素，区间以偏移量 start 和 stop 指定
LREM	根据参数 count 的值，移除列表中与参数 value 相等的元素
LSET	将列表 key 下标为 index 的元素的值设置为 value
LTRIM	对一个列表进行修剪(trim)，就是说，让列表只保留指定区间内的元素，不在指定区间之内的元素都将被删除
RPOP	移除并返回列表 key 的尾元素
RPOPLPUSH	命令 RPOPLPUSH 在一个原子时间内，执行两个动作：1、将列表 source 中的最后一个元素(尾元素)弹出，并返回给客户端。2、将 source 弹出的元素插入到列表 destination ，作为 destination 列表的的头元素。
RPUSH	将一个或多个值 value 插入到列表 key 的表尾
RPUSHX	将值 value 插入到列表 key 的表尾，当且仅当 key 存在并且是一个列表
 

五、Set
 　　Set命令速查

命令	说明
SADD	将一个或多个 member 元素加入到集合 key 当中，已经存在于集合的 member 元素将被忽略
SCARD	返回集合 key 的集合中元素的数量
SDIFF	返回一个集合的全部成员，该集合是所有给定集合之间的差集
SDIFFSTORE	这个命令的作用和 SDIFF 类似，但它将结果保存到新集合，而不是简单地返回结果集
SINTER	返回一个集合的全部成员，该集合是所有给定集合的交集
SINTERSTORE	与SINTER类似，不过可以指定保存到新集合
SISMEMBER	判断 member 元素是否集合 key 的成员
SMEMBERS	返回集合 key 中的所有成员
SMOVE	将 member 元素从一个集合移动到另一个集合
SPOP	移除并返回集合中的一个随机元素
SRANDMEMBER	仅仅返回随机元素，而不对集合进行任何改动，与SPOP的区别在于不移除
SREM	移除集合 key 中的一个或多个 member 元素，不存在的 member 元素会被忽略
SUNION	返回一个集合的全部成员，该集合是所有给定集合的并集
SUNIONSTORE	与SUNION类似，不过可以指定保存到新集合
SSCAN	增量迭代
 

六、SortedSet
 　　SortedSet命令速查：

命令	说明
ZADD	将一个或多个 member 元素及其 score 值加入到有序集 key 当中
ZCARD	返回有序集 key 的基数
ZCOUNT	返回有序集 key 中， score 值在 min 和 max 之间(包括 score 值等于 min 或 max )的成员的数量
ZINCRBY	为有序集 key 的成员 member 的 score 值加上指定增量
ZRANGE	返回有序集 key 中，指定区间内的成员(小到大排列)
ZRANGEBYSCORE	返回有序集 key 中，所有 score 值介于 min 和 max 之间(包括等于 min 或 max )的成员
ZRANK	返回有序集 key 中成员 member 的排名。其中有序集成员按 score 值递增(从小到大)顺序排列
ZREM	移除有序集 key 中的一个或多个成员，不存在的成员将被忽略
ZREMRANGEBYRANK	移除有序集 key 中，指定排名(rank)区间内的所有成员
ZREMRANGEBYSCORE	移除有序集 key 中，所有 score 值介于 min 和 max 之间(包括等于 min 或 max )的成员
ZREVRANGE	返回有序集 key 中，指定区间内的成员，成员位置按score大到小排列
ZREVRANGEBYSCORE	返回有序集 key 中， score 值介于 max 和 min 之间(默认包括等于 max 或 min )的所有的成员。成员按 score 值递减(从大到小)排列
ZREVRANK	返回有序集 key 中成员 member 的排名。其中有序集成员按 score 值递减(从大到小)排序
ZSCORE	返回有序集 key 中，成员 member 的 score 值
ZUNIONSTORE	计算给定的一个或多个有序集的并集，其中给定 key 的数量必须以 numkeys 参数指定，并将该并集(结果集)储存到新集合
ZINTERSTORE	计算给定的一个或多个有序集的交集，其中给定 key 的数量必须以 numkeys 参数指定，并将该交集(结果集)储存到新集合
ZSCAN	增量迭代
 

七、Pub/Sub
　　Pub/Sub命令速查：

命令	说明
PSUBSCRIBE	订阅一个或多个符合给定模式的频道
PUBLISH	将信息 message 发送到指定的频道
PUBSUB	PUBSUB 是一个查看订阅与发布系统状态的内省命令
PUNSUBSCRIBE	指示客户端退订所有给定模式
SUBSCRIBE	订阅给定的一个或多个频道的信息
UNSUBSCRIBE	指示客户端退订给定的频道
 

八、Transaction
　　Transaction命令速查：

命令	说明
DISCARD	取消事务，放弃执行事务块内的所有命令
EXEC	执行所有事务块内的命令
MULTI	标记一个事务块的开始
UNWATCH	取消 WATCH 命令对所有 key 的监视
WATCH	监视一个(或多个) key ，如果在事务执行之前这个(或这些) key 被其他命令所改动，那么事务将被打断
 

九、Script
　　script命令速查：

命令	说明
EVAL	通过内置的 Lua 解释器，可以使用 EVAL 命令对 Lua 脚本进行求值
EVALSHA	根据给定的 sha1 校验码，对缓存在服务器中的脚本进行求值
SCRIPT EXISTS	给定一个或多个脚本的 SHA1 校验和，返回一个包含 0 和 1 的列表，表示校验和所指定的脚本是否已经被保存在缓存当中
SCRIPT FLUSH	清除所有 Lua 脚本缓存
SCRIPT KILL	停止当前正在运行的 Lua 脚本，当且仅当这个脚本没有执行过任何写操作时，这个命令才生效。这个命令主要用于终止运行时间过长的脚本
SCRIPT LOAD	将脚本 script 添加到脚本缓存中，但并不立即执行这个脚本
 

十、Connection
 　　connection命令速查:

命令	说明
AUTH	通过设置配置文件中 requirepass 项的值，可以使用密码来保护 Redis 服务器
ECHO	打印一个特定的信息 message ，测试时使用。
PING	使用客户端向 Redis 服务器发送一个 PING ，如果服务器运作正常的话，会返回一个 PONG，通常用于测试与服务器的连接是否仍然生效，或者用于测量延迟值
QUIT	请求服务器关闭与当前客户端的连接
SELECT	切换到指定的数据库，数据库索引号 index 用数字值指定，以 0 作为起始索引值
十一、Server
　　server命令速查：

命令	说明
BGREWRITEAOF	执行一个 AOF文件 重写操作。重写会创建一个当前 AOF 文件的体积优化版本。
BGSAVE	在后台异步(Asynchronously)保存当前数据库的数据到磁盘
CLIENT GETNAME	返回 CLIENT SETNAME 命令为连接设置的名字
CLIENT KILL	关闭地址为 ip:port 的客户端
CLIENT LIST	以人类可读的格式，返回所有连接到服务器的客户端信息和统计数据
CLIENT SETNAME	为当前连接分配一个名字
CONFIG GET	CONFIG GET 命令用于取得运行中的 Redis 服务器的配置参数
CONFIG RESETSTAT	重置 INFO 命令中的某些统计数据
CONFIG REWRITE	CONFIG REWRITE 命令对启动 Redis 服务器时所指定的 redis.conf 文件进行改写
CONFIG SET	CONFIG SET 命令可以动态地调整 Redis 服务器的配置而无须重启
DBSIZE	返回当前数据库的 key 的数量
DEBUG OBJECT	DEBUG OBJECT 是一个调试命令，它不应被客户端所使用
DEBUG SEGFAULT	执行一个不合法的内存访问从而让 Redis 崩溃，仅在开发时用于 BUG 模拟
FLUSHALL	清空整个 Redis 服务器的数据(删除所有数据库的所有 key )
FLUSHDB	清空当前数据库中的所有 key
INFO	返回关于 Redis 服务器的各种信息和统计数值
LASTSAVE	返回最近一次 Redis 成功将数据保存到磁盘上的时间，以 UNIX 时间戳格式表示
MONITOR	实时打印出 Redis 服务器接收到的命令，调试用
PSYNC	用于复制功能的内部命令
SAVE	
SAVE 命令执行一个同步保存操作，将当前 Redis 实例的所有数据快照(snapshot)以 RDB 文件的形式保存到硬盘。
一般来说，在生产环境很少执行 SAVE 操作，因为它会阻塞所有客户端，保存数据库的任务通常由 BGSAVE 命令异步地执行。然而，如果负责保存数据的后台子进程不幸出现问题时， SAVE 可以作为保存数据的最后手段来使用。

SHUTDOWN	
SHUTDOWN 命令执行以下操作：

停止所有客户端
如果有至少一个保存点在等待，执行 SAVE 命令
如果 AOF 选项被打开，更新 AOF 文件
关闭 redis 服务器(server)

SLAVEOF	SLAVEOF 命令用于在 Redis 运行时动态地修改复制(replication)功能的行为
SLOWLOG	Slow log 是 Redis 用来记录查询执行时间的日志系统
SYNC	用于复制功能的内部命令
TIME	返回当前服务器时间


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
#返回当前key的值的类型
type key
#获取指定key值的长度
strlen key

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
