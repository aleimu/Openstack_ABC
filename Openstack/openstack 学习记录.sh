《openstack 学习记录》

参考博客{
#入门,了解各组件的关系 ----很好
http://www.cnblogs.com/pythonxiaohu/p/5861409.html  
#nova创建虚机流程源码分析 ------精简,过程基本包含
http://blog.csdn.net/Tech_Salon/article/details/70238434
#OpenStack建立实例完整过程源码详细分析: -------系列文章,较全面

https://github.com/int32bit/openstack-workflow  #----精华
http://blog.csdn.net/gaoxingnengjisuan/article/details/9130213
http://www.cnblogs.com/junneyang/p/5257303.html
http://www.cnblogs.com/littlebugfish/p/4660586.html
http://blog.csdn.net/weixin_39400463/article/details/76407950

}

学习Openstack的最佳步骤是{
看文档
部署allineone
使用
部署多节点
再次看文档
深度使用
阅读源码
参与社区开发
}

RPC与rabbitMQ消息队列{

#http://www.cnblogs.com/jmilkfan-fanguiju/p/7532329.html  ---Openstack Nova 源码分析 — RPC 远程调用过程------具体到了代码,可以学习
#http://www.cnblogs.com/chris-cp/p/6678719.html  -----openstack rpc机制 ----概念
#http://www.cnblogs.com/chenergougou/p/7056557.html    ------openstack RPC通信 ----概念

RPC（Remote Procedure Call Protocol）
——远程过程调用协议,它是一种通过网络从远程计算机程序上请求服务,而不需要了解底层网络技术的协议。RPC协议假定某些传输协议的存在,如TCP或UDP,为通信程序之间携带信息数据。
RPC 的主要功能目标是让构建分布式计算（应用）更容易,在提供强大的远程调用能力时不损失本地调用的语义简洁性。
RPC 调用分以下两种: 
	同步调用
	客户方等待调用执行完成并返回结果。
	异步调用
	客户方调用后不用等待执行结果返回,但依然可以通过回调通知等方式获取返回结果。 若客户方不关心调用返回结果,则变成单向异步调用,单向调用不用返回结果。
	异步和同步的区分在于是否等待服务端执行完成并返回结果。

在Openstack中,RPC调用是通过RabbitMQ进行的。
任何一个RPC调用,都有Client/Server两部分,分别在rpcapi.py和manager.py中实现。
这里以nova-scheduler调用nova-compute为例子。
nova/compute/rpcapi.py中有ComputeAPI
nova/compute/manager.py中有ComputeManager
两个类有名字相同的方法,nova-scheduler调用ComputeAPI中的方法,通过底层的RabbitMQ,就能到达nova-compute的ComputeManager中的方法。	

OpenStack层封装call和cast接口用于远程调用RPC的server上的方法,这些方法都是构造RPC的server的endpoints内的方法。远程调用时,需要提供一个字典对象来指明调用的上下文,调用方法的名字和传递给调用方法的参数(用字典表示)。如: 
　　　　cctxt =self.client.prepare(vesion=’2.0’)
　　　　cctxt.cast(context,'build_instances', **kw)
通过cast方式的远程调用,请求发送后就直接返回了；通过call方式远程调用,需要等响应从服务器返回。	
#其中cast表示异步调用,build_instances 是远程调用的方法,kw是传递的参数。		

self.client = rpc.get_client(target, serializer=serializer)
#放入
cctxt = self.client.prepare(version=version)
cctxt.cast(context, 'schedule_and_build_instances', **kw)
#获取
cctxt = self.client.prepare(version='1.1')
return cctxt.call(ctxt, 'get_cell_info_for_neighbors')
#调用的call方法,即同步RPC调用,此时nova-conductor并不会退出,而是堵塞等待直到nova-scheduler返回。

#------自下而上-----
#E:\下载9月\openstatck\nova-master\nova-master\requirements.txt
oslo.messaging>=5.29.0 # Apache-2.0
import oslo_messaging as messaging
#E:\下载9月\openstatck\nova-master\nova-master\nova\rpc.py
from nova import rpc
self.router = rpc.ClientRouter(default_client)
cctxt = self.router.client(ctxt).prepare(server=host, version=version)
cctxt.cast(ctxt, 'add_aggregate_host',aggregate=aggregate, host=host_param,slave_info=slave_info)
#E:\下载9月\openstatck\nova-master\nova-master\nova\compute\rpcapi.py

#当nova-conductor通知nova-compute创建虚拟机实例时,过程如下:  
1. 在 nova-conductor 的代码中使用了 import nova-compute rpcapi module 或者类实例化传参这两种实现方式来加载 compute rpcapi 对象。这样 nova-conductor 就拥有了通过 RPC 访问 nova-compue 的能力。 
2. 在 nova-conductor 的代码实现中调用了 rpcapi 模块的方法,即 nova-conductor发送了一个请求到 Queue,并等待 nova-compute 接受和响应。 
3. nova-compute 接收到 nova-conductor 的请求,并作出响应。
}

