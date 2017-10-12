RabbitMQ 安装和几种消息队列的收发

安装{
#安装
ubuntu下安装 rabbitMQ:

#安装: sudo apt-get install rabbitmq-server 

启动rabbitmq web服务：
sudo invoke-rc.d rabbitmq-server stop
sudo invoke-rc.d rabbitmq-server start
service rabbitmq-server restart

#RabbitMQ提供了一些简单实用的命令用于管理服务器运行状态：
查看服务器运行状态: rabbitmq-server status
启动服务器:rabbitmq-server start
停止服务器:rabbitmq-server stop
 
查看服务器中所有的消息队列信息 :rabbitmqctl list_queues
查看服务器种所有的路由信息: rabbitmqctl list_exchanges
查看服务器种所有的路由与消息队列绑定信息 :rabbitmq list_bindings

启动web管理：sudo rabbitmq-plugins enable rabbitmq_management
root@ubuntu10:/usr/lib/rabbitmq/bin# ./rabbitmq-plugins enable rabbitmq-management

http://10.175.102.22:15672
vim /usr/lib/rabbitmq/bin/rabbitmq-defaults

#上面说的那些命令好像直接安装后都不能用........直接用下面的启动好了
/usr/lib/rabbitmq/bin/rabbitmq-server &
rabbitmq-plugins enable rabbitmq_management
http://10.175.102.22:15672

#远程访问rabbitmq，自己增加一个用户，步骤如下：
创建一个admin用户：sudo rabbitmqctl add_user admin admin123
设置该用户为administrator角色：sudo rabbitmqctl set_user_tags admin administrator
设置权限：sudo  rabbitmqctl  set_permissions  -p  '/'  admin '.' '.' '.'

重启rabbitmq服务：sudo service rabbitmq-server restart
之后就能用admin用户远程连接rabbitmq server了。

#遇到问题pika.exceptions.ProbableAccessDeniedError
被拒绝任何网络服务，对于权限都有设置的，比如mysql, redis，允许远程访问的时候，都需要自己配置的，所以要把使用的用户设置远程访问功能。参考如下博客操作：
http://www.cnblogs.com/yueerwanwan0204/p/5319474.html

#安装python rabbitMQ modul：
pip install pika

#默认端口：
4369 (epmd), 25672 (Erlang distribution)
5672, 5671 (AMQP 0-9-1 without and with TLS)
15672 (if management plugin is enabled)
61613, 61614 (if STOMP is enabled)
1883, 8883 (if MQTT is enabled)
}

简述{

RabbitMQ 主要模式:
1. 简单队列
2. exchange：
	direct 关键字类型
	topic 模糊匹配类型
	fanout 广播类型
}

