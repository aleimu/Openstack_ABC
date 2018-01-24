#python redis使用
1.安装
pip install redis
 
2.基本使用
import redis
r = redis.Redis(host='localhost', port=6379, db=0)
r['test'] = 'test'#或者可以r.set('test', 'test') 设置key
r.get('test')   #获取test的值
r.delete('test')#删除这个key
r.flushdb()     #清空数据库
r.keys()        #列出所有key
r.exists('test')#检测这个key是否存在
r.dbsize()      #数据库中多少个条数
 
>>> import redis
>>> pool = redis.ConnectionPool(host='localhost', port=6379, db=0)
>>> r = redis.StrictRedis(connection_pool = pool)
>>> r.set('foo', 'bar')
True
>>> r.get('foo')
'bar'

Redis有默认16个数据库，默认在0库，可以切换(eg:切换到15号数据库: select 15)；但在python中，出于安全考虑，在python的API没有切换数据库的概念，可以在连接调用时指定调用的数据库，但一连接上了就不能切换了。
move(name, db))# 将redis的某个值移动到指定的db下

3.API参考
Redis 官方文档详细解释了每个命令（http://redis.io/commands）。redis-py 提供了两个实现这些命令的客户端类。StrictRedis 类试图遵守官方的命令语法,但也有几点例外:
  SELECT:没有实现。参见下面'线程安全'部分的解释。
  DEL:'del' 是 Python 语法的保留关键字。因此redis-py 使用 'delete' 代替。
  CONFIG GET|SET:分别用 config_get 和 config_set 实现。
  MULTI/EXEC:作为 Pipeline 类的一部分来实现。若在调用pipeline 方法时指定use_transaction=True,在执行 pipeline 时会用 MULTI 和 EXEC 封装 pipeline 的操作。参见下面 Pipeline 部分。
  SUBSCRIBE/LISTEN: 和 pipeline 类似,由于需要下层的连接保持状态, PubSub 也实现成单独的类。调用 Redis 客户端的 pubsub 方法返回一个 PubSub 的实例,通过这个实例可以订阅频道或侦听消息。两个类（StrictRedis 和 PubSub 类）都可以发布(PUBLISH)消息。
除了上面的改变,StrictRedis 的子类 Redis,提供了对旧版本 redis-py 的兼容:
  LREM:参数 'num' 和 'value' 的顺序交换了一下,这样'num' 可以提供缺省值 0.
  ZADD:实现时 score 和 value 的顺序不小心弄反了,后来有人用了,就这样了
  SETEX: time 和 value 的顺序反了
注:最好不要用 Redis,这个类只是做兼容用的
 
4.详细说明
4.1 连接池
redis-py使用connection pool来管理对一个redis server的所有连接，避免每次建立、释放连接的开销。默认，每个Redis实例都会维护一个自己的连接池。可以直接建立一个连接池，然后作为参数Redis，这样就可以实现多个Redis实例共享一个连接池。
import redis
pool = redis.ConnectionPool(host='192.168.0.110', port=6379)
r = redis.Redis(connection_pool=pool)
r.set('name', 'zhangsan')   #添加
print (r.get('name'))   #获取
　　
4.2 管道
redis-py默认在执行每次请求都会创建（连接池申请连接）和断开（归还连接池）一次连接操作，如果想要在一次请求中指定多个命令，则可以使用pipline实现一次请求指定多个命令，并且默认情况下一次pipline 是原子性操作。
另外,pipeline 也可以保证缓冲的命令组做为一个原子操作。缺省就是这种模式。要使用命令缓冲,但禁止pipeline 的原子操作属性,可以关掉 transaction:
>>> pipe = r.pipeline(transaction=False)
import redis
pool = redis.ConnectionPool(host='192.168.0.110', port=6379)
r = redis.Redis(connection_pool=pool)
pipe = r.pipeline(transaction=True)
r.set('name', 'zhangsan')
r.set('name', 'lisi')
pipe.execute()

# 使用管道与不使用的对比
import redis
import time
from concurrent.futures import ProcessPoolExecutor

r = redis.Redis(host='127.0.0.1', port=6379, password='bigdata123')
def try_pipeline():
    start = time.time()
    with r.pipeline(transaction=False) as p:
        p.sadd('seta', 1).sadd('seta', 2).srem('seta', 2).lpush('lista', 1).lrange('lista', 0, -1)
        p.execute()
    print time.time() - start