RPC消息在nova中的流程
{
#通常一个服务的目录都会包含api.py、rpcapi.py、manager.py,这个三个是最重要的模块。
api.py:  通常是供其它组件调用的封装库。换句话说,该模块通常并不会由本模块调用。比如compute目录的api.py,通常由nova-api服务的controller调用。
rpcapi.py: 这个是RPC请求的封装,或者说是RPC封装的client端,该模块封装了RPC请求调用。
manager.py:  这个才是真正服务的功能实现,也是RPC的服务端,即处理RPC请求的入口,实现的方法通常和rpcapi实现的方法一一对应。

比如对一个虚拟机执行关机操作: 
API节点
nova-api接收用户请求 -> nova-api调用compute/api.py -> compute/api调用compute/rpcapi.py -> rpcapi.py向目标计算节点发起stop_instance()RPC请求
计算节点
收到MQ RPC消息 -> 解析stop_instance()请求 -> 调用compute/manager.py的callback方法stop_instance() -> 调用libvirt关机虚拟机

#OpenStack项目的目录结构是按照功能划分的,而不是服务组件,因此并不是所有的目录都能有对应的组件。仍以Nova为例:
cmd: 这是服务的启动脚本,即所有服务的main函数。看服务怎么初始化,就从这里开始。
db: 封装数据库访问,目前支持的driver为sqlalchemy。
conf: Nova的配置项声明都在这里。
locale: 本地化处理。
image: 封装Glance调用接口。
network: 封装网络服务接口,根据配置不同,可能调用nova-network或者neutron。
volume: 封装数据卷访问接口,通常是Cinder的client封装。
virt: 这是所有支持的hypervisor驱动,主流的如libvirt、xen等。
objects: 对象模型,封装了所有实体对象的CURD操作,相对以前直接调用db的model更安全,并且支持版本控制。
policies:  policy校验实现。
tests: 单元测试和功能测试代码。





想知道一个项目有哪些服务组成,入口函数（main函数）在哪里,最直接的方式就是查看项目根目录下的setup.cfg文件,其中console_scripts就是所有服务组件的入口,比如nova的setup.cfg的console_scripts,
其中nova-compute服务的入口函数为nova/cmd/compute.py(. -> /)模块的main函数

import pdb; pdb.set_trace() # 设置断点
	c or continue 继续执行程序
	q or quit
	l or list, 显示当前步帧的源码
	w or where,回溯调用过程
	d or down, 后退一步帧（注：相当于回滚）
	u or up, 前进一步帧
	(回车), 重复上一条指令
	
	break 或 b 设置断点
	设置断点(b 77：在77行设置断点；b：查看断点；cl 2：删除第二个断点)

	step 或 s
	进入函数

	return 或 r
	执行代码直到从当前函数返回

	exit 或 q
	中止并退出

	next 或 n
	执行下一行

	p
	打印变量的值

	help
	帮助

}

