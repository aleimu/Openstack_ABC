# IO多路复用实现一个读写分离的、支持多客户端的连接请求

# select实现

import socket
import queue
from select import select

SERVER_IP = ('127.0.0.1', 8888)

# 保存客户端发送过来的消息,将消息放入队列中
message_queue = {}
input_list = []
output_list = []

if __name__ == "__main__":
    server = socket.socket()
    server.bind(SERVER_IP)
    server.listen(10)
    # 设置为非阻塞
    server.setblocking(False)

    # 初始化将服务端加入监听列表
    input_list.append(server)

    while True:
        # 开始 select 监听,对input_list中的服务端server进行监听
        stdinput, stdoutput, stderr = select(input_list, output_list,
                                             input_list)

        # 循环判断是否有客户端连接进来,当有客户端连接进来时select将触发
        for obj in stdinput:
            # 判断当前触发的是不是服务端对象, 当触发的对象是服务端对象时,说明有新客户端连接进来了
            if obj == server:
                # 接收客户端的连接, 获取客户端对象和客户端地址信息
                conn, addr = server.accept()
                print("Client {0} connected! ".format(addr))
                # 将客户端对象也加入到监听的列表中, 当客户端发送消息时 select 将触发
                input_list.append(conn)
                # 为连接的客户端单独创建一个消息队列，用来保存客户端发送的消息
                message_queue[conn] = queue.Queue()

            else:
                # 由于客户端连接进来时服务端接收客户端连接请求，将客户端加入到了监听列表中(input_list)，客户端发送消息将触发
                # 所以判断是否是客户端对象触发
                try:
                    recv_data = obj.recv(1024)
                    # 客户端未断开
                    if recv_data:
                        print("received {0} from client {1}".format(
                            recv_data.decode(), addr))
                        # 将收到的消息放入到各客户端的消息队列中
                        message_queue[obj].put(recv_data)

                        # 将回复操作放到output列表中，让select监听
                        if obj not in output_list:
                            output_list.append(obj)

                except ConnectionResetError:
                    # 客户端断开连接了，将客户端的监听从input列表中移除
                    input_list.remove(obj)
                    # 移除客户端对象的消息队列
                    del message_queue[obj]
                    print("\n[input] Client  {0} disconnected".format(addr))

                    # 如果现在没有客户端请求,也没有客户端发送消息时，开始对发送消息列表进行处理，是否需要发送消息
        for sendobj in output_list:
            try:
                # 如果消息队列中有消息,从消息队列中获取要发送的消息
                if not message_queue[sendobj].empty():
                    # 从该客户端对象的消息队列中获取要发送的消息
                    send_data = message_queue[sendobj].get()
                    sendobj.sendall(send_data)
                else:
                    # 将监听移除等待下一次客户端发送消息
                    output_list.remove(sendobj)

            except ConnectionResetError:
                # 客户端连接断开了
                del message_queue[sendobj]
                output_list.remove(sendobj)
                print("\n[output] Client  {0} disconnected".format(addr))

# epoll实现实例
"""
使用 epoll 机制的程序通常按照如下流程执行。

1. 创建 epoll 对象。
2. 告知该 epoll 对象需要在特定套接字上监听的某些事件。（即，注册事件）
3. 询问 epoll 对象哪些套接字在最近一次查询后又有新的已注册的事件到来。
4. 在第3步中有事件到来的那些套接字上进行操作。
5. 告知 epoll 对象修改监听的套接字列表或事件类型。
6. 重复 3-5 步，直到程序结束。
7. 销毁 epoll 对象。

Linux 2.6 提供了很多管理异步套接字的机制，其中 Python API 是 select, poll 和 epoll，epoll 和 poll 比 select 好，
因为此时 Python 程序不必为了自己感兴趣的事件而去检查每个套接字，而是依赖操作系统获知哪些套接字有自己感兴趣的事件。
另外，epoll 又比 poll 好，因为 Python 程序不要求操作系统检测每个套接字来获取自己感兴趣的事件，而是在某些事件发生时 Linux 跟踪这些事件。
然后返回事件列表，所以 epoll 在具有大量（数千的并发连接）并发连接时更高效，可扩展性更强

import select 导入select模块
epoll = select.epoll() 创建一个epoll对象
epoll.register(文件句柄,事件类型) 注册要监控的文件句柄和事件
事件类型:
    select.EPOLLIN    可读事件
    select.EPOLLOUT   可写事件
    select.EPOLLERR   错误事件
    select.EPOLLHUP   客户端断开事件
    epoll.unregister(文件句柄)   销毁文件句柄
    epoll.poll(timeout)  当文件句柄发生变化，则会以列表的形式主动报告给用户进程,timeout
                         为超时时间，默认为-1，即一直等待直到文件句柄发生变化，如果指定为1
                         那么epoll每1秒汇报一次当前文件句柄的变化情况，如果无变化则返回空
    epoll.fileno() 返回epoll的控制文件描述符(Return the epoll control file descriptor)
    epoll.modfiy(fineno,event) fineno为文件描述符 event为事件类型  作用是修改文件描述符所对应的事件
    epoll.fromfd(fileno) 从1个指定的文件描述符创建1个epoll对象
    epoll.close()   关闭epoll对象的控制文件描述符

"""

