#安装
rpm -ivh
#升级
rpm -Uvh
#移走
rpm -e

#列出安装的软件
rpm -qa|grep tcpd
#卸载
rpm -e tcpdump-3.9.8-1.21.x86_64
#强制卸载
rpm -e --nodeps gaussdata
rpm -e --nodeps --force gaussdata

#yum安装：
yum install 包名
#yum卸载：
yum -y remove 包名
