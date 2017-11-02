#!/usr/bin/python
# -*- coding: utf-8 -*-
from oslo_log import log as logging
from tempest import config

import paramiko
import select
import sys

LOG = logging.getLogger(__name__)
CONF = config.CONF

'''

#Logging in as root and execute the command stream but do not process
the return data,
so it is not possible to determine whether the request has been processed

[gaussdb]
gaussdba_user=gaussdba
gaussdb_pw = FusionSphere123
gaussdb_ip = 172.28.8.100
gaussdb_port = 5432
root_user = root
root_password = FusionSphere123
root_database = postgres
database_host = https://172.28.8.100:5431
database_url = /gaussdb/database

# a = GaussdbOperation()
# a.create_database('lgj1')
# CREATE TABLE lgjtablas(state_id INT2, state_name VARCHAR(50));
# a.create_table('lgj_table2','state_id INT2, state_name VARCHAR(50),
area_id INT2')
# INSERT INTO states VALUES(100, 'lgj_datas', 10);
# a.insert_data_into_table('lgj_table2',"123,111")
# SELECT * FROM lgj_table;
# a.query_data_from_table('lgj_table2')
# DROP databse lgj1;
# a.drop_database('lgj1')
# a.close_connection()

'''


class DataBaseUtils(object):
    ROOT_USER = CONF.gaussdb.root_user
    ROOT_PASSWORD = CONF.gaussdb.root_password
    ROOT_DATABASE = CONF.gaussdb.root_database
    HOST_IP = CONF.gaussdb.gaussdb_ip
    HOST_PORT = CONF.gaussdb.gaussdb_port
    GAUSSDB_PW = CONF.gaussdb.gaussdb_pw
    GAUSSDB_USER = CONF.gaussdb.gaussdba_user

    # my_temp_data
    # ROOT_USER = 'root'
    # ROOT_PASSWORD = 'IaaS@OS-CLOUD8!'
    # HOST_IP = '172.28.0.2'
    # HOST_PORT = 5432
    # ROOT_DATABASE = 'postgres'
    # GAUSSDB_USER = 'gaussdba'
    # GAUSSDB_PW = 'FusionSphere123'

    def __init__(self):
        self.t = paramiko.Transport((self.HOST_IP, 22))
        self.t.start_client()
        self.t.auth_password(self.ROOT_USER, self.ROOT_PASSWORD)
        self.chan = self.t.open_session()
        self.chan.get_pty()
        self.chan.invoke_shell()
        self.LoginDB = 'gsql -d %s -U %s -W %s -p %s\r' % (
            self.ROOT_DATABASE, self.GAUSSDB_USER, self.GAUSSDB_PW, self.
            HOST_PORT)
        self.CmdList = ['su gaussdba\r', self.LoginDB,
                        'SELECT * FROM SERVICES;\r', 'q', '\q\r', 'exit\r']

    def spawn(self, ResList=None):
        ResList = []
        for cmd in self.CmdList:
            while True:
                r_list, w_list, error = select.select(
                    [self.chan, sys.stdin, ], [], [], 1)
                if self.chan in r_list:
                    try:
                        x = self.chan.recv(1024)
                        if len(x) == 0:
                            break
                        ResList.append(str(x))
                    except OSError:
                        break
                else:
                    break
            self.chan.sendall(cmd)
        LOG.info("cmd: %s send end!" % repr(self.CmdList))
        return ResList

    def create_database(self, database_name):
        try:
            CREATEDB = "CREATE DATABASE %s;\r" % database_name
            self.CmdList = ['su gaussdba\r', self.LoginDB,
                            CREATEDB, 'q', '\q\r', 'exit\r']
            self.spawn()
            LOG.info("CREATE  DATABASE %s SUCCESS" % (database_name))
        except Exception as e:
            LOG.warn("CREATE DATABASE %s FAILED. %s" % (database_name, str(e)))
            self.close_connection()

    def create_table(self, table_name, table_structure):
        try:
            create_table_cmd = "CREATE TABLE %s(%s);\r" % (
                table_name, table_structure)
            show_table_cmd = '\d %s\r' % table_name
            self.CmdList = ['su gaussdba\r', self.LoginDB,
                            create_table_cmd, show_table_cmd, '\q\r', 'exit\r']
            self.spawn()
            LOG.info("CREATE  TABLE %s SUCCESS" % (table_name))
        except Exception as e:
            LOG.warn("CREATE TABLE %s FAILED. %s" % (table_name, str(e)))
            self.close_connection()

    def query_data_from_table(self, table_name):
        try:
            query_cmd = "SELECT * FROM %s;\r" % table_name
            self.CmdList = ['su gaussdba\r',
                            self.LoginDB, query_cmd, '\q\r', 'exit\r']
            self.spawn()
            LOG.info("SELECT * FROM %s SUCCESS" % (table_name))
        except Exception as e:
            LOG.warn("SELECT * FROM %s FAILED. %s" % (table_name, str(e)))
            self.close_connection()

    def insert_data_into_table(self, table_name, data):
        try:
            insert_cmd = "INSERT INTO %s VALUES(%s);" % (table_name, data)
            self.CmdList = ['su gaussdba\r', self.LoginDB,
                            insert_cmd, 'q', '\q\r', 'exit\r']
            self.spawn()
            LOG.info("INSERT INTO %s VALUES(%s)" % (table_name, data))
        except Exception as e:
            LOG.warn("INSERT FAILED %s VALUES(%s)" %
                     (table_name, data, str(e)))
            self.close_connection()

    def drop_database(self, database_name):
        try:
            DropDB = "DROP DATABASE %s;\r" % database_name
            self.CmdList = ['su gaussdba\r', self.LoginDB,
                            DropDB, 'q', '\q\r', 'exit\r']
            self.spawn()
            LOG.info("DROP DATABASE %s SUCCESS" % (database_name))
        except Exception as e:
            LOG.warn("DROP DATABASE %s FAILED. %s" % (database_name, str(e)))
            self.close_connection()

    def close_connection(self):
        self.chan.close()
        self.t.close()

