#!/usr/bin/env python
# -*-coding:utf-8-*-
import subprocess
import paramiko


class GetGaussdbaLibs(object):
    def __init__(self, host=None, log_path="paramiko.log"):
        self.host = host
        self.port = 22
        self.username = None
        self.password = None
        self.timeout = 30
        self.channel = None
        self.sftp = None
        paramiko.util.log_to_file(log_path)
        self.ssh = paramiko.SSHClient()
        self.ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    def connect(self, username, password, **kwargs):

        self.username = username
        self.password = password
        self.host = kwargs.pop('host', self.host)
        self.port = kwargs.pop('port', self.port)
        self.timeout = kwargs.pop('timeout', self.timeout)
        self.ssh.connect(self.host, self.port, self.username, self.password,
                         look_for_keys=False, **kwargs)
        self.channel = self.ssh.invoke_shell(width=320)
        self.channel.settimeout(self.timeout)
        t = paramiko.Transport((self.host, self.port))
        t.connect(username=self.username, password=self.password)
        self.sftp = paramiko.SFTPClient.from_transport(t)

    def close(self):
        print('[SSH] disconnect from %s.' % self.host)
        self.ssh.close()

    def get_gaussdba_lib_remote(self, remote_dir):
        self._ensure_connect()
        # get all files in remote_dir_tar
        all_files = self.exec_cmd(
            'tar -czf /tmp/remote_temp.tar.gz  ' + remote_dir)
        print(all_files)
        self.sftp.get('/tmp/remote_temp.tar.gz', '/tmp/local_temp.tar.gz')

        tarcmd = 'tar xf /tmp/local_temp.tar.gz'
        cp_cmd = 'alias cp=cp;cp -r usr / ;alias cp="cp -i";'
        ret = subprocess.call(tarcmd, shell=True)
        if ret == 0:
            ret = subprocess.call(cp_cmd, shell=True)
            if ret == 0:
                print('tar and cp files: %s success' % remote_dir)
            else:
                raise Exception('Failed to get database lib')

        subprocess.call('rm -rf usr', shell=True)

    def _ensure_connect(self):
        if not self.sftp or self.sftp.sock.closed:
            t = paramiko.Transport((self.host, self.port))
            t.connect(username=self.username, password=self.password)
            self.sftp = paramiko.SFTPClient.from_transport(t)

    def exec_cmd(self, cmd):
        stdin, stdout, stderr = self.ssh.exec_command(cmd)
        err_info = stderr.readlines()
        if err_info:
            print('execute %s failed: %s' % (cmd, err_info))
            return []
        else:
            return stdout.readlines()




def get_gaussdba_lib_remote():
    ssh = GetGaussdbaLibs('172.28.0.2')
    ssh.connect('root', 'Huawei@CLOUD8!')
    paths = ['/usr/lib64/python2.7/site-packages/sqlalchemy',
             '/usr/lib64/python2.7/site-packages/psycopg2',
             '/usr/lib64/libpq.so.5.5', '/usr/lib64/libpq.so.5', '/usr/lib64/libpq.so']
    for path in paths:
        ssh.get_gaussdba_lib_remote(path)
    ssh.close()

if __name__ == '__main__':
    get_gaussdba_lib_remote()