#!/usr/bin/env python
# -*- coding:utf-8 -*-

import socket
import select
import queue

# 创建socket对象
serversocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
# 设置IP地址复用
serversocket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
# ip地址和端口号
server_address = ("127.0.0.1", 8888)
# 绑定IP地址
serversocket.bind(server_address)
# 监听，并设置最大连接数
serversocket.listen(10)
print("服务器启动成功，监听IP：", server_address)
# 服务端设置非阻塞
serversocket.setblocking(False)
# 超时时间
timeout = 10
# 创建epoll事件对象，后续要监控的事件添加到其中
epoll = select.epoll()
# 注册服务器监听fd到等待读事件集合
epoll.register(serversocket.fileno(), select.EPOLLIN)
# 保存连接客户端消息的字典，格式为{}
message_queues = {}
# 文件句柄到所对应对象的字典，格式为{句柄：对象}
fd_to_socket = {serversocket.fileno(): serversocket, }
try:
    while True:
        # 轮询注册的事件集合，返回值为[(文件句柄，对应的事件)，(...),....]
        events = epoll.poll(timeout)
        for fd, event in events:
            socket = fd_to_socket[fd]
            # 如果活动socket为当前服务器socket，表示有新连接
            if socket == serversocket:
                connection, address = serversocket.accept()
                print("新连接：", address)
                # 新连接socket设置为非阻塞
                connection.setblocking(False)
                # 注册新连接fd到待读事件集合
                epoll.register(connection.fileno(), select.EPOLLIN)
                # 把新连接的文件句柄以及对象保存到字典
                fd_to_socket[connection.fileno()] = connection
                # 以新连接的对象为键值，值存储在队列中，保存每个连接的信息
                message_queues[connection] = queue.Queue()
            # 关闭事件
            elif event & select.EPOLLHUP:
                print('client close')
                # 在epoll中注销客户端的文件句柄
                epoll.unregister(fd)
                # 关闭客户端的文件句柄
                fd_to_socket[fd].close()
                # 在字典中删除与已关闭客户端相关的信息
                del fd_to_socket[fd]
            # 可读事件
            elif event & select.EPOLLIN:
                # 接收数据
                data = socket.recv(1024)
                if data:
                    print("收到数据：", data, "客户端：", socket.getpeername())
                    # 将数据放入对应客户端的字典
                    message_queues[socket].put(data)
                    # 修改读取到消息的连接到等待写事件集合(即对应客户端收到消息后，再将其fd修改并加入写事件集合)
                    epoll.modify(fd, select.EPOLLOUT)
            # 可写事件
            elif event & select.EPOLLOUT:
                try:
                    # 从字典中获取对应客户端的信息
                    msg = message_queues[socket].get_nowait()
                except queue.Empty:
                    print(socket.getpeername(), " queue empty")
                    # 修改文件句柄为读事件
                    epoll.modify(fd, select.EPOLLIN)
                else:
                    print("发送数据：", data, "客户端：", socket.getpeername())
                    # 发送数据
                    socket.send(msg)
finally:
    # 在epoll中注销服务端文件句柄
    epoll.unregister(serversocket.fileno())
    # 关闭epoll
    epoll.close()
    # 关闭服务器socket
    serversocket.close()



#!/usr/bin/env python
#-*- coding:utf-8 -*-
# 客户端代码
import socket

#创建客户端socket对象
clientsocket = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
#服务端IP地址和端口号元组
server_address = ('127.0.0.1',8888)
#客户端连接指定的IP地址和端口号
clientsocket.connect(server_address)

while True:
    #输入数据
    data = input('please input:')
    #客户端发送数据
    clientsocket.sendall(data)
    #客户端接收数据
    server_data = clientsocket.recv(1024)
    print ('客户端收到的数据：' , server_data)
    #关闭客户端socket
    clientsocket.close()