虚拟机操作列表{

boot: 创建虚拟机。
delete: 删除虚拟机。
force-delete: 无视虚拟机当前状态,强制删除虚拟机。即使开启了软删除功能,该操作也会立即清理虚拟机资源。
list: 显示虚拟机列表。
show: 查看指定虚拟机的详细信息。
stop: 关机虚拟机。
start: 开机虚拟机。
reboot: 重启虚拟机。默认先尝试软重启,当软重启尝试120后失败,将执行强制重启。
migrate: 冷迁移虚拟机,迁移过程中虚拟机将关机。
live-migrate: 在线迁移虚拟机,虚拟机不会关机。
resize: 修改虚拟机配置,即使用新的flavor重建虚拟机。
rebuild: 重建虚拟机,指定新的image,如果指定快照,则相当于虚拟机状态回滚。
evacuate: 疏散迁移,只有当compute服务down时执行,能够迁移虚拟机到其它正常计算节点中。
reset-state: 手动重置虚拟机状态为error或者active。
create-image: 创建虚拟机快照。
backup: 定期创建虚拟机快照。
volume-attach: 挂载volume卷。
volume-detach: 卸载volume卷。
lock/unlock: 锁定虚拟机,锁定后的虚拟机普通用户不能执行删除、关机等操作。
set-password: 修改管理员密码,虚拟机需要运行qemu guest agent服务。
pause/unpause: 暂停运行的虚拟机,如果底层的虚拟化使用的是libvirt,那么libvirt会在将虚拟机的信息保存到内存中,KVM/QEMU进程仍然在运行,只是暂停执行虚拟机的指令。
suspend/resume: 挂起虚拟机,将虚拟机内存中的信息保存到磁盘上,虚拟机对于的KVM/QEMU进程会终止掉,该操作对应于libvirt中的save操作。resume从挂起的虚拟机恢复。
reset-network: 重置虚拟机网络,在使用libvirt时,该操作不执行任何实际的动作,因此功能尚未实现。
shelve/unshelve: 虚拟机关机后仍占用资源,如果虚拟机长期不使用,可以执行shelve操作,该操作先创建虚拟机快照,然后删除虚拟机,恢复时从快照中重建虚拟机。
rename: 重命名虚拟机, 后期版本将被update操作替代。
update: 修改虚拟机名称、description信息等。
rescue/unrescue: 虚拟机进入拯救模式。原理是创建一台新的虚拟机,并把需要rescue的虚拟机的根磁盘作为第二块硬盘挂载到新创建的虚拟机。当原虚拟机根磁盘破坏不能启动时该操作非常有用。
interface-attach/interface-dettach: 绑定/解绑网卡。
trigger-crash-dump: 使虚拟机触发crash dump错误,测试使用。
resize-confirm: 确认resize操作,此时原来的虚拟机将被删除, 可以配置为自动确认。
resize-revert: 撤销resize操作,新创建的虚拟机删除,并使用原来的虚拟机。
console-log: 查看虚拟机日志。
get-vnc-console: 获取虚拟机vnc地址, 通常使用novnc协议。
restore: 恢复虚拟机。如果配置了软删除功能,当虚拟机被删除时,不会立即删除,而仅仅标识下,此时能够使用restore操作恢复删除的虚拟机。
instance-action-list: 查看虚拟机的操作日志。
instance-action：查看某个虚拟机操作的详细信息,如操作用户、操作时间等。


}

