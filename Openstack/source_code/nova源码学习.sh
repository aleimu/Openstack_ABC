#OpenStack源码学习

Nova的软件架构，每个nova-xxx组件是由python代码编写的守护进程，每个进程之间通过队列（Queue）和数据库（nova database）来交换信息，执行各种请求。而用户通过nova-api暴露的web service来同其他组件进行进行交互。Glance是相对独立的基础架构，nova通过glance-api来和它交互。

AMQP 即Advanced Message Queuing Protocol，高级消息队列协议
（1）	面向消息、队列、路由（包括点对点和发布/订阅）、可靠性、安全。
（2）	AMQP在消息提供者和客户端的行为进行了强制规定，使得不同卖商之间真正实现了互操作能力。
（3）	AMQP是一个协议，而RabbitMQ是对这个协议的一个实现。

#nova-api 配置文件
E:\New_openstack\git工程\nova-master\etc\nova\api-paste.ini

#并发与异步 eventlet库
{
https://github.com/eventlet/eventlet  #Eventlet是Python的并发网络库
http://www.cnblogs.com/yasmi/articles/4953910.html

eventlet是对greenlet的封装
greenlet需要程序员显式的写代码在不同的协程之间切换

from greenlet import greenlet

def test1():
    print (12)
    gr2.switch()
    print (34)

def test2():
    print (56)
    gr1.switch()
    print (78)

gr1 = greenlet(test1)
gr2 = greenlet(test2)
gr1.switch()
#gr2.switch()

"""
定义两个协程，最后一行g1.switch()跳转到 test1() ，它打印12，然后跳转到 test2() ，打印56，
然后跳转回 test1() ，打印34，然后 test1() 就结束，gr1死掉，回到父greenlet，不会再切换到test2，
所以不会打印78。在上面的例子中main greenlet就是它们的父greenlet。

每一个greenlet有一个父greenlet，相应父greenlet在greenlet被创建时初始化。greenlet死亡后，父greenlet继续执行。
greenlet树形组织，隐含的main greenlet为此树根节点。任何一个greenlet死亡，执行顺序将被回溯至main greenlet。异常发生将传播至parent greenlet。
switch不是调用，只是在并行的'stack containers'中传输执行。

"""


http://www.cnblogs.com/qiyukun/p/4754077.html

eventlet是一个用来处理和网络相关的python库函数，且可以通过协程（coroutines）实现并发。在eventlet里，将协程叫做greenthread(绿色线程)，所谓并发，即开启多个greenthread，并对这些greenthread进行管理。尤为方便的是，eventlet为了实现“绿色线程”，竟然对python的和网络相关的几个标准库函数进行了改写，并且可以以补丁（patch）的方式导入到程序中，因为python的库函数只支持普通的线程，而不支持协程，eventlet称之为“绿化”。
eventlet主要基于两个库——greenlet（过程化其并发基础，简单封装后即成为GreenTread）和select.epoll（默认网络通信模型）。

Greenlet能够和Python线程结合，每个python线程中包含一个独立的main greenlet及由其子greenlet构成的树。但不属于同一个线程的不同greenlet之间不能结合或切换。


backdoor{
http://www.cnblogs.com/Security-Darren/p/4172717.html
#Python——eventlet.backdoor
#eventlet.backdoor 是正在运行中的进程内的 Pyhon 交互解释器。
#该模块便于检测一个长期运行进程的运行状态，提供了一种可以不阻塞应用正常操作的 Pyhon 交互解释器，从而极大地方便了调试、性能调优或仅仅是了解事情是怎么运转的。

from eventlet import backdoor
import eventlet
 
def _funca():
    print "abc"
    return "123"
 
backdoor_locals = {'funca': _funca}
 
eventlet.spawn(backdoor.backdoor_server, eventlet.listen(('localhost', 3000)),locals=backdoor_locals)
 
while True:
    print "aaa"
    eventlet.sleep(1)
#当这个程序运行后，我在另一个终端上执行下面的命令就可以看到对应的结果：
[root@COMPUTE02 ~]# telnet 127.0.0.1 3000
Trying 127.0.0.1...
Connected to 127.0.0.1.
Escape character is '^]'.
Python 2.6.6 (r266:84292, Sep  4 2013, 07:46:00) 
[GCC 4.4.7 20120313 (Red Hat 4.4.7-3)] on linux2
Type "help", "copyright", "credits" or "license" for more information.
(InteractiveConsole)
>>> funca()
abc
'123'
>>> 
可以看到，print或return都会的把输出返回到telnet的client端。
}

}

