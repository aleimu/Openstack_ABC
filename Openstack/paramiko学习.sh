paramiko的连接
#参考 http://python.jobbole.com/87088/
#http://www.cnblogs.com/jishuweiwang/p/5726286.html

使用paramiko模块有两种连接方式，一种是通过paramiko.SSHClient()函数，另外一种是通过paramiko.Transport()函数。

SSHClient{
##基于用户名密码连接
{
import paramiko

# 创建SSH对象
ssh = paramiko.SSHClient()
# 允许连接不在know_hosts文件中的主机
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
# 连接服务器
ssh.connect(hostname='172.25.50.13', port=22, username='work', password='123456')

# 执行命令
stdin, stdout, stderr = ssh.exec_command('ls -l')
# 获取命令结果
result = stdout.read()
print(result.decode())
# 关闭连接
ssh.close()
}

##基于公钥密钥连接
{
import paramiko

# 创建key文件
private_key = paramiko.RSAKey.from_private_key_file('/home/auto/.ssh/id_rsa')

# 创建SSH对象
ssh = paramiko.SSHClient()
# 允许连接不在know_hosts文件中的主机
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
# 连接服务器
ssh.connect(hostname='172.25.50.13', port=22, username='work', key=private_key)

# 执行命令
stdin, stdout, stderr = ssh.exec_command('df -h')
# 获取命令结果
result = stdout.read()

# 关闭连接
ssh.close()
}

}

SFTPClient{
#paramiko.Transport方式
import paramiko
t = paramiko.Transport(("主机","端口"))
t.connect(username = "用户名", password = "口令")
#t.connect(username = "用户名", password = "口令", hostkey="密钥")

##基于用户名密码连接
{
#基于用户名密码实现上传下载
import paramiko

# 创建transport
transport = paramiko.Transport(('172.25.50.13',22))
transport.connect(username='work',password='123456')

# 创建sftpclient，并基于transport连接，把他俩进行绑定
sftp = paramiko.SFTPClient.from_transport(transport)
# 将location.py 上传至服务器 /tmp/test.py
sftp.put('/tmp/location.py', '/tmp/test.py')
# 将remove_path 下载到本地 local_path
sftp.get('remove_path', 'local_path')

# 关闭session
transport.close()
}

##基于公钥密钥连接
{
#基于公钥密钥上传下载
import paramiko
# 创建key文件
private_key = paramiko.RSAKey.from_private_key_file('/home/auto/.ssh/id_rsa')

transport = paramiko.Transport(('172.25.50.13', 22))
transport.connect(username='work', pkey=private_key )

sftp = paramiko.SFTPClient.from_transport(transport)
# 将location.py 上传至服务器 /tmp/test.py
sftp.put('/tmp/location.py', '/tmp/test.py')
# 将remove_path 下载到本地 local_path
sftp.get('remove_path', 'local_path')

transport.close()
}


}


dome1{

import paramiko
#paramiko.util.log_to_file('/tmp/sshout')
def ssh2(ip,username,passwd,cmd):
    try:
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(ip,22,username,passwd,timeout=5)
        stdin,stdout,stderr = ssh.exec_command(cmd)
#           stdin.write("Y")   #简单交互，输入 ‘Y’
        print stdout.read()
#        for x in  stdout.readlines():
#          print x.strip("n")
        print '%stOKn'%(ip)
        ssh.close()
    except :
        print '%stErrorn'%(ip)
ssh2("192.168.0.102","root","361way","hostname;ifconfig")
ssh2("192.168.0.107","root","123456","ifconfig")

'''
stdin.write部分是用于交互情况下，通过该命令可以执行交互。注意这里可能会引起歧义，这里的交互并不是ssh连接过程中出现的让输入yes的交互，因为paramiko模块在连接过程中会自动处理好yes确认。这里的交互是指后面的cmd需要的执行的程序可能出现交互的情况下，可以通过该参数进行交互。

stdout标准输出，在输出内容比较少时，可以通过直接使用read读取出所有的输出；但在输出内容比较多时，建议通过按行读取进行处理。不过按行读取时，每行结尾会有换行符n，这样输出的结果很不美观。可以通过strip进行字符串的处理。
'''
}