WSGI{
#https://www.python.org/dev/peps/pep-3333/  #原文
#http://www.cnblogs.com/laozhbook/p/python_pep_333.html #python wsgi PEP333 中文翻译
#http://www.cnblogs.com/holbrook/archive/2012/02/25/2357337.html #戏说WSGI（Python Web服务网关接口）
#http://www.cnblogs.com/eric-nirnava/p/wsgi.html #dome与实现
#分为三部分
1. The Application/Framework Side 应用程序/框架 端
2. The Server/Gateway Side  服务器/网关 接口
3. Middleware 中间件 同时扮演两种角色的组件

对于服务器程序来说，middleware就是应用程序，middleware需要伪装成应用程序，传递给服务器程序
对于应用程序来说，middleware就是服务器程序，middleware需要伪装成服务器程序，接受并调用应用程序
注意到单个对象可以作为请求应用程序的服务器存在，也可以作为被服务器调用的应用程序存在。这样的中间件可以执行这样一些功能:
    重写前面提到的 environ 之后，可以根据目标URL将请求传递到不同的应用程序对象
    允许多个应用程序和框架在同一个进程中运行
    通过在网络传递请求和响应，实现负载均衡和远程处理
    对内容进行后加工，比如附加xsl样式表
中间件的存在对于服务器接口和应用接口来说都应该是透明的，并且不需要特别的支持。希望在应用程序中加入中间件的用户只需简单得把中间件当作应用提供给服务器，并配置中间件足见以服务器的身份来请求应用程序。


在web服务器和web应用/web框架之间建立一种简单的通用的接口规范，Python Web Server Gateway Interface (WSGI)

WebOb 是一个Python库，主要是用在WSGI中对请求环境变量request environment（也就是WSGI应用中的参数environ）进行包装（提供wrapper），并提供了一个对象来方便的处理返回response消息。

E:\下载9月\openstatck\nova-master\nova-master\nova\wsgi.py


}

文件注入{
目前在创建VM时，可以指定将一些数据预先注入到VM中去，这样启动时就能用了。这些配置项一般都是直接采用OS命令，直接注入到VM硬盘中

}
metadata机制{
用户可以在VM创建时进行部分的自定制。比如说传入主机名、注入密钥、放置启动脚本。
}

既然两者功能差不多，那为啥要弄两套机制呢？{
#文件注入一般是直接往硬盘里写数据的方式，而metadata机制是在VM启动后依赖一个叫做cloud-init的组件来完成写入
一方面，cloud-init是直接预装在镜像中的，虽说目前主流的操作系统都基本包含了，但并不是所有镜像都有，且需要特定网络配置配合。因此只依靠metadata注入并不保险，而且metadata只能导入一部分数据。
另一方面，文件注入通常是将虚拟机磁盘作为设备挂载到主机上，之后就和操作本机文件一样直接文件读写了。但是，并不是所有的操作系统or镜像类型都能够这样做（如centos就需要手工编译nbd到内核里）。所以，这也不是保险的做法。
}


疑问{
#函数spawn在几个文件里都定义了,他的作用是什么？spawn方法是相对比较底层的,里面涉及镜像和创建虚机,后续需要继续深入
spawn(self, context, instance, image_meta, injected_files,admin_password, network_info=None, block_device_info=None)

#创建虚机的函数位置
E:\下载9月\openstatck\nova-master\nova-master\nova\virt\libvirt\driver.py
#下面几个文件中也有spawn函数
E:\下载9月\openstatck\nova-master\nova-master\nova\virt\ironic\driver.py
E:\下载9月\openstatck\nova-master\nova-master\nova\virt\hyperv\vmops.py
E:\下载9月\openstatck\nova-master\nova-master\nova\virt\xenapi\vmops.py
E:\下载9月\openstatck\nova-master\nova-master\nova\virt\vmwareapi\vmops.py
}

计划{
1. 总结 python的二八知识点
2. 总结 openstack的二八知识点

}

