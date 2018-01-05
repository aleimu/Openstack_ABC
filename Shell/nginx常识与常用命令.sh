#nginx的常用命令
1、启动
/usr/local/nginx/sbin/nginx
nginx
./nginx 
由于nginx默认端口也是80端口，如果单板上有其他进程占用，需要停掉
 
2、停止
nginx -s quit
nginx -s stop
nginx停止命令stop与quit参数的区别在于stop是快速停止nginx，可能并不保存相关信息，业务有中断。quit是完整有序的停止nginx，并保存相关信息。

3、重载
 ./sbin/nginx -s reload
上述是采用向 Nginx 发送信号的方式，或者使用service nginx reload
重载，顾名思义就是修改配置后“动态”使其生效，不过和我们想象的不一样的是，它需要进程重启。

4、指定配置文件
 ./sbin/nginx -c /usr/local/nginx/conf/nginx.conf --默认也是这个
 
5、检查配置文件
加载前的必备检查
SZV1000031009:/usr/local/nginx/sbin # ./nginx -t
nginx: the configuration file /usr/local/nginx/conf/nginx.conf syntax is ok
 
6、help
SZV1000031009:/usr/local/nginx/sbin # ./nginx -h


#http://www.cnblogs.com/jay36/p/7521044.html
 nginx 配置说明1{
#运行用户
user nobody;
#启动进程,通常设置成和cpu的数量相等
worker_processes  1;

#全局错误日志及PID文件
#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;

#工作模式及连接数上限
events {
    #epoll是多路复用IO(I/O Multiplexing)中的一种方式,
    #仅用于linux2.6以上内核,可以大大提高nginx的性能
    use   epoll; 

    #单个后台worker process进程的最大并发链接数    
    worker_connections  1024;

    # 并发总数是 worker_processes 和 worker_connections 的乘积
    # 即 max_clients = worker_processes * worker_connections
    # 在设置了反向代理的情况下，max_clients = worker_processes * worker_connections / 4  为什么
    # 为什么上面反向代理要除以4，应该说是一个经验值
    # 根据以上条件，正常情况下的Nginx Server可以应付的最大连接数为：4 * 8000 = 32000
    # worker_connections 值的设置跟物理内存大小有关
    # 因为并发受IO约束，max_clients的值须小于系统可以打开的最大文件数
    # 而系统可以打开的最大文件数和内存大小成正比，一般1GB内存的机器上可以打开的文件数大约是10万左右
    # 我们来看看360M内存的VPS可以打开的文件句柄数是多少：
    # $ cat /proc/sys/fs/file-max
    # 输出 34336
    # 32000 < 34336，即并发连接总数小于系统可以打开的文件句柄总数，这样就在操作系统可以承受的范围之内
    # 所以，worker_connections 的值需根据 worker_processes 进程数目和系统可以打开的最大文件总数进行适当地进行设置
    # 使得并发总数小于操作系统可以打开的最大文件数目
    # 其实质也就是根据主机的物理CPU和内存进行配置
    # 当然，理论上的并发总数可能会和实际有所偏差，因为主机还有其他的工作进程需要消耗系统资源。
    # ulimit -SHn 65535

}


http {
    #设定mime类型,类型由mime.type文件定义
    include    mime.types;
    default_type  application/octet-stream;
    #设定日志格式
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  logs/access.log  main;

    #sendfile 指令指定 nginx 是否调用 sendfile 函数（zero copy 方式）来输出文件，
    #对于普通应用，必须设为 on,
    #如果用来进行下载等应用磁盘IO重负载应用，可设置为 off，
    #以平衡磁盘与网络I/O处理速度，降低系统的uptime.
    sendfile     on;
    #tcp_nopush     on;

    #连接超时时间
    #keepalive_timeout  0;
    keepalive_timeout  65;
    tcp_nodelay     on;

    #开启gzip压缩
    gzip  on;
    gzip_disable "MSIE [1-6].";

    #设定请求缓冲
    client_header_buffer_size    128k;
    large_client_header_buffers  4 128k;


    #设定虚拟主机配置
    server {
        #侦听80端口
        listen    80;
        #定义使用 www.nginx.cn访问
        server_name  www.nginx.cn;

        #定义服务器的默认网站根目录位置
        root html;

        #设定本虚拟主机的访问日志
        access_log  logs/nginx.access.log  main;

        #默认请求
        location / {
            
            #定义首页索引文件的名称
            index index.php index.html index.htm;   

        }

        # 定义错误提示页面
        error_page   500 502 503 504 /50x.html;
        location = /50x.html {
        }

        #静态文件，nginx自己处理
        location ~ ^/(images|javascript|js|css|flash|media|static)/ {
            
            #过期30天，静态文件不怎么更新，过期可以设大一点，
            #如果频繁更新，则可以设置得小一点。
            expires 30d;
        }

        #PHP 脚本请求全部转发到 FastCGI处理. 使用FastCGI默认配置.
        location ~ .php$ {
            fastcgi_pass 127.0.0.1:9000;
            fastcgi_index index.php;
            fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
            include fastcgi_params;
        }

        #禁止访问 .htxxx 文件
            location ~ /.ht {
            deny all;
        }

    }
}

 }
 
 nginx 配置说明2{
 #用户 用户组   
user       www www;   
#工作进程，根据硬件调整，有人说几核cpu，就配几个，我觉得可以多一点   
worker_processes  5；   
#错误日志   
error_log  logs/error.log;   
#pid文件位置   
pid        logs/nginx.pid;   
worker_rlimit_nofile 8192;   
  
events {   
#工作进程的最大连接数量，根据硬件调整，和前面工作进程配合起来用，尽量大，但是别把cpu跑到100%就行   
    worker_connections  4096;   
}   
  
http {   
    include    conf/mime.types;   
    #反向代理配置，可以打开proxy.conf看看   
    include    /etc/nginx/proxy.conf;   
    #fastcgi配置，可以打开fastcgi.conf看看   
    include    /etc/nginx/fastcgi.conf;   
  
    default_type application/octet-stream;   
    #日志的格式   
    log_format   main '$remote_addr - $remote_user [$time_local] $status '  
                      '"$request" $body_bytes_sent "$http_referer" '  
                      '"$http_user_agent" "$http_x_forwarded_for"';   
    #访问日志   
    access_log   logs/access.log  main;   
    sendfile     on;   
    tcp_nopush   on;   
    #根据实际情况调整，如果server很多，就调大一点   
    server_names_hash_bucket_size 128; # this seems to be required for some vhosts   
  
    #这个例子是fastcgi的例子，如果用fastcgi就要仔细看   
    server { # php/fastcgi   
        listen       80;   
        #域名，可以有多个   
        server_name  domain1.com www.domain1.com;   
        #访问日志，和上面的级别不一样，应该是下级的覆盖上级的   
        access_log   logs/domain1.access.log  main;   
        root         html;   
  
        location / {   
            index    index.html index.htm index.php;   
        }   
  
        #所有php后缀的，都通过fastcgi发送到1025端口上   
         #上面include的fastcgi.conf在此应该是有作用，如果你不include，那么就把fastcgi.conf的配置项放在这个下面。   
        location ~ \.php$ {   
            fastcgi_pass   127.0.0.1:1025;   
        }   
    }   
  
    #这个是反向代理的例子   
    server { # simple reverse-proxy   
        listen       80;   
        server_name  domain2.com www.domain2.com;   
        access_log   logs/domain2.access.log  main;   
  
        #静态文件，nginx自己处理   
        location ~ ^/(images|javascript|js|css|flash|media|static)/  {   
                root    /var/www/virtual/big.server.com/htdocs;   
                #过期30天，静态文件不怎么更新，过期可以设大一点，如果频繁更新，则可以设置得小一点。   
                expires 30d;   
        }   
  
        #把请求转发给后台web服务器，反向代理和fastcgi的区别是，反向代理后面是web服务器，fastcgi后台是fasstcgi监听进程，当然，协议也不一样。   
        location / {   
            proxy_pass      http://127.0.0.1:8080;   
        }   
    }   
  
    #upstream的负载均衡，weight是权重，可以根据机器配置定义权重。据说nginx可以根据后台响应时间调整。后台需要多个web服务器。   
    upstream big_server_com {   
        server 127.0.0.3:8000 weight=5;   
        server 127.0.0.3:8001 weight=5;   
        server 192.168.0.1:8000;   
        server 192.168.0.1:8001;   
    }   
  
    server {   
        listen          80;   
        server_name     big.server.com;   
        access_log      logs/big.server.access.log main;   
  
        location / {   
                proxy_pass      http://big_server_com;   
        }   
    }   
} 
 }