dome2{
#不仅要实现单纯的执行命令，还要在执行命令之后，上传一个文件，上传文件之后依然能执行命令。--->这样能ssh登陆数据库手动操作数据库吗？
# 自己封装一个类似SSHClient的类
import paramiko
 
class SSHConnection(object):
    def __init__(self, host='172.25.50.13', port=22, username='work',pwd='123456'):
        self.host = host
        self.port = port
        self.username = username
        self.pwd = pwd
        self.__k = None
 
    def run(self):
        self.connect()
        pass
        self.close()
 
    def connect(self):
        # 创建transport
        transport = paramiko.Transport((self.host,self.port))
        # 启动session
        transport.connect(username=self.username,password=self.pwd)
        self.__transport = transport
 
    def close(self):
        self.__transport.close()
 
    def cmd(self, command):
        ssh = paramiko.SSHClient()
        ssh._transport = self.__transport
        # 执行命令
        stdin, stdout, stderr = ssh.exec_command(command)
        # 获取命令结果
        result = stdout.read()
        return result
 
    def upload(self,local_path, target_path):
        # 连接，上传
        sftp = paramiko.SFTPClient.from_transport(self.__transport)
        # 将location.py 上传至服务器 /tmp/test.py
        sftp.put(local_path, target_path)
 
ssh = SSHConnection()
ssh.connect()
# 执行命令
r1 = ssh.cmd('df')
print(r1.decode())
# 上传文件
ssh.upload('s2.py', "/home/alex/s7.py")
 
ssh.close()
}

dome3{
#python 建立ssh连接 并登陆mysql
#!/usr/bin/python
import paramiko
ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect("10.10.1.1",22,"root","1111")
stdin, stdout, stderr = ssh.exec_command("mysql -uroot -p123456 -Dmysql -e 'select user from user'")
print stdout.readlines()
ssh.close()

}

dome4{
#可以利用多进程或线程可以批量执行命令
import paramiko
import threading
 
def ssh_cmd(ip,port,username,passwd,cmd):
  ssh = paramiko.SSHClient()
  ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
  ssh.connect(ip,port,username,passwd)
  for m in cmd:
    stdin, stdout, stderr = ssh.exec_command(m)
    print(stdout.readlines())
  ssh.close()
 
if __name__=='__main__':
  cmd = ['ls','ifconfig']  
  a=threading.Thread(target=ssh_cmd,args=(ip,port,username,passwd,cmd))
  a.start()
  a.join()
  
  
}

dome5{
ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect('127.0.0.1',username='root',password='passw0rd')

output=""
err_str=""

#cli_channel=ssh.get_transport().open_channel('session')
#cli_channel.settimeout(3600)
#cli_channel.get_pty()
#cli_channel.invoke_shell()

stdin, stdout, stderr = ssh.exec_command("/usr/bin/cp /root/names.txt /tmp/names.txt.before",get_pty=True)
#stdin, stdout, stderr=ssh.exec_command("/usr/bin/cp /root/names.txt /tmp/names.txt.before; echo good bye; sleep 1; ls -al /dev; grep -Ev '^[[:space:]]*#' /usr/local/src/py/network/paramiko_2.py",get_pty=True)

output=stdout.channel.recv(8192).decode()
try:
    while not stdout.channel.exit_status_ready():
        rl, wl, xl = select.select([stdout.channel], [], [], 0.0)
        if len(rl) > 0:
            output+=stdout.channel.recv(8192).decode()
except socket.timeout:
    print("Operation time out. Ouput might not be complete.")

rc=stdout.channel.recv_exit_status()
print(rc)
print(output)
print(err_str)

print ("Command done, closing SSH connection")
ssh.close()
}

dome6{
ssh = paramiko.SSHClient()

ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect('127.0.0.1',username='root',password='passw0rd')
output=""
err_str=""

cli_channel=ssh.get_transport().open_channel('session')
cli_channel.settimeout(600)


try:
    out=cli_channel.recv(512)
    while len(out) > 0:
        output+=out.decode()
        out=cli_channel.recv(512)

    out=cli_channel.recv_stderr(512)
    while len(out) > 0:
        err_str+=out.decode()
        out=cli_channel.recv_stderr(512)

except socket.timeout:
        print("Operation time out. Ouput might not be complete.")
rc=cli_channel.recv_exit_status()
print(rc)
print(output)
print(err_str)

print ("Command done, closing SSH connection")
ssh.close()
}

疑问{
1 ssh.connect是否会保持状态，以后得每一次ssh.exec_command都能继承上一次的环境？
	import paramiko
	ssh = paramiko.SSHClient()
	ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
	ssh.connect("10.10.1.1",22,"root","1111")
	stdin, stdout, stderr = ssh.exec_command("mysql -uroot -p123456 -Dmysql -e 'select user from user'")
#答
exec_command为单个会话，执行完成之后会回到登录时的缺省目录。
比如执行下面两句。
stdin, stdout, stderr = ssh.exec_command("cd  /root/paramiko;mkdir %s" %name)
stdin,stdout,stderr = ssh.exec_command('mkdir haha') #haha目录最终是在缺省的/root目录下新建的，而不是/root/paramiko目录。

2 sudo的用法

stdin, stdout, stderr = s.exec_command(‘sudo -S %s’ % cmd)
stdin.write(‘%s’ % password)
stdin.flush()
out = stdout.readlines()

3 paramiko.channel.Channel 是否能完成 1 的需求？
}