以前的知识{

版本：
FusionSphere Platform V100R005C00B071
FusionManager V100R005C00B032

使用root用户登录主机后，还需要导入环境变量，才可以进行一些角色服务的操作：
1.导入admin用户环境变量（B061）：
export OS_PASSWORD=default
export OS_USERNAME=cloud_admin
export OS_TENANT_NAME=admin
export OS_AUTH_URL=https://az1.dc1.vodafone.com:8023/identity/v2.0  
export OS_CACERT=/etc/cacert.crt
export OS_REGION_NAME="az1.dc1"
export BASE_BOND=brcps
export OS_VOLUME_API_VERSION=2
export OS_IDENTITY_API_VERSION=2.0
export NOVA_ENDPOINT_TYPE=internalURL 
export CINDER_ENDPOINT_TYPE=internalURL
export OS_ENDPOINT_TYPE=internalURL

B071执行cli命令环境变量变更如下：

export OS_PASSWORD=cnp200@HW
export OS_USERNAME=nova
export OS_TENANT_NAME=service
export OS_AUTH_URL=https://identity.az1.dc1.vodafone.com:8023/identity/v2.0 
export NOVA_ENDPOINT_TYPE=internalURL
export OS_ENDPOINT_TYPE=internalURL
export CINDER_ENDPOINT_TYPE=internalURL
export OS_VOLUME_API_VERSION=2 
export OS_REGION_NAME=az1.dc1

2.导入keystone导入环境变量
给keystone CLI使用
export OS_PASSWORD=2012
export OS_AUTH_URL=https://az1.dc1.vodafone.com:8023/identity/v2.0  
export OS_USERNAME=nova
export OS_TENANT_NAME=service 
利用keystone token-get获取一个token
export OS_SERVICE_TOKEN=上一步申请到的token
export OS_SERVICE_ENDPOINT=https://az1.dc1.vodafone.com:8023/identity-admin/v2.0



一：CPS相关：

1.查询endpoint
keystone endpoint-list

2.删除endpoint 
 keystone endpoint-delete ID（如上命令查出的0314b53e554c4708bf8c7b296550382d）

3.查询keystone
cps template-instance-list --service keystone keystone

4.查询haproxy
cps template-params-show --service haproxy haproxy

5.列出当前主机：
cps host-list

6.删除规格
nova flavor-list



二：glance相关：
1. 查看当前镜像
glance image-list

2.删除镜像
glance image-delete ID（如上命令查出的ef13104e-94ee-45b9-8ecf-418e5374c99b ）

3.创建镜像：
glance image-create --name theFirstImage --disk-format qcow2 --container-format bare --is-public True --file cirros-0.3.1-x86_64-disk.img


三：虚拟机操作相关：

0.虚拟机镜像上传
curl -i -H "Content-Type: application/octet-stream" -H "X-Auth-$TOKEN_ID" -T /opt/HUAWEI/image/cirros-0.3.1-x86_64-disk.img -k https://$DOMAIN_GLANCE/v2/images/$IMAGE_ID/file

1.在指定的host上创建虚拟机（非FM虚拟机）：
例1：
nova boot --image theFirstImage --flavor 1 --nic net-id=d9f5c593-d0a9-42e0-974f-137bc9c71d30  testVM11 --availability_zone nova:A0808A70-CCB4-E311-80F9-000000821800
例2：创建双网卡虚拟机：
nova --debug boot --image big-image --flavor 7 --nic net-id=d26794b8-473c-4254-8cb8-2b79203bc6d3 --nic net-id=5cb5d724-0979-462b-8540-2a16d8c03fa8 SMSC01 --availability_zone nova:A0CDFEC3-D0B4-E311-80F9-000000821800


2.显示虚拟机：
nova list

3.显示当前虚拟机详情：
nova show ID（如61826e3f-8fe9-4f6e-aee7-1955edab8fbb）

4.查看虚拟机规格：
nova flavor-list

5.显示当前节点虚拟机：
virsh list

6.进入虚拟机：
virsh console ID（上命令查询出来的ID，如2）

7.删除虚拟机：
nova delete 61826e3f-8fe9-4f6e-aee7-1955edab8fbb

8.退出虚拟机登陆：
ctrl+] 

9. 创建FM虚拟机规格：
nova flavor-create FSFLAVOR 6 6144 80 4 --ephemeral 80

10.创建FM的虚拟机
创建双机的FM：（IP注意与不能DHCP端口组占用的IP重复，建议从开始网段的第3个IP后分配）
cps --debug mnt-vm-boot --type fusionmanager --parameter subtype=allinone hamode="active-standby" host="A0808A70-CCB4-E311-80F9-000000821800,804A2A04-A9B4-E311-80F9-000000821800" user=nova password=2012 tenant-name=service auth-url="https://az1.dc1.vodafone.com:8023/identity-admin" api-subnet="6ceabb5e-364f-4f17-92e2-b6a6b398fb2f" api-fixips="90.1.0.5,90.1.0.6" api-netmask=255.255.255.0 api-haarbitrateip=90.1.0.1 api-gateway=90.1.0.1 api-floatip=90.1.0.7 region-name=az1.dc1 om-subnet="df7c27b4-e553-436c-a86f-3a0d96f706c9" om-netmask="255.255.240.0" om-fixips="169.254.2.7，169.254.2.8" om-gateway=169.254.0.1 om-floatip=169.254.2.9 flavorid="6"