# paste库
{
谈到WSGI，就免不了要了解paste，其中paste deploy是用来发现和配置WSGI应用的一套系统，对于WSGI应用的使用者而言，可以方便地从配置文件汇总加载WSGI应用（loadapp）；对于WSGI应用的开发人员而言，只需要给自己的应用提供一套简单的入口点即可。

http://blog.csdn.net/u011521019/article/details/50891330
http://www.cnblogs.com/Security-Darren/p/4087587.html
http://www.cnblogs.com/zmlctt/p/4208919.html
http://www.cnblogs.com/jmilkfan-fanguiju/p/7532332.html
http://blog.csdn.net/li_101357/article/details/52755367

paste的配置文件中有下面几项是比较常见的：
filter:
如：
[filter:s3_extension]
paste.filter_factory = keystone.contrib.s3:S3Extension.factory
 
app:
如：
[app:service_v3]
paste.app_factory = keystone.service:v3_app_factory
 
pipeline：
如：
[pipeline:public_api]
pipeline = sizelimit url_normalize build_auth_context token_auth admin_token_auth xml_body json_body ec2_extension user_crud_extension public_service
 
composite：
如：
[composite:main]
use = egg:Paste#urlmap
/v2.0 = public_api
/v3 = api_v3
/ = public_version_api

Request 被 paste.ini 处理的流程
WSGI Server(Web Server) 接受到 URL_Path 形式的 HTTP Request 时，这些 Request 首先会被 Paste 模块按照配置文件 paste.ini 进行处理。

app(应用程序)：WSGI服务的核心部分，用于实现WSGI服务的主要逻辑
app是一个callable object，接受的参数(environ,start_response)，这是paste系统交给application的，符合 WSGI规范的参数. app需要完成的任务是响应envrion中的请求，准备好响应头和消息体，然后交给start_response 处理，并返回响应消息体。
filter(过滤器)：一般用于一些准备性的工作，例如验证用户身份、准备服务器环境等。在一个filter执行完之后，可以直接返回，也可以交给下一个filter或者app继续执行。
filter是一个callable object，其唯一参数是(app)，这是WSGI的application对象，filter需要完成的工作是将application包装成另一个application（“过滤”），并返回这个包装后的application。
pipeline(管道)：由若干个filter和1个app组成。通过pipeline，可以很容易定制WSGI服务
composite(复合体)：用于实现复杂的应用程序，可以进行分支选择。例如：根据不同的URL调用不同的处理程序。

处理的过程为： 
1. composite(将Request将URL_Path的前缀(/v2.0 /v3 /)和一个Application(app/filter)进行映射。然后将Request转发到pipeline或app中，最终会到达指定的 Application) 
2. ==> pipeline(包含了filter和app) 
3. ==> filter(调用Middleware对Request进行过滤) 
4. ==> app(具体的Application来实现Request的操作)。
这个过程就是将 Application 和 Middleware 串起来的过程，不一定要按照顺序执行，只要能到达 Application 即可。
由配置文件可以很容易找到各个组件的代码位置，如neutron.api.v2.router代表 neutron/api/v2/router

# Keystone Request URL 为 http://homename:35357/v3/auth/tokens
Step1. （hostname:35357）： 这一部分由 Web Server 来获取并处理的(EG.虚拟机功能)。
Step2. （/v3/auth/tokens）: 根据 paste.ini 中的配置来对剩下的 URL（/v3/auth/tokens）部分进行处理。首先请求的 Post=35357 决定了会经过 [composite:admin] section 。（一般是admin监听35357端口，main监听5000端口；也可以由 application = wsgi_server.initialize_application(name) 中 name 参数来决定）
Step3. （/v3）: composite section 会根据 /v3 这个 URL 前缀来决定将 Request 路由到哪一个 pipeline secion，这里就把请求转发给 [pipeline:api_v3] 处理，转发之前，会把 /v3 这个部分的 URL 去掉。
Step4. （/auth/tokens） : [pipeline:api_v3] 收到请求，URL_Path是 （/auth/tokens），然后开始调用各个 filter(中间件) 来处理请求。最后会把请求交给 [app:service_v3] 进行处理。
Step5. （/auth/tokens）: [app:service_v3] 收到请求，URL_Path是 (/auth/tokens)，最后交由的 WSGI Application:keystone.service:v3_app_factory 去处理。
注意：剩下的URL后缀 /auth/tokens 则交由另一个模块 Routers 来处理，这个以后再介绍。


Paste#urlmap 表示默认使用Paste.urlmap。
use = egg:Paste#urlmap 意味着直接使用来自于Paste包的urlmap的composite应用。 
urlmap是特别常见的composite应用；它使用路径前缀来映射将你的请求与其他应用对应起来。基本含义就是说，这是Paste已经提供好的一个composite，如果你想自定义就需要另外写一个composite_factory了。


[composite:blog]
use=egg:Paste # urlmap 表示我们将使用Pasteegg包中urlmap来实现composite，这一个段(urlmap)可以算是一个通用的composite程序了。
/:portal  # 根据web请求的path的前缀进行一个到应用的映射(map)
/admin:admin

[pipeline:admin] # 指明一串app的传递链，由一些filter、app组成，最后一个是应用，即将前面的fiiter应用到app。
pipeline = logrequest adminWeb

# App
# - app是一个callable object，接受的参数(environ,start_response)，这是paste系统交给application的，符合
# WSGI规范的参数. app需要完成的任务是响应envrion中的请求，准备好响应头和消息体，然后交给start_response处理，并返回响应消息体。
[app:portal]
version = 1.0.0 #参数
description = This is an blog portal. #参数
paste.app_factory = pastedeploylab:Portal.factory

[app:adminWeb]
version = 1.0.0 # 参数
description = This is an blog admin. #参数
paste.app_factory = pastedeploylab:AdminWeb.factory

# - app_factory是一个callable object，其接受的参数是一些关于application的配置信息：(global_conf,**kwargs)，
# global_conf是在ini文件中default section中定义的一系列key-value对，而**kwargs，即一些本地配置，是在ini文件中，
# app:xxx section中定义的一系列key-value对。app_factory返回值是一个application对象


# Filter
# - filter是一个callable object，其唯一参数是(app)，这是WSGI的application对象，
# filter需要完成的工作是将application包装成另一个application（“过滤”），并返回这个包装后的application。

[filter:logrequest]
paste.filter_factory = pastedeploylab:LogFilter.factory
# - filter_factory是一个callable object，其接受的参数是一系列关于filter的配置信息：(global_conf,**kwargs)，
# global_conf是在ini文件中default section中定义的一系列key-value对，而**kwargs，即一些本地配置，是在ini文件中，
# filter:xxx section中定义的一系列key-value对。filter_factory返回一个filter对象


}