def without_pipeline():
    start = time.time()
    r.sadd('seta', 1)
    r.sadd('seta', 2)
    r.srem('seta', 2)
    r.lpush('lista', 1)
    r.lrange('lista', 0, -1)
    print time.time() - start

def worker():
    while True:
        try_pipeline()

with ProcessPoolExecutor(max_workers=12) as pool:
    for _ in range(10):
        pool.submit(worker)
　
4.3 分析器
分析类提供了控制如何对 Redis 服务器的响应进行分析的途径。redis-py 提供了两个分析类, PythonParser和 HiredisParser。缺省情况下,如果安装了 hiredis 模块, redis-py 会尝试使用 HiredisParser,否则使用 PythonParser。
Hiredis 是由 Redis 核心团队维护的 C 库。 Pieter Noordhuis 创建了 Python 的实现。分析 Redis 服务器的响应时,Hiredis 可以提供 10 倍的速度提升。性能提升在获取大量数据时优为明显,比如 LRANGE 和SMEMBERS 操作。
和 redis-py 一样,Hiredis 在 Pypi 中就有,可以通过 pip 或 easy_install 安装:
pip install hiredis
或:
easy_install hiredis

4.4 响应回调函数
客户端类使用一系列回调函数来把 Redis 响应转换成合适的 Python 类型。有些回调函数在 Redis 客户端类的字典 RESPONSE_CALLBACKS 中定义。
通过 set_response_callback 方法可以把自定义的回调函数添加到单个实例。这个方法接受两个参数:一个命令名和一个回调函数。通过这种方法添加的回调函数只对添加到的对象有效。要想全局定义或重载一个回调函数,应该创建 Redis 客户端的子类并把回调函数添加到类的 RESPONSE_CALLBACKS(原文误为REDIS_CALLBACKS) 中。
响应回调函数至少有一个参数:Redis 服务器的响应。要进一步控制如何解释响应,也可以使用关键字参数。这些关键字参数在对 execute_command 的命令调用时指定。通过 'withscores' 参数,ZRANGE 演示了回调函数如何使用关键字参数。
4.5 线程安全
Redis 客户端实例可以安全地在线程间共享。从内部实现来说,只有在命令执行时才获取连接实例,完成后直接返回连接池,命令永不修改客户端实例的状态。
但是,有一点需要注意:SELECT 命令。SELECT 命令允许切换当前连接使用的数据库。新的数据库保持被选中状态,直到选中另一个数据库或连接关闭。这会导致在返回连接池时,连接可能指定了别的数据库。
因此,redis-py 没有在客户端实例中实现 SELECT 命令。如果要在同一个应用中使用多个 Redis 数据库,应该给第一个数据库创建独立的客户端实例（可能也需要独立的连接池）。
在线程间传递 PubSub 和 Pipeline 对象是不安全的。

#WATCH命令
WATCH命令可以监控一个或多个键，一旦其中有一个键被修改（或删除），之后的事务就不会执行会被取消并抛出 WatchError 异常。监控一直持续到EXEC命令（事务中的命令是在EXEC之后才执行的，所以在MULTI命令后可以修改WATCH监控的键值）

with r.pipeline() as pipe:
    while 1:
        try:
            # 对序列号的键进行 WATCH
            pipe.watch('OUR-SEQUENCE-KEY')
            # WATCH 执行后,pipeline 被设置成立即执行模式直到我们通知它
            # 重新开始缓冲命令。
            # 这就允许我们获取序列号的值
            current_value = pipe.get('OUR-SEQUENCE-KEY')
            next_value = unicode(int(current_value) + 1)
            # 现在我们可以用 MULTI 命令把 pipeline 设置成缓冲模式
            pipe.multi()
            pipe.set('OUR-SEQUENCE-KEY', next_value)
            # 最后,执行 pipeline (set 命令)
            pipe.execute()
            # 如果执行时没有抛出 WatchError,我们刚才所做的确实'原子地'
            # 完成了
            break
        except WatchError:
            # 一定是其它客户端在我们开始 WATCH 和执行 pipeline 之间修改了
            # 'OUR-SEQUENCE-KEY',我们最好的选择是重试
            continue
　　
