#Python 之ConfigParser
ConfigParser 是用来读取配置文件的包。配置文件的格式如下：中括号“[ ]”内包含的为section。section 下面为类似于key-value 的配置内容。

[db]
db_host = 127.0.0.1
db_port = 22
db_user = root
db_pass = rootroot

[concurrent]
thread = 10
processor = 20
二、ConfigParser 初始工作

使用ConfigParser 首选需要初始化实例，并读取配置文件：

cf = ConfigParser.ConfigParser()
cf.read("配置文件名")
三、ConfigParser 常用方法

1. 获取所有sections。也就是将配置文件中所有“[ ]”读取到列表中：

s = cf.sections()
print 'section:', s
将输出（以下将均以简介中配置文件为例）：

section: ['db', 'concurrent']
2. 获取指定section 的options。即将配置文件某个section 内key 读取到列表中：

o = cf.options("db")
print 'options:', o
将输出：

options: ['db_host', 'db_port', 'db_user', 'db_pass']
3. 获取指定section 的配置信息。

v = cf.items("db")
print 'db:', v
将输出：

db: [('db_host', '127.0.0.1'), ('db_port', '22'), ('db_user', 'root'), ('db_pass', 'rootroot')]
4. 按照类型读取指定section 的option 信息。

同样的还有getfloat、getboolean。

#可以按照类型读取出来
db_host = cf.get("db", "db_host")
db_port = cf.getint("db", "db_port")
db_user = cf.get("db", "db_user")
db_pass = cf.get("db", "db_pass")

# 返回的是整型的
threads = cf.getint("concurrent", "thread")
processors = cf.getint("concurrent", "processor")

print "db_host:", db_host
print "db_port:", db_port
print "db_user:", db_user
print "db_pass:", db_pass
print "thread:", threads
print "processor:", processors
将输出：

db_host: 127.0.0.1
db_port: 22
db_user: root
db_pass: rootroot
thread: 10
processor: 20
5. 设置某个option 的值。（记得最后要写回）

cf.set("db", "db_pass", "zhaowei")
cf.write(open("test.conf", "w"))
6.添加一个section。（同样要写回）

cf.add_section('liuqing')
cf.set('liuqing', 'int', '15')
cf.set('liuqing', 'bool', 'true')
cf.set('liuqing', 'float', '3.1415')
cf.set('liuqing', 'baz', 'fun')
cf.set('liuqing', 'bar', 'Python')
cf.set('liuqing', 'foo', '%(bar)s is %(baz)s!')
cf.write(open("test.conf", "w"))
7. 移除section 或者option 。（只要进行了修改就要写回的哦）

cf.remove_option('liuqing','int')
cf.remove_section('liuqing')
cf.write(open("test.conf", "w"))


8. 一个复杂的例子
#读取配置，有时候是字符串形式的，但不方便处理，可以eval转化成字典来操作，这样就不用管那么多转义字符
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