# 目录的作用如下：
{
API: 处理跟其他模块的接口
CA：证书相关内容
cells: 基础的功能库
cert: 证书
cloudpipe: 用户数据加载ZIP文件，并根据 它启动一个实例
cmd: 命令
common:公共，主要是配置
compute: nova中comptue模块，nova核心模块
conductor: 负责操作数据库，即nova-conductor
conf: 配置模块
console:控制台，horizon中虚拟机的虚拟控制台
consoleauth: 控制台的认证，鉴权
db: 数据库
image: 镜像相关的
ipv6: ipv6
keymgr: 权限管理
locale: 语言
network:网络
notifications: 消息通知
objects: 基础的一些对象
pci: pci相关
policies: 策略
scheduler: nova-scheduler 调度用
servicegroup: 
virt: libvirt相关的
vnc: vnc登陆相关
volume: 磁盘相关
wsgi: wsgi接口
}

# 整理的简要的Nova模块源码结构
{
/bin:Nova各个服务的启动脚本
/nova/api/auth.py:通用身份验证的中间件，访问keystone；
/nova/api/manager.py:Metadata管理初始化；
/nova/api/sizelimit.py:limit中间件的实现；
/nova/api/validator.py:一些参数的验证；
/nova/api/ec2/__init__.py:Amazon EC2 API绑定，路由EC2请求的起点；
/nova/api/ec2/apirequest.py:APIRequest类；
/nova/api/ec2/cloud.py:云控制器：执行EC2 REST API的调用，这个调用是通过AMQP RPC分派到其他节点；
/nova/api/ec2/ec2utils.py:ec2相关的实用程序；
/nova/api/ec2/faults.py:捕获异常并返回REST响应；
/nova/api/ec2/inst_state.py:状态信息的设置；
/nova/api/metadata/__init__.py:Nova元数据服务；
/nova/api/metadata/base.py:实例元数据相关信息；
/nova/api/metadata/handler.py:Metadata请求处理程序；
/nova/api/metadata/password.py:元数据相关的密码处理程序；
/nova/api/openstack/__init__.py:OpenStack API控制器的WSGI中间件；
/nova/api/openstack/auth.py:身份验证；
/nova/api/openstack/common.py:一些通用管理程序；
/nova/api/openstack/extensions.py:模块扩展相关；
/nova/api/openstack/urlmap.py:urlmap相关；
/nova/api/openstack/wsgi.py:wsgi的一些应用；
/nova/api/openstack/xmlutil.py:处理xml的实用程序；
/nova/api/openstack/compute/__init__.py:OpenStack Compute API的WSGI中间件；
/nova/api/openstack/compute/consoles.py:OpenStack Compute API控制台；
/nova/api/openstack/compute/extensions.py：扩展管理；
/nova/api/openstack/compute/flavors.py：OpenStack Compute API的flavors控制器；
/nova/api/openstack/compute/image_metadata.py：OpenStack Compute API的镜像源文件API控制器；
/nova/api/openstack/compute/images.py：用于检索/显示镜像的基本控制器；
/nova/api/openstack/compute/ips.py：OpenStack API的服务IP地址API控制器；
/nova/api/openstack/compute/limits.py：limit中间件相关；
/nova/api/openstack/compute/server_metadata.py：OpenStack API的服务元数据API控制器；
/nova/api/openstack/compute/servers.py：server的模板类以及控制类API实现；
/nova/api/openstack/compute/versions.py：版本相关；
/nova/api/openstack/compute/contrib/__init__.py：
/nova/api/openstack/compute/contrib/admin_actions.py:定义了若干管理员权限运行的管理虚拟机的操作；
/nova/api/openstack/compute/contrib/agents.py:主要实现对代理器的处理；
注：代理主要指的是来宾（guest）的代理。主机可以使用代理来实现在来宾系统（guest）上访问磁盘文件、配置网络以及运行其他程序或脚本。
/nova/api/openstack/compute/contrib/aggregates.py：管理员Aggregate API操作扩展；  
/nova/api/openstack/compute/contrib/attach_interfaces.py：实例接口扩展；（应该看看）
/nova/api/openstack/compute/contrib/availability_zone.py：对可用的zone的处理的API集合；
/nova/api/openstack/compute/contrib/baremetal_nodes.py:裸机节点管理员操作API扩展；
/nova/api/openstack/compute/contrib/cells.py:cell操作扩展API；
/nova/api/openstack/compute/contrib/certificates.py:OpenStack API的x509数字认证操作API；
/nova/api/openstack/compute/contrib/cloudpipe_update.py:为cloudpipe实例处理更新vpn ip/port；
/nova/api/openstack/compute/contrib/cloudpipe.py:通过cloudpipes连接vlan到外网；
/nova/api/openstack/compute/contrib/config_drive.py:配置驱动扩展；
/nova/api/openstack/compute/contrib/console_output.py:控制台输出控制;
/nova/api/openstack/compute/contrib/consoles.py:控制台控制API；
/nova/api/openstack/compute/contrib/coverage_ext.py：Coverage报告API控制器；
/nova/api/openstack/compute/contrib/createserverext.py：扩展建立对服务v1.1 API的支持；
/nova/api/openstack/compute/contrib/deferred_delete.py:延期删除实例扩展；
/nova/api/openstack/compute/contrib/disk_config.py:磁盘配置扩展API；
/nova/api/openstack/compute/contrib/evacuate.py:允许管理员迁移一个服务从失败的主机到一个新的主机；
/nova/api/openstack/compute/contrib/extended_availability_zone.py:可用的zone状态API扩展；
/nova/api/openstack/compute/contrib/extended_ips.py:扩展IP API扩展；
/nova/api/openstack/compute/contrib/extended_server_attributes.py:扩展服务属性API扩展；
/nova/api/openstack/compute/contrib/extended_status.py:扩展实例状态的API；
/nova/api/openstack/compute/contrib/fixed_ips.py:固定IP操作API；
/nova/api/openstack/compute/contrib/flavor_access.py:OpenStack API的flavor访问操作API；
/nova/api/openstack/compute/contrib/flavor_disabled.py:OpenStack API的flavor禁用访问API；
/nova/api/openstack/compute/contrib/flavor_rxtx.py:OpenStack API的flavor Rxtx API；
/nova/api/openstack/compute/contrib/flavor_swap.py:OpenStack API的flavor Swap API扩展；
/nova/api/openstack/compute/contrib/flavorextradata.py:OpenStack API的flavor额外数据扩展；
/nova/api/openstack/compute/contrib/flavorextraspecs.py:实例类型额外规格扩展；
/nova/api/openstack/compute/contrib/flavormanage.py:flavor管理API；
/nova/api/openstack/compute/contrib/floating_ip_dns.py：浮动IP DNS支持；
/nova/api/openstack/compute/contrib/floating_ip_pools.py：浮动IP池；
/nova/api/openstack/compute/contrib/floating_ips_bulk.py：批量浮动IP支持；
/nova/api/openstack/compute/contrib/floating_ips.py：浮动IP控制器；
/nova/api/openstack/compute/contrib/fping.py：Fping控制器的实现；
/nova/api/openstack/compute/contrib/hide_server_addresses.py：特定的状态下隐藏服务地址；
/nova/api/openstack/compute/contrib/hosts.py：主机管理扩展；
/nova/api/openstack/compute/contrib/hypervisors.py：虚拟机管理程序管理的扩展；
/nova/api/openstack/compute/contrib/image_size.py：镜像大小管理；
/nova/api/openstack/compute/contrib/instance_actions.py：对实例操作的管理；
/nova/api/openstack/compute/contrib/instance_usage_audit_log.py：虚拟机实例应用的日志记录控制器；
/nova/api/openstack/compute/contrib/keypairs.py：密钥对API管理扩展；
/nova/api/openstack/compute/contrib/multinic.py：多网络支持扩展；
/nova/api/openstack/compute/contrib/networks_associate.py：Network Association支持；
/nova/api/openstack/compute/contrib/os_networks.py：管理员权限网络管理扩展；
/nova/api/openstack/compute/contrib/os_tenant_networks.py：基于租户的网络管理扩展；
/nova/api/openstack/compute/contrib/quota_classes.py：磁盘配额类管理支持；
/nova/api/openstack/compute/contrib/quotas.py：磁盘配额管理支持；
/nova/api/openstack/compute/contrib/rescue.py：实例救援模式扩展；
/nova/api/openstack/compute/contrib/scheduler_hints.py：传递任意的键值对到调度器；
/nova/api/openstack/compute/contrib/security_group_default_rules.py：安全组默认规则的支持；
/nova/api/openstack/compute/contrib/security_groups.py：安全组的扩展支持；
/nova/api/openstack/compute/contrib/server_diagnostics.py：服务器诊断的支持；
/nova/api/openstack/compute/contrib/server_password.py：server password扩展的支持；
/nova/api/openstack/compute/contrib/server_start_stop.py：虚拟机实例启动和停止的API支持；
/nova/api/openstack/compute/contrib/services.py：对service扩展的支持；
/nova/api/openstack/compute/contrib/simple_tenant_usage.py：简单的租户使用率的扩展；
/nova/api/openstack/compute/contrib/used_limits.py：有限使用资源的数据；
/nova/api/openstack/compute/contrib/virtual_interfaces.py：虚拟接口扩展；
/nova/api/openstack/compute/contrib/volumes.py：卷相关管理的扩展；
/nova/cells/driver.py:cell通讯驱动基类；
/nova/cells/manager.py:cell服务管理API，主要定义了类CellsManager；
/nova/cells/messaging.py:cell通信模块；
/nova/cells/opts.py:cell的全局配置选项；
/nova/cells/rpc_driver.py:cell RPC通信驱动，通过RPC实现cell的通信；
/nova/cells/rpcapi.py:nova-cells RPC客户端API，来实现与nova-cells服务的交流，主要就是Cell RPC API客户端类；
/nova/cells/scheduler.py:cell调度器实现；
/nova/cells/state.py:cell状态管理实现，包括一个CellState类（为一个特定的cell保存信息类）和一个CellStateManager类（cell状态管理类）；
/nova/cells/utils.py:cell的实用方法；
/nova/cert/manager.py:x509数字认证的证书管理，主要包括一个类CertManager（认证管理类）；
/nova/cert/rpcapi.py:认证管理RPC的客户端API；
/nova/cloudpipe/pipelib.py:CloudPipe - 建立一个用户数据加载zip文件，并根据它启动一个实例；
/nova/compute/api.py:处理关于计算资源的所有的请求；
/nova/compute/cells_api.py:通过cell执行的服务操作API；
/nova/compute/instance_actions.py:对一个实例的所有可能的操作；
/nova/compute/instance_types.py:对实例的内置属性的操作；
/nova/compute/manager.py:对实例相关的所有进程的处理（来宾虚拟机）；
ComputeVirtAPI类：计算Virt API；
ComputeManager类：管理实例从建立到销毁的运行过程；
/nova/compute/power_state.py:Power state表示的是从一个特定的域调用virt driver时的状态；
/nova/compute/resource_tracker.py:跟踪计算主机的资源，例如内存和磁盘等，管理实例资源；
/nova/compute/rpcapi.py:compute RPC API客户端；
ComputeAPI类：compute rpc API的客户端类；
SecurityGroupAPI类：安全组RPC API客户端类；
/nova/compute/stats.py:用来更新计算节点工作量统计数据信息的操作；
/nova/compute/task_states.py:实例可能处于的任务状态；
/nova/compute/utils.py:计算相关的使用工具和辅助方法；
/nova/compute/vm_mode.py:实例可能的虚拟机模式；
/nova/compute/vm_states.py:实例可能的虚拟机状态；
/nova/conductor/__init__.py:这里简单解释一下nova conductor服务，在Grizzly版的Nova中，nova-conductor是在nova-compute之上的新的服务层，它使得nova-compute不再直接访问数据库；
/nova/conductor/api.py:处理conductor service所有的请求；
LocalAPI类：conductor API 的本地版本，这个类处理了本地数据库的更新，而不是通过RPC；
API类：通过RPC和ConductorManager类实现数据库的更新，实现Conductor的管理；
/nova/conductor/manager.py:处理来自其他nova服务的数据库请求；
注：主要实现就是ConductorManager类；
/nova/conductor/rpcapi.py:conductor RPC API客户端；
/nova/console/api.py:处理ConsoleProxy API请求；
/nova/console/fake.py:模拟ConsoleProxy driver用于测试；
/nova/console/manager.py:控制台代理服务；
/nova/console/rpcapi.py:console RPC API客户端；
/nova/console/vmrc_manager.py:VMRC控制台管理；
/nova/console/vmrc.py:VMRC控制台驱动；
/nova/console/websocketproxy.py:与OpenStack Nova相兼容的Websocket proxy；
/nova/console/xvp.py:Xenserver VNC Proxy驱动；
/nova/consoleauth/__init__.py:控制台身份验证模块；
/nova/consoleauth/manager.py:控制台的认证组组件；
/nova/consoleauth/rpcapi.py:控制台认证rpc API的客户端；
/nova/db/__init__.py:Nova数据库的抽象；
/nova/db/api.py:定义数据库访问接口；
/nova/db/base.py:需要模块化数据库访问基类；
/nova/db/migration.py:数据库设置和迁移命令；
/nova/db/sqlalchemy/api.py:SQLAlchemy后端的执行；
/nova/db/sqlalchemy/models.py:nova数据的SQLAlchemy模板；
/nova/db/sqlalchemy/types.py:自定义SQLAlchemy类型；
/nova/db/sqlalchemy/utils.py:SQLAlchemy实用程序；
/nova/image/glance.py:使用Glance作为后端的镜像服务的实现；
GlanceClientWrapper类：glance客户端包装类；
包括：建立一个glance客户端、调用一个glance客户端对象来获取image镜像等方法；
GlanceImageService类：这个glance镜像服务类提供了glance内部的磁盘镜像对象的存储和检索；
还有其他的一些glance镜像服务方法；
/nova/image/s3.py:从S3获取数据，建立镜像等相关方法；
/nova/network/api.py:API类：通过nova-network进行网络管理的API；
/nova/network/dns_driver.py:定义DNS管理器接口；
/nova/network/driver.py:加载网络驱动；
/nova/network/floating_ips.py:FloatingIP类：实现添加浮动IP的功能和相关管理；
/nova/network/l3.py:L3网络的实现和管理；
/nova/network/ldapdns.py:LdapDNS管理；
/nova/network/linux_net.py:linux应用程序实现vlans、bridges和iptables rules；
/nova/network/manager.py:建立IP地址和设置网络；
RPCAllocateFixedIP类：FlatDCHP的设置和VLAN网络管理；
NetworkManager类：实现通用的网络管理的方法集合类；
FlatManager类：不使用vlan的FLAN网络管理；
FlatDHCPManager类：DHCP FLAT网络管理；
VlanManager类：DHCP的VLAN网络管理；
/nova/network/minidns.py:用于测试的DNS驱动类；
/nova/network/model.py:定义网络模板；
Model类：定义了对于大多数的网络模型所必需的结构；
IP类：Nova中的一个IP地址；
FixedIP类：Nova中的一个浮动IP；
Route类：Nova中的一个IP路由；
Subnet类：Nova中的一个IP路由；
Network类：代表网络中的Network参数；
VIF类：虚拟的网络接口；
NetworkInfo类：为一个Nova实例存储和处理网络信息；
/nova/network/noop_dns_driver.py:Noop DNS管理方法的定义；
/nova/network/nova_ipam_lib.py:QuantumNovaIPAMLib类：应用本地Nova数据库来实现Quantum IP地址管理接口；
/nova/network/rpcapi.py:network RPC API客户端；
/nova/network/sg.py:实现对安全组的抽象和相关API；
/nova/network/quantumv2/__init__.py:获取quantum v2版客户端；
/nova/network/quantumv2/api.py:访问quantum 2.xAPI接口方法集合类；
/nova/network/security_group/openstack_driver.py:OpenStank安全组驱动相关；
/nova/network/security_group/quantum_driver.py:SecurityGroupAPI类：安全组相关的管理API；
/nova/network/security_group/security_group_base.py:SecurityGroupBase类：安全组基类；
/nova/objectstore/s3server.py:基于本地文件实现S3式的存储服务；
/nova/openstack/common/cliutils.py:命令行实用工具，确认所提供的用于调用方法的参数是充足的；
/nova/openstack/common/context.py:实现存储安全上下文信息的类；
/nova/openstack/common/eventlet_backdoor.py:eventlet后门程序；
/nova/openstack/common/excutils.py:异常相关的实用程序；
/nova/openstack/common/fileutils.py:文件相关的实用程序；
/nova/openstack/common/gettextutils.py:获取文本文件实用程序；
/nova/openstack/common/importutils.py:加载类的相关实用程序和辅助方法；
/nova/openstack/common/jsonutils.py:JSON相关实用程序；
/nova/openstack/common/local.py:Greenthread本地存储；
/nova/openstack/common/lockutils.py:锁相关的方法；
/nova/openstack/common/log.py:OpenStack日志处理程序；
/nova/openstack/common/memorycache.py:memcached客户端接口；
/nova/openstack/common/network_utils.py:network相关的实用程序和辅助方法；
parse_host_port方法：把address和default_port解析成host和port配对形式的字符串；
/nova/openstack/common/policy.py:policy机制就是用来控制某一个User在某个Tenant中的权限的机制；
/nova/openstack/common/processutils.py:系统级的实用程序和辅助方法；
/nova/openstack/common/setup.py:一些实用程序；
/nova/openstack/common/timeutils.py:time相关实用方法；
/nova/openstack/common/uuidutils.py:UUID相关实用方法；
/nova/openstack/common/version.py:版本信息；
/nova/openstack/common/db/api.py:多DB API的后端支持；
/nova/openstack/common/db/exception.py:DB相关的自定义异常；
/nova/openstack/common/db/sqlalchemy/models.py:SQLAlchemy模板；
/nova/openstack/common/db/sqlalchemy/session.py:SQLAlchemy后端的会话处理；
/nova/openstack/common/db/sqlalchemy/utils.py:分页查询的实现；
/nova/openstack/common/notifier/api.py:notifier（通知）功能实现的API；
/nova/openstack/common/notifier/log_notifier.py:实现确定系统日志记录器；
/nova/openstack/common/notifier/rabbit_notifier.py:在Grizzly版本中，不在应用rabbit来发送通知，而是使用rpc_notifier来进行发送,提示转到相关方法；
/nova/openstack/common/notifier/rpc_notifier.py:通过RPC发送一个通知；
/nova/openstack/common/notifier/rpc_notifier2.py:通过RPC发送一个通知；
/nova/openstack/common/plugin/callbackplugin.py:管理插件的callback功能；
/nova/openstack/common/plugin/plugin.py:为OpenStack增加插件定义接口；
/nova/openstack/common/plugin/pluginmanager.py:插件相关管理；
/nova/openstack/common/rootwrap/filters.py:命令行的各种过滤器的实现；
/nova/openstack/common/rootwrap/wrapper.py:实现过滤器的封装；
/nova/openstack/common/rpc/__init__.py:远程过程调用（rpc）的抽象实现；
/nova/openstack/common/rpc/amqp.py:基于openstack.common.rpc实现AMQP之间的代码共享，AMQP的实现；
/nova/openstack/common/rpc/common.py:RPC封装的实现；
/nova/openstack/common/rpc/dispatcher.py:RPC消息调度的代码实现；
/nova/openstack/common/rpc/impl_fake.py:虚拟RPC实现，直接调用代理方法而不用排队；
/nova/openstack/common/rpc/impl_kombu.py:系统默认的RPC实现；
/nova/openstack/common/rpc/impl_qpid.py:RPC实现之一；
/nova/openstack/common/rpc/impl_zmq.py:RPC实现之一；
/nova/openstack/common/rpc/matchmaker.py:MatchMaker类；
/nova/openstack/common/rpc/proxy.py:RPC客户端的辅助类；
/nova/openstack/common/rpc/service.py:运行在主机host上的服务对象；

/nova/scheduler/__init__.py:这个模块的功能是挑选一个计算节点来运行一个虚拟机实例；
/nova/scheduler/baremetal_host_manager.py:管理当前域中的主机；
/nova/scheduler/chance.py:随机调度实施方案；
/nova/scheduler/driver.py:所有调度器应该继承的调度基类；
/nova/scheduler/filter_scheduler.py:这个FilterScheduler类是为了创建本地的实例；
我们可以通过制定自己的主机过滤器（Host Filters）和权重函数（Weighing Functions）来自定义调度器；
/nova/scheduler/host_manager.py:管理当前域中的主机；
/nova/scheduler/manager.py:调度服务；
/nova/scheduler/multi.py:这个调度器原本是用来处理计算和卷之间关系的；
现在用于openstack扩展，使用nova调度器来调度需求到计算节点；
但是要提供它们自己的管理和主题；
/nova/scheduler/rpcapi.py:调度器管理RPC API的客户端；
/nova/scheduler/scheduler_options.py:SchedulerOptions检测本地的一个json文件的变化，有需要的话加载它；
这个文件被转换为一个数据结构，并且传递到过滤和权重函数；
可以实现它的动态设置；
/nova/scheduler/filters/__init__.py:调度主机过滤器；
/nova/scheduler/filters/aggregate_instance_extra_specs.py:AggregateInstanceExtraSpecsFilter主机过滤器的定义和实现；
/nova/scheduler/filters/aggregate_multitenancy_isolation.py:实现在特定的聚集中隔离租户；
/nova/scheduler/filters/all_hosts_filter.py:不经过过滤，返回所有主机host；
/nova/scheduler/filters/availability_zone_filter.py:通过可用的区域来过滤主机host；
/nova/scheduler/filters/compute_capabilities_filter.py:ComputeCapabilitiesFilter主机过滤器实现；
/nova/scheduler/filters/compute_filter.py:活跃的计算节点的过滤；
/nova/scheduler/filters/core_filter.py:基于核心CPU利用率的主机host过滤器；
/nova/scheduler/filters/disk_filter.py:基于磁盘使用率的主机host过滤；
/nova/scheduler/filters/extra_specs_ops.py:一些参数的设置；
/nova/scheduler/filters/image_props_filter.py:通过符合实例镜像属性来进行计算节点主机的过滤；
/nova/scheduler/filters/io_ops_filter.py:过滤掉有过多的I/O操作的主机host；
/nova/scheduler/filters/isolated_hosts_filter.py:IsolatedHostsFilter过滤器实现；
/nova/scheduler/filters/json_filter.py:JsonFilter过滤器的实现；
/nova/scheduler/filters/num_instances_filter.py:过滤掉已经有太多实例的主机host；
/nova/scheduler/filters/ram_filter.py:只返回有足够可使用的RAM主机host；
/nova/scheduler/filters/retry_filter.py:跳过已经尝试过的节点；
/nova/scheduler/filters/trusted_filter.py:根据可信计算池进行主机host过滤；
/nova/scheduler/filters/type_filter.py:TypeAffinityFilter过滤器的实现，它不允许一个主机上运行多余一种类型的虚拟机；
/nova/scheduler/weights/__init__.py:调度器中的主机权重；
/nova/scheduler/weights/least_cost.py:Least Cost是调度器中选择主机的一种算法；
/nova/scheduler/weights/ram.py:RAM权重；
/nova/servicegroup/api.py:定义servicegroup的入口API；
/nova/storage/linuxscsi.py:通用的linux scsi子系统实用程序；
/nova/virt/configdrive.py:构建配置驱动器；
/nova/virt/driver.py:计算驱动基类的实现；
/nova/virt/event.py:来自于虚拟机管理程序异步事件的通知；
/nova/virt/fake.py:用于测试的一个虚拟的hypervisor+api；
/nova/virt/firewall.py:虚拟机防火墙的定义和管理；
/nova/virt/images.py:处理虚拟机磁盘镜像；
/nova/virt/netutils.py:支持libvirt连接的网络相关实用程序；
/nova/virt/storage_users.py:实例存储相关；
/nova/virt/virtapi.py:Virt API抽象类；
/nova/virt/libvirt/blockinfo.py:处理块设备信息和块设备映射；
/nova/virt/libvirt/config.py:libvirt对象配置；
/nova/virt/libvirt/designer.py:libvirt对象配置策略；
/nova/virt/libvirt/driver.py:通过libvirt连接到虚拟机管理程序的实现，以及相关管理功能的实现；
/nova/virt/libvirt/firewall.py:libvirt防火墙相关；
/nova/virt/libvirt/imagebackend.py:通过libvirt实现后端镜像的管理操作；
/nova/virt/libvirt/imagecache.py:镜像高速缓存的管理实现；
/nova/virt/libvirt/utils.py:libvirt相关实用程序；
/nova/virt/libvirt/vif.py:libvirt的VIF驱动；
/nova/virt/libvirt/volume_nfs.py:不再应用的过时的实现；
/nova/virt/libvirt/volume.py:libvirt卷驱动实现；
/nova/virt/disk/__init__.py:磁盘上的实践包括：重定义大小，文件系统建立和文件注入等；
/nova/virt/disk/api.py:提供了调整、重新分区和修改磁盘镜像的方法以及文件注入等方法；
/nova/virt/disk/mount/__init__.py:支持挂载磁盘镜像到主机文件系统；
/nova/virt/disk/mount/api.py:支持挂载虚拟镜像文件；
/nova/virt/disk/mount/loop.py:支持回环设备挂载镜像；
/nova/virt/disk/mount/nbd.py:支持挂载磁盘镜像到qemu-nbd；
/nova/virt/disk/vfs/__init__.py:虚拟文件系统实践；
/nova/virt/disk/vfs/api.py:虚拟文件系统API；
/nova/virt/disk/vfs/guestfs.py:来宾虚拟文件系统；
/nova/virt/disk/vfs/localfs.py:本地虚拟文件系统；
/nova/virt/hyperv/basevolumeutils.py:卷管理相关业务的辅助方法以及存储的实现；
/nova/virt/hyperv/constants.py:ops类中使用的常量；
/nova/virt/hyperv/driver.py:Hyper-V Nova Compute driver
/nova/virt/hyperv/hostops.py:主机运作的管理类；
/nova/virt/hyperv/hostutils.py:主机运作的实用程序；
/nova/virt/hyperv/imagecache.py:镜像缓存和管理；
/nova/virt/hyperv/livemigrationops.py:实时迁移VM虚拟机业务管理类；
/nova/virt/hyperv/livemigrationutils.py:虚拟机实例实时迁移实用程序；
/nova/virt/hyperv/migrationops.py:迁移/调整大小操作管理类；
/nova/virt/hyperv/networkutils.py:网络相关业务实用程序类；
/nova/virt/hyperv/pathutils.py:路径相关实用程序；
/nova/virt/hyperv/snapshotops.py:虚拟机快照业务管理类；
/nova/virt/hyperv/vmops.py:基本VM虚拟机业务管理类；
/nova/virt/hyperv/vmutils.py:Hyper-V上的VM虚拟机相关业务实用程序类；
/nova/virt/hyperv/volumeops.py:存储相关方法管理类（附加，卸下等等）；
/nova/virt/hyperv/volumeutils.py:卷的相关管理业务辅助类以及存储实现等；
/nova/virt/hyperv/volumeutilsv2.py:卷的相关管理业务辅助类以及在Windows Server 2012上存储实现等；
/nova/__init__.py:Nova HTTP服务；
/nova/availability_zones.py:可用zone的辅助方法；
/nova/context.py:关于请求信息上下文的一些方法
/nova/exception.py:Nova基本的异常处理，包括各种异常类及其类中提示的异常信息；
/nova/filters.py:滤波器支持，定义了所有滤波器类的基类和处理加载滤波器类的基类；
/nova/manager.py:基本管理类；
/nova/notifications.py:系统常见的多层次通知的相关方法；
/nova/policy.py:Nova的Policy引擎；
/nova/quota.py:实例配额和浮动ip；
/nova/service.py:主机上运行所有服务的通用节点基类；
/nova/test.py:单元测试的基类；
/nova/utils.py:实用工具和辅助方法；
/nova/weights.py:可插拔权重支持；
/nova/wsgi.py:WSGI服务工作的通用方法；
}

