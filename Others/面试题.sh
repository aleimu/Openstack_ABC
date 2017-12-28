#RMI,socket,rpc,hessian,http比较
SOCKET使用时可以指定协议TCP,UDP等；
RIM使用JRMP协议，JRMP又是基于TCP/IP；
RPC底层使用SOCKET接口，定义了一套远程调用方法；
HTTP是建立在TCP上，不是使用SOCKET接口，需要连接方主动发数据给服务器，服务器无法主动发数据个客户端；
可以用socket实现HTTP；
其实符合HTTP规范的就是HTTP协议，不管用什么技术。
hessian是一套用于建立web service的简单的二进制协议，用于替代基于XML的web service，是建立在rpc上的，hessian有一套自己的序列化格式将数据序列化成流，然后通过http协议发送给服务器，看源码发现其实是使用
HttpURLConnection和servlet建立连接，然后发送流

#Python中关于XML-RPC原理 SimpleXMLRPCServer模块
http://www.cnblogs.com/wanghaoran/p/3189017.html


#http://www.cnblogs.com/tiwlin/archive/2011/12/25/2301305.html 
TCP是主机对主机层的传输控制协议，提供可靠的连接服务，采用三次握手确认建立一个连接:
位码即tcp标志位,有6种标示:SYN(synchronous建立联机) ACK(acknowledgement 确认) PSH(push传送) FIN(finish结束) RST(reset重置) URG(urgent紧急)
Sequence number(顺序号码) Acknowledge number(确认号码)
TCP/IP基础－－TCP三次握手
第一次握手：主机A发送位码为syn＝1,随机产生seq number=1234567的数据包到服务器，主机B由SYN=1知道，A要求建立联机；
第二次握手：主机B收到请求后要确认联机信息，向A发送ack number=(主机A的seq+1),syn=1,ack=1,随机产生seq=7654321的包
第三次握手：主机A收到后检查ack number是否正确，即第一次发送的seq number+1,以及位码ack是否为1，若正确，主机A会再发送ack number=(主机B的seq+1),ack=1，主机B收到后确认seq值与ack=1则连接建立成功。
完成三次握手，主机A与主机B开始传送数据。
 

在TCP/IP协议中，TCP协议提供可靠的连接服务，采用三次握手建立一个连接。 
第一次握手：建立连接时，客户端发送syn包(syn=j)到服务器，并进入SYN_SEND状态，等待服务器确认； 
第二次握手：服务器收到syn包，必须确认客户的SYN（ack=j+1），同时自己也发送一个SYN包（syn=k），即SYN+ACK包，此时服务器进入SYN_RECV状态； 第三次握手：客户端收到服务器的SYN＋ACK包，向服务器发送确认包ACK(ack=k+1)，此包发送完毕，客户端和服务器进入ESTABLISHED状态，完成三次握手。 完成三次握手，客户端与服务器开始传送数据.
 
实例:
IP 192.168.1.116.3337 > 192.168.1.123.7788: S 3626544836:3626544836
IP 192.168.1.123.7788 > 192.168.1.116.3337: S 1739326486:1739326486 ack 3626544837
IP 192.168.1.116.3337 > 192.168.1.123.7788: ack 1739326487,ack 1
第一次握手：192.168.1.116发送位码syn＝1,随机产生seq number=3626544836的数据包到192.168.1.123,192.168.1.123由SYN=1知道192.168.1.116要求建立联机;
第二次握手：192.168.1.123收到请求后要确认联机信息，向192.168.1.116发送ack number=3626544837,syn=1,ack=1,随机产生seq=1739326486的包;
第三次握手：192.168.1.116收到后检查ack number是否正确，即第一次发送的seq number+1,以及位码ack是否为1，若正确，192.168.1.116会再发送ack number=1739326487,ack=1，192.168.1.123收到后确认seq=seq+1,ack=1则连接建立成功。


1）在HTTP 1.0中，客户端的每次请求都要求建立一次单独的连接，在处理完本次请求后，就自动释放连接。
2）在HTTP 1.1中则可以在一次连接中处理多个请求，并且多个请求可以重叠进行，不需要等待一个请求结束后再发送下一个请求。
由于HTTP在每次请求结束后都会主动释放连接，因此HTTP连接是一种“短连接”，要保持客户端程序的在线状态，需要不断地向服务器发起连接请求。通常 的做法是即时不需要获得任何数据，客户端也保持每隔一段固定的时间向服务器发送一次“保持连接”的请求，服务器在收到该请求后对客户端进行回复，表明知道 客户端“在线”。若服务器长时间无法收到客户端的请求，则认为客户端“下线”，若客户端长时间无法收到服务器的回复，则认为网络已经断开。


tcp的keepalive是侧重在保持客户端和服务端的连接
http的keep-alive侧重于请求的复用，客户端发送connection:keep-alive头给服务端，且服务端也接受这个keep-alive的话，这个连接就可以复用了，一个http处理完之后，另外一个http数据直接从这个连接走了。
TCP的keepalive机制和HTTP的keep-alive机制是说的完全不同的两个东西，tcp的keepalive是在ESTABLISH状态的时候，双方如何检测连接的可用行。而http的keep-alive说的是如何避免进行重复的TCP三次握手和四次挥手的环节。

tcp的keepalive就是为了检测链接的可用性。主要调节的参数有三个：
tcp_keepalive_time // 距离上次传送数据多少时间未收到判断为开始检测
tcp_keepalive_intvl // 检测开始每多少时间发送心跳包
tcp_keepalive_probes // 发送几次心跳包对方未响应则close连接