创建单机的FM：（IP注意与不能DHCP端口组占用的IP重复，建议从开始网段的第3个IP后分配）
cps --debug mnt-vm-boot --type fusionmanager --parameter subtype=allinone hamode="single" host="A0808A70-CCB4-E311-80F9-000000821800" user=nova password=2012 tenant-name=service auth-url="https://az1.dc1.vodafone.com:8023/identity-admin" api-subnet="6ceabb5e-364f-4f17-92e2-b6a6b398fb2f" api-fixips="90.1.0.10" api-netmask=255.255.255.0 api-haarbitrateip=90.1.0.1 api-gateway=90.1.0.1 region-name=az1.dc1 om-subnet="df7c27b4-e553-436c-a86f-3a0d96f706c9" om-netmask="255.255.240.0" om-fixips="169.254.2.20" om-gateway=169.254.0.1  flavorid="6"

11.删除FM虚拟机，关联的数据没有删除，需要手工删除

删除镜像
glance image-list

删除安全组
neutron security-group-list
删除网络
neutron net-list
删除关联的端口

12.创建虚拟机失败，查看这两个日志定位：
/var/log/fusionsphere/component/cps-server # vi cps-server.log
/var/log/fm/



四：neutron 相关

1.查询网络
neutron net-list

2.查看具体某个网络
neutron net-show netID

3.查询网桥的状态：
ovs-ofctl show br-int

4.查询安全组
neutron security-group-list

5.给安全组添加规则：
neutron security-group-rule-create --protocol tcp --remote-ip-prefix 0.0.0.0/0 --direction ingress 7110d000-3ccc-43a5-baac-bec11114ea58 
neutron security-group-rule-create --protocol udp --remote-ip-prefix 0.0.0.0/0 --direction ingress 7110d000-3ccc-43a5-baac-bec11114ea58 
neutron security-group-rule-create --protocol icmp --remote-ip-prefix 0.0.0.0/0 --direction ingress 7110d000-3ccc-43a5-baac-bec11114ea58 
创建安全组规则，否则会导致创建出来的虚拟机可以ping通外面，但是外面ping不通里面


五：数据库相关：
1.登陆neutron/nova的数据库，按q退出
A0808A70-CCB4-E311-80F9-000000821800:/var/log/fusionsphere/component/nova-compute # su gaussdba
gaussdba@A0808A70-CCB4-E311-80F9-000000821800:/var/log/fusionsphere/component/nova-compute> gsql neutron
could not change directory to "/var/log/fusionsphere/component/nova-compute"
gsql (9.2.1)
Type "help" for help.

NEUTRON=# \d
NEUTRON=# select * from SECURITYGROUPS;
NEUTRON=# \d
NEUTRON=# select * from SECURITYGROUPPORTBINDINGS;


2.登陆FM数据库
allinonefm:/etc/sysconfig/network # su - dbadmin
dbadmin@allinonefm:~> gsql
gsql (9.2.1)
Type "help" for help.

ALLFMDB=# select * from connector.connector;
ALLFMDB=# select * from ssp.cloud_infra;


六：其它
1.停止主节点上DHCP办法(非正常途径)：
ps -ef |grep cbs
将cbs模块都停了，然后修改cbs模块，注释掉dhcp模块
vi /usr/local/bin/cbs-server/cbs_start.sh
将这一行注释掉：
InstallApp=$CURRENT_CBS_PATH/bin/dhcp/dhcpd