# six
是一个Python 2和3的兼容性库,它提供了用于平滑Python版本之间差异的实用函数，其目标是编写在两个Python版本上兼容的Python代码。

#创建虚拟机的函数调用关系
{
[nova-api]
nova/api/openstack/compute/servers.py: create （创建虚拟机）
    nova/compute/api.py: create
        nova/compute/api.py: _create_instance
            nova/compute/api.py: _validate_and_build_base_options （验证基本输入参数，并拷贝flavor信息）
            nova/compute/api.py: _check_and_transform_bdm （检查块设备）
            nova/compute/api.py: _provision_instances （查看配额quota是否满足）
            nova/compute/api.py: _build_filter_properties （获取主机过滤条件）
            nova/compute/api.py: _record_action_start （更新数据库，记录创建开始信息）
            nova/conductor/api.py: build_instances （使用rpc调用 nova-conductor的manager的同名函数）
                nova/conductor/rpcapi.py: build_instances
                    [nova-conductor]
                    nova/conductor/manager.py: build_instances
                    scheduler_utils.build_request_spec
                    self.scheduler_client.select_destinations 
                       scheduler_rpcapi.select_destinations
                        [nova-scheduler]
                        nova/scheduler/filter_scheduler.py: select_destinations（调用过滤器，选择满足条件的主机）
                           nova/scheduler/filter_scheduler.py:_schedule
                              nova/scheduler/host_manager.py:get_all_host_states
                              nova/scheduler/host_manager.py:get_filtered_hosts
                             nova/filters.py: get_filtered_objects 
                                            （这里的filter_classes就是系统配置的过滤器集）
                    [nova-conductor]
                    self.compute_rpcapi.build_and_run_instance
                        [nova-compute]
                        build_and_run_instance
                            utils.spawn_n  _do_build_and_run_instance （创建一个绿色线程）
                                self._decode_files(injected_files)   (处理注入文件的编码)
                                _build_and_run_instance  （状态从building变为active）
                                    _build_resources
                                        _build_networks_for_instance （创建网络）
                                        _prep_block_device  （创建存储）
                                    self.driver.spawn  （调用virt层创建虚拟机）
                                    [libvirt]
                                    nova/virt/libvirt/driver.py:spawn （真正创建虚拟机）
                                        nova/virt/libvirt/driver.py:_create_image
                                        nova/virt/libvirt/driver.py: _get_guest_xml （nova和libvirt的接口就是xml）
                                        nova/virt/libvirt/driver.py:_create_domain_and_network
                                           nova/virt/libvirt/driver.py: _create_domain
                                        nova/virt/libvirt/driver.py:_wait_for_boot （等待libvirt创建虚拟机结束）

}