注意,因为在整个 WATCH 过程中,Pipeline 必须绑定到一个连接,必须调用 reset() 方法确保连接返回连接池。如果 Pipeline 用作 Context Manager(如上面的例子所示), reset() 会自动调用。当然,也可以用手动的方式明确调用 reset():
pipe = r.pipeline()
while 1:
    try:
        pipe.watch('OUR-SEQUENCE-KEY')
        current_value = pipe.get('OUR-SEQUENCE-KEY')
        next_value = unicode(int(current_value) + 1)
        pipe.multi()
        pipe.set('OUR-SEQUENCE-KEY', next_value)
        pipe.execute()
        break
    except WatchError:
        continue
    finally:
        pipe.reset()

#重点:
  WATCH 执行后,pipeline 被设置成立即执行模式
  用 MULTI 命令把 pipeline 设置成缓冲模式
  要么使用 with,要么显式调用 reset()
有一个简便的名为'transaction'的方法来处理这种处理和在 WatchError 重试的模式。它的参数是一个可执行对象和要 WATCH 任意个数的键,其中可执行对象接受一个 pipeline 对象做为参数。上面的客户端 INCR 命令可以重写如下（更可读）:
def client_side_incr(pipe):
    current_value = pipe.get('OUR-SEQUENCE-KEY')
    next_value = unicode(int(current_value) + 1)
    pipe.multi()
    pipe.set('OUR-SEQUENCE-KEY', next_value)

r.transaction(client_side_incr, 'OUR-SEQUENCE-KEY')


# setbit的应用场景
{
setbit的应用场景，想想什么情况下会用到这个功能呢？超大型的应用平台，比如新浪微博，我想查看当前正在登陆的用户，如何实现？当然你会想到，用户登陆后在数据库上的用户信息上做个标记，然后count去统计做标记的用户一共有多少，so，当前用户查看迎刃而解；OK，好好，首先每个用户登录都要设置标记，如果当前用户几个亿，那么得存几个亿的标记位，超级占用库的开销；现在就有一个无敌高效的办法，利用二进制位统计当前在线用户
import redis
#建立连接
pool = redis.ConnectionPool(host='127.0.0.1', port=6379)
r = redis.Redis(connection_pool=pool)

r.setbit("uv_count1", 5, 1)  #每来一个连接，则让字节位设为１
r.setbit("uv_count1", 8, 1)
r.setbit("uv_count1", 3, 1)
r.setbit("uv_count1", 3, 1)  #重复的不计算
print("uv_count:", r.bitcount("uv_count1"))

输出:uv_count: 3
比如:当前第500位用户在线，则将第500个bit置为1(默认为0)。bitcount统计二级制位中1的个数，setbit和bitcount配合使用，轻松解决当前在线用户数的问题。1字节=8位，那么10m=8000万位，即一个亿的在线用户也就10m多的内存就可搞定
}

#redis发布与订阅 dome
{
# redis_helper.py文件(公共类)
#!/usr/bin/env python
# -*-coding:utf-8-*-
import redis

class RedisHelper(object):

    def __init__(self):
        self.__conn=redis.Redis(host='127.0.0.1')
        self.chan_sub='fm88.7'          #设置两个频道，订阅频道
        self.chan_pub='fm88.7'          #发布频道
    
    def public(self,msg):
        self.__conn.publish(self.chan_pub,msg)        #发布消息
        return True
    
    def subscribe(self):
        pub=self.__conn.pubsub()        #生成实例　打开收音机
        pub.subscribe(self.chan_sub)    #拧到那个台
        m=pub.parse_response()          #准备听,未阻塞，再调用一次就阻塞
        print(m)                        #[b'subscribe', b'fm88.7', 1]
        return pub                      #返回实例

#redis_sub.py
from redis_helper import RedisHelper

obj=RedisHelper()
redis_sub=obj.subscribe()               #返回实例

while True:
    msg=redis_sub.parse_response()      #听
    print(msg)                          #有消息则打印，无消息则阻塞

#redis_pub.py
from redis_helper import RedisHelper

obj=RedisHelper()
return1=obj.public('love')
print(return1)

}