A0808A70-CCB4-E311-80F9-000000821800:~ # ps -ef |grep cbs
root      44553      1  1 13:38 ?        00:00:01 python /usr/local/bin/cbs-server/bin/monitor/CBSServerMonitor.py
root      45148      1  0 13:38 ?        00:00:00 /usr/local/bin/cbs-server/bin/dhcp/dhcpd -cf /usr/local/bin/cbs-server/bin/dhcp/dhcpd.conf brcps
root      45215      1  0 13:38 ?        00:00:00 /usr/local/bin/cbs-server/bin/tftp/in.tftpd -ls /usr/local/bin/cbs-server/bin -a 169.254.0.140:69
root      45225      1  0 13:38 ?        00:00:00 /usr/local/bin/cbs-server/bin/python-2.7.3/bin/python2.7 cgi_server.py
root     120815  44553  0 13:40 ?        00:00:00 sh -c { sh /usr/local/bin/cbs-server/cbs_status.sh; } 2>&1
root     120819 120815  0 13:40 ?        00:00:00 sh /usr/local/bin/cbs-server/cbs_status.sh
root     120882 104942  0 13:40 pts/5    00:00:00 grep cbs
A0808A70-CCB4-E311-80F9-000000821800:~ # 


2.当前镜像支持的格式：
wanghuan 00225961(w00225961) 2014-05-23 10:26:01
镜像当前支持raw,qcow2,iso三种格式

3.网卡绑定的命令：
wangwubin 00221487(w00221487) 2014-05-29 11:03:50
echo +trunk0 >/sys/class/net/bonding_masters
echo -trunk0 >/sys/class/net/bonding_masters
ifenslave trunk0 eth0
ifenslave -d trunk0 eth0


4.宿主机上查看FC光纤口的启动器命令：
cat /sys/class/fc_host/host10/port_name

}

Python code 提取UML
{
#Python code 提取UML
http://www.cnblogs.com/linyihai/p/7466235.html
pyreverse 与Graphviz 的使用

pyreverse能方便的生成uml类图，pylint里整合了pyreverse这个工具。使用pip安装pylint
pip install pylint
}


饱谙世事慵开口，会尽人间只点头.
莫道老来无伎俩，更嫌何处不风流.

多进程的坑---变量共享
#http://www.cnblogs.com/congbo/archive/2012/08/24/2652322.html #参考此博客
{

==========================================================
********** {u'hamode': u'active-active', u'pkgname': u'cps-heat-1.0.1-60', u'name': u'heat', u'service': u'heat', u'description': u'The Orchestration service provides a template-based orchestration for describing a cloud application by running OpenStack API calls to generate running cloud applications.'}
Exception in thread Thread-14:
Traceback (most recent call last):
  File "/usr/lib64/python2.7/threading.py", line 811, in __bootstrap_inner
    self.run()
  File "/usr/lib64/python2.7/threading.py", line 764, in run
    self.__target(*self.__args, **self.__kwargs)
  File "/usr/lib64/python2.7/multiprocessing/pool.py", line 342, in _handle_tasks
    put(task)
PicklingError: Can't pickle <type 'function'>: attribute lookup __builtin__.function failed


    def _check_other_comps_ssl(self, new_ssl):
        templates = self.comp_util.get_have_cfg_templates("rabbit_use_ssl")
        import multiprocessing
        import time

        def task(i):
            # print('new we send:',i)
            self._wait_use_ssl_changed(i["service"],
                                       i["name"],
                                       new_ssl)
            self.comp_util.wait_instances_normal(i["service"],
                                                 i["name"],
                                                 new_ssl)

        pool = multiprocessing.Pool(processes=4)
        for i in templates:
            pool.apply_async(task, (i, ))
        pool.close()
        pool.join()

        

        
Exception in thread Thread-14:
Traceback (most recent call last):
  File "/usr/lib64/python2.7/threading.py", line 811, in __bootstrap_inner
    self.run()
  File "/usr/lib64/python2.7/threading.py", line 764, in run
    self.__target(*self.__args, **self.__kwargs)
  File "/usr/lib64/python2.7/multiprocessing/pool.py", line 342, in _handle_tasks
    put(task)
PicklingError: Can't pickle <type 'function'>: attribute lookup __builtin__.function failed
}



