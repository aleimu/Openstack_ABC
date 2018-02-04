#!/usr/bin/env python
#-*- coding:utf-8 -*-

import paramiko
import os
import stat

"""
scp -r root@172.28.0.2:/usr/lib64/python2.7/site-packages/sqlalchemy/ /usr/lib64/python2.7/site-packages/
scp -r root@172.28.0.2:/usr/lib64/python2.7/site-packages/psycopg2/ /usr/lib64/python2.7/site-packages/
scp root@172.28.0.2:/usr/lib64/libpq.so.5.5 /usr/lib64/
scp root@172.28.0.2:/usr/lib64/libpq.so.5 /usr/lib64/
scp root@172.28.0.2:/usr/lib64/libpq.so /usr/lib64/
"""

root_user = 'root'
root_password = 'passwd'

transport = paramiko.Transport(('172.28.0.2', 22))
transport.connect(username=root_user, password=root_password)

sftp = paramiko.SFTPClient.from_transport(transport)
paths = ['/usr/lib64/python2.7/site-packages/sqlalchemy/',
         '/usr/lib64/python2.7/site-packages/psycopg2/',
         '/usr/lib64/libpq.so.5.5', '/usr/lib64/libpq.so.5', '/usr/lib64/libpq.so']

def get_all_files_in_remote_dir(sftp, remote_dir):
    all_files = list()
    if remote_dir[-1] == '/':
        remote_dir = remote_dir[0:-1]

    files = sftp.listdir_attr(remote_dir)
    for x in files:
        filename = remote_dir + '/' + x.filename
        if stat.S_ISDIR(x.st_mode):
            all_files.extend(get_all_files_in_remote_dir(sftp, filename))
        else:
            all_files.append(filename)
    return all_files

def put_all_files_in_local_dir(sftp,local_dir)
    for x in all_files:
        filename = x.split('/')[-1]
        local_filename = os.path.join(local_dir, filename)
        print u'Get文件%s传输中...' % filename
        sftp.get(x, local_filename)

