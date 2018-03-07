#参考博客
http://blog.csdn.net/toontong/article/details/25730829
https://stackoverflow.com/questions/25239650/python-requests-speed-up-using-keep-alive
http://xiaorui.cc/2017/04/03/%E6%9E%84%E5%BB%BA%E9%AB%98%E6%95%88%E7%9A%84python-requests%E9%95%BF%E8%BF%9E%E6%8E%A5%E6%B1%A0/


#python-requests 必需如下使用才能保持keep-alive

import requests

session = requests.session()
session.get('http://www.qq.com')
session.get('http://www.qq.com')

#输出如下
>>INFO:requests.packages.urllib3.connectionpool:Starting new HTTP connection (1): www.qq.com
>>DEBUG:requests.packages.urllib3.connectionpool:"GET / HTTP/1.1" 200 None
>>DEBUG:requests.packages.urllib3.connectionpool:"GET / HTTP/1.1" 200 None
其官网提供的调试的方法是会产生新连接的，可以通过以下方法设置log为debug看到：

logging.BASIC_FORMAT = '%%(levelname)s - %(filename)s[%(lineno)d]- %(message)s'
logging.basicConfig() # you need to initialize logging, otherwise you will not see anything from requests
requests_log = logging.getLogger("requests.packages.urllib3")
requests_log.setLevel(logging.DEBUG)
requests_log.propagate = True

# 第一次调用，log会输出创建一个新连接并放进连接池
requests.get('http://www.qq.com')

# 第二次调用，log依然输出创建一个新连接并放进连接池
requests.get('http://www.qq.com')


#输出如下：
>>INFO:requests.packages.urllib3.connectionpool:Starting new HTTP connection (1): www.qq.com
>>DEBUG:requests.packages.urllib3.connectionpool:"GET / HTTP/1.1" 200 None
>>INFO:requests.packages.urllib3.connectionpool:Starting new HTTP connection (1): www.qq.com
>>DEBUG:requests.packages.urllib3.connectionpool:"GET / HTTP/1.1" 200 None


#持久连接keep-alive
requests的keep-alive是基于urllib3，同一会话内的持久连接完全是自动的。同一会话内的所有请求都会自动使用恰当的连接。
也就是说，你无需任何设置，requests会自动实现keep-alive。
当前的requests版本是urllib3的封装，urllib3默认是不开启keepalive长连接的? 
#上面两句哪个是真的？
requests session是可以保持长连接的，但他能保持多少个长连接？ 10个长连接！  session内置一个连接池，requests库默认值为10个长连接。requests.adapters.HTTPAdapter(pool_connections=100, pool_maxsize=100)   
一般来说，单个session保持10个长连接是绝对够用了，但如果你是那种social爬虫呢？这么多域名只共用10个长连接肯定不够的。 
Python requests连接池是借用urllib3.poolmanager来实现的。每一个独立的(scheme, host, port)元祖使用同一个Connection, (scheme, host, port)是从请求的URL中解析分拆出来的。
from .packages.urllib3.poolmanager import PoolManager, proxy_from_url 。

Keep-Alive工作原理

与HTTP1.0需要主动声明不同的是，HTTP1.1默认支持这一特性，两者的交互流程如下：

HTTP1.0 Keep-Alive的数据交互流程:
建立tcp连接
Client 发出request，并声明HTTP版本为1.0，且包含header:"Connection： keep-alive"。
Server收到request，通过HTTP版本1.0和"Connection： keep-alive"，判断连接为长连接；故Server在response的header中也增加"Connection： keep-alive"。
同时，Server不释放tcp连接，在Client收到response后，认定为长连接，同样也不释放tcp连接。这样就实现了会话的保持。
直到会话保持的时间超过keepaliveTime时，client和server端将主动释放tcp连接。

HTTP1.1 Keep-Alive的数据交互流程:
建立tcp连接

Client 发出request，并声明HTTP版本为1.1。
Server收到request后，通过HTTP版本1.1就认定连接为长连接；此时Server在response的header中增加"Connection： keep-alive"。
Server不释放tcp连接，在Client收到response后，通过"Connection： keep-alive"判断连接为长连接，同样也不释放tcp连接。
这个过程与http1.0类似，仅是http1.1时，客户端的request不用声明"Connection： keep-alive"。


如何查询httpd进程占用的内存
pidof httpd
top -p 60257或者
cat /proc/60257/status

