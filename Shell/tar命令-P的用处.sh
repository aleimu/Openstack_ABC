tar: Removing leading / from member names {

首先应该明确：*nix系统中，使用tar对文件打包时，一般不建议使用绝对路径。

通常是在两台环境相似的机器上进行同步复制的时候，才有需要使用绝对路径进行打包。使用绝对路径打包时如果不指定相应的参数，tar会产生一句警告信息：'tar: Removing leading / from member names'，并且实际产生的压缩包会将绝对路径转化为相对路径。

比如：
root@queen ~ # tar -czvf robin.tar.gz /home/robin
tar: Removing leading / from member names
/home/robin/
/home/robin/file1
/home/robin/file2
/home/robin/file3
root@queen ~ # tar -tzvf robin.tar.gz
drwxr-xr-x robin/root 0 2009-11-10 18:51:31 home/robin/
-rw-r--r-- robin/root 0 2009-11-10 18:51:28 home/robin/file1
-rw-r--r-- robin/root 0 2009-11-10 18:51:30 home/robin/file2
-rw-r--r-- robin/root 0 2009-11-10 18:51:31 home/robin/file3
root@queen ~ #

这样的一个压缩包，如果我们再去解开，就会当前目录（也即此例中的'~'）下再新建出'./home/robin/' 两级目录。对于这样的压缩包，解压方法是使用参数 '-C'指解压的目录为根目录（'/'）：tar -xzvf robin.tar.gz -C /

更为可靠的方法是在打包和解开的时候都使用参数 -P：
root@queen ~ # tar -czvPf robin.tar.gz /home/robin/
/home/robin/
/home/robin/file1
/home/robin/file2
/home/robin/file3
root@queen ~ # tar tzvf robin.tar.gz
drwxr-xr-x robin/root 0 2009-11-10 18:51:31 /home/robin/
-rw-r--r-- robin/root 0 2009-11-10 18:51:28 /home/robin/file1
-rw-r--r-- robin/root 0 2009-11-10 18:51:30 /home/robin/file2
-rw-r--r-- robin/root 0 2009-11-10 18:51:31 /home/robin/file3
root@queen ~ # tar -xzvPf robin.tar.gz
/home/robin/
/home/robin/file1
/home/robin/file2
/home/robin/file3

#打包和解开的时候都使用参数 -P 以根路径压缩、以根路径解压，直接覆盖原根路径下的文件，不用二次copy

def get_gaussdba_lib_remote(self, remote_dir):
    self._ensure_connect()
    # get all files in remote_dir_tar
    all_files = self.exec_cmd(
        'tar -czf /tmp/remote_temp.tar.gz  ' + remote_dir)
    print(all_files)
    self.sftp.get('/tmp/remote_temp.tar.gz', '/tmp/local_temp.tar.gz')

    tarcmd = 'tar xf /tmp/local_temp.tar.gz'   #在哪里执行就会解压到哪里
    cp_cmd = 'alias cp=cp;cp -r usr / ;alias cp="cp -i";'
    ret = subprocess.call(tarcmd, shell=True)
    if ret == 0:
        ret = subprocess.call(cp_cmd, shell=True)
        if ret == 0:
            print('tar and cp files: %s success' % remote_dir)
        else:
            raise Exception('Failed to get database lib')

    subprocess.call('rm -rf usr', shell=True)
 
#使用 -P 
 
def get_gaussdba_lib_remote(self, remote_dir):
    self._ensure_connect()
    # get all files in remote_dir_tar
    all_files = self.exec_cmd(
        'tar -czPf /tmp/remote_temp.tar.gz  ' + remote_dir)
    print(all_files)
    self.sftp.get('/tmp/remote_temp.tar.gz', '/tmp/local_temp.tar.gz')

    tarcmd = 'tar xPf /tmp/local_temp.tar.gz'
    ret = subprocess.call(tarcmd, shell=True)
    if ret == 0:
        print('Get gaussdba libs %s success' % remote_dir)
    else:
        raise Exception('Failed to get database lib')
 
}
