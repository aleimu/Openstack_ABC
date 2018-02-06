#centos环境上的Django+uwsgi+Nginx安装部署

yum -y install nginx
yum install python-devel.x86_64
pip install uwsgi
pip install Django

#配置Nginx
vim /etc/nginx/nginx.conf
    server {
        #对外监听的端口和ip格式，也就是网页访问时的端口ip
        listen       802; 
        server_name  0.0.0.0;
        root         /usr/share/nginx/html;
        charset UTF-8;
        access_log  /home/lgj/log/access.log;
        error_log   /home/lgj/log/error.log;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;
        #脚本请求全部转发到uwsgi处理. 使用uwsgi配置.
        location / {
            include uwsgi_params;
            uwsgi_pass 127.0.0.1:800; #这里是uwsgi的监听端口
            uwsgi_read_timeout 2;
        }
        error_page 404 /404.html;
            location = /40x.html {
        }

        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
        }
    }
#启动nginx
nginx
#停止
nginx -s quit
nginx -s stop
nginx停止命令stop与quit参数的区别在于stop是快速停止nginx，可能并不保存相关信息，业务有中断。quit是完整有序的停止nginx，并保存相关信息。
#重载
nginx -s reload
nginx -t 是nginx检查配置文件是否有错误的命令


#新建myweb_uwsgi.ini配置文件如下:
[uwsgi]
socket = 127.0.0.1:800
chdir = /home/lgj/myweb
module = myweb.wsgi
master  = true
processes = 4
vacuum = true
#运行uwsgi加载对应配置
uwsgi --ini /home/lgj/myweb/myweb_uwsgi.ini


#创建一个Django项目
cd /home/lgj
django-admin.py startproject myweb

#修改ALLOWED_HOSTS 为['*']
vim /home/lgj/myweb/myweb/settings.py
ALLOWED_HOSTS = ['*']

#启动django，端口随便用只要不冲突，uwsgi是靠module = myweb.wsgi找到的服务
python ./myweb/manage.py runserver 127.0.0.1:8080

#页面上尝试访问
http://100.114.233.208:802/



扩展知识{

#测试uwsgi，创建test.py文件：
def application(env, start_response):
    start_response('200 OK', [('Content-Type','text/html')])
    return [b"Hello World"]
 
#通过uwsgi运行该文件。
uwsgi --http :800 --wsgi-file test.py


#接下来配置Django与uwsgi连接。假定的我的django项目位置为：/home/lgj/myweb
uwsgi --http :800 --chdir /home/lgj/myweb --wsgi-file myweb/wsgi.py --master --processes 4 --threads 2 --stats 0.0.0.0:8000

#常用选项：
http ： 协议类型和端口号
processes ：开启的进程数量
workers ：  开启的进程数量，等同于processes（官网的说法是spawn the specified number ofworkers / processes）
chdir ： 指定运行目录（chdir to specified directory before apps loading）
wsgi-file ： 载入wsgi-file（load .wsgi file）
stats ： 在指定的地址上，开启状态服务
threads ： 运行线程。由于GIL的存在，我觉得这个真心没啥用。
master ： 允许主进程存在（enable master process）
daemonize ： 使进程在后台运行，并将日志打到指定的日志文件或者udp服务器（daemonize uWSGI）。实际上最常用的，还是把运行记录输出到一个本地文件上。
pidfile ： 指定pid文件的位置，记录主进程的pid号。
vacuum ： 当服务器退出的时候自动清理环境，删除unix socket文件和pid文件（try to remove all of the generated file/sockets）


uswgi作为nginx和django之间的搬运工，wsgi-file连接django项目，socket连接Nginx。要将服务长久化就必须写一个配置文件。如下配置文件,路径在django主目录，是对上一步骤的命令行中命令的文件化。其中我们熟悉的配置项：

http:9000   指定服务的开启端口
wsgi-flie   tutorial/wsgi.py 指定请求的处理文件，在django项目中自动创建的文件。位于tutorial/tutorial/wsgi.py
chdir       django的主目录
socket      和nginx交互的端口。
daemonize   让程序后台运行。默认开启程序时如上图中会在终端中输出连接信息，开启该项配置关闭输出信息。

# uwsig使用配置文件启动
[uwsgi]
# 项目目录
chdir=/opt/proj/teacher/
# 指定项目的application
module=teacher.wsgi:application
# 指定sock的文件路径       
socket=/opt/proj/script/uwsgi.sock
# 进程个数       
workers=5
pidfile=/opt/proj/script/uwsgi.pid
# 指定IP端口       
http=192.168.2.108:8080
# 指定静态文件
static-map=/static=/opt/proj/teacher/static
# 启动uwsgi的用户名和用户组
uid=root
gid=root
# 启用主进程
master=true
# 自动移除unix Socket和pid文件当服务停止的时候
vacuum=true
# 序列化接受的内容，如果可能的话
thunder-lock=true
# 启用线程
enable-threads=true
# 设置自中断时间
harakiri=30
# 设置缓冲
post-buffering=4096
# 设置日志目录
daemonize=/opt/proj/script/uwsgi.log


#  /etc/nginx/nginx.conf 中server的常用配置

server {
        #这里是访问时用到的端口
        listen       8000;
        server_name  127.0.0.1;
        charset UTF-8;
        #这块存让日志文件
        access_log  /home/lgj/log/access.log;
        error_log   /home/lgj/log/error.log;
        client_max_body_size 75M;
        location / {
            #一定要有该配置项
            include uwsgi_params;
            #同uwsgi内容，连接uwsgi的socket。
            uwsgi_pass 127.0.0.1:8001;
            #链接超时时间
            uwsgi_read_timeout 30;
        }

          location /static/ {
               autoindex on;
               #这里的路径一定要到达静态文件的文件夹。即collectedstatic/,重点在最后的横杠。不然会报错
               alias /home/ccf/code/django_learn/tutorial/collectedstatic/; 
               }

          location /media/ {
                  autoindex on;
                alias /home/ccf/code/django_learn/tutorial/media/;
          }
}



}