样例{
# 参考博客：
# http://www.cnblogs.com/menkeyi/p/6971581.html
# http://www.cnblogs.com/pycode/p/RabbitMQ.html

简单队列{

# -*- coding:utf-8 -*-
import pika

# 消息持久化 消息确认机制使得客户端在崩溃的时候,服务端消息不丢失,但是如果rabbitmq奔溃了呢？该如何保证队列中的消息不丢失？
# 此就需要product在往队列中push消息的时候,告诉rabbitmq,此队列中的消息需要持久化,用到的参数：durable=True,再次强调,Producer和client都应该去创建这个queue,尽管只有一个地方的创建是真正起作用的
# 还有就是不能queue='helloworld'不能重复，重复报错；pika.exceptions.ChannelClosed: (406,
# "PRECONDITION_FAILED - parameters for queue 'hello' in vhost '/' not
# equivalent")

# 简单队列模型


def producer():
    # 认证的用户密码
    credentials = pika.PlainCredentials('lgj', 'lgj')
    # 远程主机配置
    parameters = pika.ConnectionParameters(
        '10.175.102.22', 5672, '/', credentials)

    # connection = pika.BlockingConnection(pika.ConnectionParameters(host='10.175.102.22', port=5672, ))     #定义未指定用户的连接池
    # channel = connection.channel()
    # 封装socket逻辑部分,拿到操作句柄
    connection = pika.BlockingConnection(parameters)
    channel = connection.channel()

    # 创建队列名字为helloworld,这个队列的名字一般是唯一的.消费者连接的信道名称也是这个
    channel.queue_declare(queue='helloworld', durable=True)
    # 注意：client端也需配置durable=True,否则将报错误：pika.exceptions.ChannelClosed: (406, "PRECONDITION_FAILED - parameters for queue 'test_persistent' in vhost '/' not equivalent")
    # 第一种工作状态
    # basic_publish设置队列
    # exchange='' 就是简单队列的意思,这里exchange不工作
    # routing_key='helloworld' ,exchange不工作了那么这里如何处理,就靠routing_key来找对应队列
    # bodybody='helloworld World!' 这就是传递的数据
    for x in range(10):
        print(" [x] Sent %s 'helloworld World!'" % x)
        channel.basic_publish(exchange='',
                              routing_key='helloworld',
                              body=str(x) + 'helloworld World!', properties=pika.BasicProperties(delivery_mode=2))
    channel.basic_qos(prefetch_count=1)  # 表示谁来谁取，不再按照奇偶数排列,不再均分
    connection.close()

    # channel.queue_declare(queue='test_persistent', durable=True)
    # for i in range(10):
    #     channel.basic_publish(exchange='', routing_key='test_persistent', body=str(
    #         i), properties=pika.BasicProperties(delivery_mode=2))
    #     print('send success msg[%s] to rabbitmq' % i)
    # connection.close()  # 关闭连接


def consumer():

    # 认证的用户密码
    credentials = pika.PlainCredentials('lgj', 'lgj')
    # 远程主机配置
    parameters = pika.ConnectionParameters(
        '10.175.102.22', 5672, '/', credentials)
    connection = pika.BlockingConnection(parameters)
    channel = connection.channel()

    # 消费者这里也创建一个队列,实际中生产者或消费者不一定谁先启动,如果消费者直接去没有创建的队列拿数据会直接报错
    channel.queue_declare(queue='helloworld', durable=True)
    # 注意：server端也需配置durable=True,否则将报错误：pika.exceptions.ChannelClosed: (406, "PRECONDITION_FAILED - parameters for queue 'test_persistent' in vhost '/' not equivalent")
    # 回调函数
    def callback(ch, method, properties, body):
        print(" [x] Received %r" % body)
        # no_ack=False 且想要启用有应答模式则必须在回调函数中加入下面的方法,不加的话消息会一直存在直到有应答正确执行:
        ch.basic_ack(delivery_tag=method.delivery_tag)

    # 获取队列中
    # queue='helloworld'获取helloworld队列的消息
    # no_ack=True(无应答)False(有应答):
    # 如果callback函数会执行很长时间或期间消费者机器出问题那么:
    # True(无应答)模式消息取从队列中取走后就会删除掉的,无法找回。
    # False(有应答)队列必须等待callback正确执行完在删除队列消息
    channel.basic_consume(callback,
                          queue='helloworld',
                          no_ack=False)

    print(' [*] Waiting for messages. To exit press CTRL+C')
    channel.start_consuming()

# 这个在测试的时候，应该先调用 producer() 等待中再调用 consumer()
# producer()
consumer()

}

fanout:广播类型{
#!/usr/bin/env python
# -*- coding:utf-8 -*-

# fanout模式:广播形式，生产者的消息会同时发送到所有消费者上


def producer():
    import pika
    import sys
    # 认证的用户密码
    credentials = pika.PlainCredentials('lgj', 'lgj')
    # 远程主机配置
    parameters = pika.ConnectionParameters(
        '10.175.102.22', 5672, '/', credentials)
    connection = pika.BlockingConnection(parameters)
    channel = connection.channel()

    # exchange创建一个交换机名为logs,并且设置类型为fanout
    channel.exchange_declare(exchange='logs',
                             type='fanout')

    message = 'exchange :type=fanout'
    # 指定名为logs的交换机,这里使用exchange,routing_key就不需要了。
    channel.basic_publish(exchange='logs',
                          routing_key='',
                          body=message)
    print(" [x] Sent %r" % message)
    connection.close()


def consumer():
    import pika
    # 认证的用户密码
    credentials = pika.PlainCredentials('lgj', 'lgj')
    # 远程主机配置
    parameters = pika.ConnectionParameters(
        '10.175.102.22', 5672, '/', credentials)
    connection = pika.BlockingConnection(parameters)
    channel = connection.channel()
    # 用意和之前一样
    channel.exchange_declare(exchange='logs',
                             type='fanout')

    # 创建一个队列
    result = channel.queue_declare(exclusive=True)
    # 给队列随机命名
    queue_name = result.method.queue

    # 将消费者队列和交换机(exchange='logs')进行绑定
    channel.queue_bind(exchange='logs',
                       queue=queue_name)
    print(' [*] Waiting for logs. To exit press CTRL+C')

    # 回调函数
    def callback(ch, method, properties, body):
        print(" [x] %r" % body)

    channel.basic_consume(callback,
                          queue=queue_name,
                          no_ack=True)
    # 阻塞函数
    channel.start_consuming()


#这个在测试的时候，应该先调用consumer() 等待中再调用producer()
producer()
# consumer()

}

direct:关键词模式{
# 关键之匹配（direct模式）
# 这个模式上在上图增加了route key 。生产者发送消息的时候会绑定一个route key，消费者订阅消息也必须绑定route key 。这样一来就可以使用同一个交换机但可以接受自己关心的消息
#!/usr/bin/env python
import pika


def producer():
    # 认证的用户密码
    credentials = pika.PlainCredentials('lgj', 'lgj')
    # 远程主机配置
    parameters = pika.ConnectionParameters(
        '10.175.102.22', 5672, '/', credentials)
    # 封装socket逻辑部分,拿到操作句柄
    connection = pika.BlockingConnection(parameters)
    channel = connection.channel()

    # 建立交换机和类型
    channel.exchange_declare(exchange='direct_logs',
                             type='direct')
    for x in range(5):

        # route key
        severity = 'info' + str(x)
        message = 'exchange:type direct' + str(x)
        # 发送消息
        channel.basic_publish(exchange='direct_logs',
                              routing_key=severity,
                              body=message)
        print(" [x] Sent %r:%r" % (severity, message))
    connection.close()


def consumer():
    # 认证的用户密码
    credentials = pika.PlainCredentials('lgj', 'lgj')
    # 远程主机配置
    parameters = pika.ConnectionParameters(
        '10.175.102.22', 5672, '/', credentials)
    connection = pika.BlockingConnection(parameters)
    channel = connection.channel()

    # 创建交换机和类型
    channel.exchange_declare(exchange='direct_logs',
                             type='direct')

    # 创建队列
    result = channel.queue_declare(exclusive=True)
    # 设定随机队列名
    queue_name = result.method.queue

    # 消费者一个队列可以绑定多个routekey
    severities = ['info1', 'info2', 'info9']

    # 循环多个routekey
    for severity in severities:
        # 绑定叫交换机、队列、routekey
        channel.queue_bind(exchange='direct_logs',
                           queue=queue_name,
                           routing_key=severity)

    print(' [*] Waiting for logs. To exit press CTRL+C')

    # 回调函数
    def callback(ch, method, properties, body):
        print(" [x] %r:%r" % (method.routing_key, body))

    # 指定回调函数
    channel.basic_consume(callback,
                          queue=queue_name,
                          no_ack=True)
    # 阻塞等待
    channel.start_consuming()

# 这个在测试的时候，应该先调用consumer() 等待中再调用producer()
producer()
# consumer()

}

topic:模糊匹配{
'''
topic(模糊匹配)
exchange type = topic

在topic类型下，可以让队列绑定几个模糊的关键字，之后发送者将数据发送到exchange，exchange将传入”路由值“和 ”关键字“进行匹配，匹配成功，则将数据发送到指定队列。
#匹配模式写在消费者中
abc.123.abc    abc.* -- 不匹配 ,* 表示只能匹配 一个 单词
abc.123.abc    abc.# -- 匹配 ，# 表示可以匹配 0 个 或 多个 单词
必须要有一个'.'来开始匹配
'''
import pika


def producer():
    # 认证的用户密码
    credentials = pika.PlainCredentials('lgj', 'lgj')
    # 远程主机配置
    parameters = pika.ConnectionParameters(
        '10.175.102.22', 5672, '/', credentials)
    # 封装socket逻辑部分,拿到操作句柄
    connection = pika.BlockingConnection(parameters)
    channel = connection.channel()

    # 建立交换机和类型
    channel.exchange_declare(exchange='topic_logs1',
                             type='topic')
    for x in range(5):

        # route key,必须要有一个'.'来开始匹配
        severity = 'info.' + str(x)
        message = 'exchange:type topic' + str(x)
        # 发送消息
        channel.basic_publish(exchange='topic_logs1',
                              routing_key=severity,
                              body=message)
        print(" [x] Sent %r:%r" % (severity, message))
    connection.close()


def consumer():
    # 认证的用户密码
    credentials = pika.PlainCredentials('lgj', 'lgj')
    # 远程主机配置
    parameters = pika.ConnectionParameters(
        '10.175.102.22', 5672, '/', credentials)
    connection = pika.BlockingConnection(parameters)
    channel = connection.channel()

    # 创建交换机和类型
    channel.exchange_declare(exchange='topic_logs1',
                             type='topic')

    # 创建队列
    result = channel.queue_declare(exclusive=True)
    # 设定随机队列名
    queue_name = result.method.queue

    # 消费者一个队列可以绑定多个routekey
    severities = ['info.*', 'info.1']

    # 循环多个routekey
    for severity in severities:
        # 绑定叫交换机、队列、routekey
        channel.queue_bind(exchange='topic_logs1',
                           queue=queue_name,
                           routing_key=severity)

    print(' [*] Waiting for logs. To exit press CTRL+C')

    # 回调函数
    def callback(ch, method, properties, body):
        print(" [x] %r:%r" % (method.routing_key, body))

    # 指定回调函数
    channel.basic_consume(callback,
                          queue=queue_name,
                          no_ack=True)
    # 阻塞等待
    channel.start_consuming()

# 这个在测试的时候，应该先调用consumer() 等待中再调用producer()
#producer()
consumer()

}

}
