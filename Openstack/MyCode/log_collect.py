#!/usr/bin/python
# -*- coding:UTF-8 -*-

import os
import shutil
import time
import logging
from watchdog.observers import Observer
from watchdog.events import (
    LoggingEventHandler, FileSystemEventHandler, FileSystemMovedEvent)
from watchdog.events import RegexMatchingEventHandler
import traceback
import linecache
import re
import requests
import subprocess


baseDir = '/var/log/fusionsphere/operate/'
filterfile = [baseDir + 'nova-api/nova-api.log',
              baseDir + 'cinder-api/cinder-api.log',
              baseDir + 'neutron-api/neutron-api.log',
              baseDir + 'glance-api/glance-api.log']

filterfile = [baseDir + 'nova-api/nova-api.log']

# 全部正则表达式
re_update = '(?P<domain_name>(\w[\-\_\/A-Za-z0-9]+))\s(?P<domain_id>(\w[' \
    '\-\_\/A-Za-z0-9]+))\s(?P<project_id>(\w*[\-\_\/A-Za-z0-9]+))\s' \
            '(?P<user_name>(\w[\-\_\/A-Za-z0-9]+))\s(?P<user_id>(\w[\-\_\/A-' \
            'Za-z0-9]+))\s(?P<service_type>ECS|VPC|RTS|EVS|IMS|ULB|DEH|' \
            'ELB)\s(?P<resource_type>(\w[\-\_\/A-Za-z0-9]+)|\-)\s(?P<re' \
            'source_name>(\w[\-\_\/A-Za-z0-9]+)|\-)\s(?P<resource_id>(\w' \
            '[\-\_\/A-Za-z0-9]+))\s(?P<trace_name>(\w*[\-\_\/A-Za-z0-9]' \
            '+))\s(?P<trace_rating>(\w*[\-\_\/A-Za-z0-9]+))\s(?P<trace_' \
            'type>(\w*[\-\_\/A-Za-z0-9]+)|\-)\s(?P<api_version>([V|v][1-9' \
            '][\.0-9]*))\s((?P<source_ip>\-|((?:[0-9]{1,3}\.){3}[0-9]{1,' \
    '3}))\s)*((?P<request_id>(req-[\-A-Za-z0-9]+)|\-)(\s))*((?P' \
            '<assumed_by>\-|{.+})*)(\s*)((?P<hw_context>\-|{.+})*)'

re_cts_out = '(\d.*\[.*\]\[.+\])\s(?P<http_method>PUT|DELETE|POST|' \
             'PATCH)\s(http://|https://[a-zA-Z0-9]+[a-zA-Z0-9-/?.]+' \
             '[:]*[\d]*[\/\w-]*[\?&\w=]*)\s(HTTP[S]?\/1\.[0-2])\s' \
             '(?P<code>\d{3})\s(\d*|\-)\s(?P<request>{.+}|\-)\s(' \
             '?P<response>{.+}|\-)\s(?P<time>\d+)\s%s' % re_update

API_ERROR = "API error"
IAM_AUTH_FAIL = "username and password are incorrect for iam identify"
CTS_AUTH_FAIL = "username and password are incorrect for cts identify"
NOT_FOUND = "The tracker does not exist. Check whether the tracker name is " \
            "correct or CTS has been enabled. error_code=404"

# conf
iam_address = '172.30.48.180'
iam_port = '31943'
cts_domain = 'op_svc_fsp'
cts_user = 'op_svc_fsp'
cts_password = 'Huawei@123'
cts_address = '172.30.49.17'
send_req = 'true'
local_cache_file_path = './local_body_cache.log'


class report_files_change(FileSystemEventHandler):
    def __init__(self, pattern='*'):
        self.pattern = pattern
        self.token = None
        self.location = '定位信息'
        self.resource = '告警源信息'
        self.log_re = re.compile(re_cts_out)
        # 上报通信是否正常，正常则直接上报，False不正常则写入文件
        self.post_flag = False
        self.get_token_headers = {'Content-Type': 'application/json'}
        self.post_headers = {'Content-Type': 'application/json',
                             "X-Auth-Token": self.token}
        self.get_token_payload = '{"auth":{"identity":{"methods":' \
                                 '["password"],"password":{"user":' \
                                 '{"name":"%s","password":"%s","domain":' \
                                 '{"name":"%s"}}}},"scope":{"domain":' \
                                 '{"name":"%s"}}}}' % (cts_user, cts_password,
                                                    cts_domain, cts_domain)
        print("self.get_token_payload:",self.get_token_payload)
        self.get_token_url = 'https://%s:%s/v3/auth/tokens' % (iam_address,
                                                               iam_port)
        # 初始化filecache的map用来存放需要上报的文件名和对应行
        self.filecache = {}
        for x in filterfile:
            self.old_cache = linecache.getlines(x)
            self.filecache[x] = self.old_cache
        #print("init filecache :", self.filecache)

    # 主要函数
    def get_file_change(self, path):
        # 获取最新的cache并与旧的cache对比，再找出不同行，返回
        linecache.updatecache(path)
        new_cache = linecache.getlines(path)
        old_cache = self.filecache[path]
        # print("old_cache:", old_cache, len(old_cache))
        # print("new_cache:", new_cache, len(new_cache))
        change_cache = new_cache[len(old_cache):len(new_cache)]
        # 更新filecache中对应的文件
        self.filecache[path] = new_cache
        #print("change is :", new_cache)
        for line_cache in change_cache:
            project_id, body = self.filter_context(line_cache)
            if project_id:
                #if self.post_flag:
                if True:
                    self.write_local_cache_file(project_id, body)
                else:
                    self.do_post_request(project_id, body)

    # 过滤行提取关键信息
    def filter_context(self, cache):
        get_context = self.log_re.search(cache)
        # print(get_context.groups())
        # 依次遍历获取body中的对应参数并填充
        body_tmp = {"user": {"domain": {}, "id": None, "name": None}}
        project_id = None
        try:
            for x in self.log_re.groupindex:
                if x == 'domain_name' and get_context.group(
                        'domain_name') != '-':
                    body_tmp['user']['domain']['name'] = get_context.group(
                        'domain_name')
                elif x == 'domain_id' and get_context.group(
                        'domain_id') != '-':
                    body_tmp['user']['domain']['id'] = get_context.group(
                        'domain_id')
                elif x == 'user_id' and get_context.group('user_id') != '-':
                    body_tmp['user']['id'] = get_context.group('user_id')
                elif x == 'user_name' and get_context.group(
                        'user_name') != '-':
                    body_tmp['user']['name'] = get_context.group('user_name')
                elif x == 'assumed_by' and get_context.group(
                        'assumed_by') != '-':
                    body_tmp['user']['assumed_by'] = get_context.group(
                        'assumed_by')
                elif x == 'project_id':
                    project_id = get_context.group('project_id')
                elif get_context.group(x) and get_context.group(x) != '-':
                    body_tmp[x] = get_context.group(x)
                #"record_time"
            # 格式转换
            body_tmp["user"] = str(body_tmp["user"])
            body_tmp["code"] = int(body_tmp["code"])
            body_tmp["time"] = int(body_tmp["time"])
        except Exception as e:
            pass
            #print("catch exception, e is %s Traceback is %s." %(e,str(traceback.format_exc())))
        print("project_id, body_tmp:", project_id, body_tmp)
        return project_id, body_tmp

    # 上报失败后缓存入本地文件
    def write_local_cache_file(self, project_id, body):
        lines_tmp = {'project_id': project_id, 'body': body}
        with open(local_cache_file_path, 'a+') as tmp_file:
            tmp_file.writelines(str(lines_tmp)+'\n')
            tmp_file.flush()

    def post_local_cache_file(self):
        tmp_file = open(local_cache_file_path, 'r+')
        tmp_lines = tmp_file.readlines()
        for body_line in tmp_lines:
            body_map = eval(body_line)
            status_code = self.post_request(body_map['project_id'], body_map['body'])
            if status_code == 200:
                #self.post_flag = True
                continue
            else:
                break

    def post_request(self, project_id, body):
        post_url = 'https://%s:60000/v1.0/%s/system/trace' % (cts_address,
                                                              project_id)
        code = None
        for x in range(2):
            print("1self.post_headers:", self.post_headers)
            r = requests.post(post_url, headers=self.post_headers,
                              json=[body], verify=False)
            code = r.status_code
            print("post_request:", r.text)
            if code == 401:
                new_token = self.get_token()
                if new_token:
                    self.post_headers["X-Auth-Token"] = new_token
                else:
                    print("iam auth is error,can not get new token for CTS!")
                    break
                print("2self.post_headers:", self.post_headers)
            elif code == 200:
                    self.post_flag = True
        print("3self.post_headers:", self.post_headers)
        return code


    # 上报行为处理
    def do_post_request(self, project_id, body):
        alarm_flag = False
        try_times = 5
        trying_times = 0
        time_nterval_1 = 1
        time_nterval_10 = 10
        time_nterval_60 = 60

        #while True:
        for x in range(2):
            status_code = self.post_request(project_id, body)
            if status_code == 200:
                if alarm_flag:
                    self.send_alarm(1506011, "cts_plugin",
                                    self.resource, self.location, "", 1)
                break
            if status_code == 401:
                self.get_token()
                print("log_info_refush_token")
                break
            if status_code == 400:
                print("log_info_400")
                self.send_alarm(1506011, "cts_plugin", self.resource,
                                self.location, "", 0)
                break
            if status_code == 404:
                print("log_info_404")
                break
            if status_code == 403 or status_code == 500:
                trying_times = trying_times + 1
                if trying_times <= try_times:
                    time.sleep(time_nterval_1)
                    print("log_info_1")
                if trying_times > try_times:
                    time.sleep(time_nterval_10)
                    print("log_info_10")
                if try_times >= 2 * try_times:
                    time.sleep(time_nterval_60)
                    print("log_info_60")
                    if not alarm_flag:
                        alarm_flag = True
                        self.send_alarm(1506011, "cts_plugin", self.resource,
                                        self.location, "", 0)

    # 获取token
    def get_token(self):
        r = requests.post(self.get_token_url, headers=self.get_token_headers,
                          data=self.get_token_payload, verify=False)
        print("1get_token:", r.text)
        print("2get_token:", r.status_code)
        if r.status_code == 401 or r.status_code == 400:
            self.send_alarm(1506011, "cts_plugin", self.resource,
                            self.location, "", 0)
        if r.status_code == 201:
            self.token = r.headers['X-Subject-Token']
            print("3get_token:", self.token)
            return self.token

    # 发送告警
    def send_alarm(self, alarm_id, moc, resource, location, addition='',
                   alarm_type=0, level=2, cause=0):
        pass
        # alarm_cmd = 'sendAlarm %d %d %d %d "" "%s" "%s" "%s" "%s"' % \
        #             (alarm_id, alarm_type, level, cause,
        #              moc, resource, location, addition)
        # subprocess.check_call(args=alarm_cmd)

    def on_any_event(self, event):
        # print("event noticed: " + event.event_type + "on file" +
        #       event.src_path.encode('utf-8') + " at " + time.asctime())
        pass

    def on_moved(self, event):
        if event.src_path in filterfile:
            print("moved src path:" + event.src_path)
            print("moved dest path:" + event.dest_path)

    def on_created(self, event):
        if event.src_path in filterfile:
            print("created path:" + event.src_path)

    def on_deleted(self, event):
        if event.src_path in filterfile:
            print("deleted path:" + event.src_path)

    def should_reload(self, event):
        if isinstance(event, FileSystemMovedEvent):
            return True
        return False

    def on_modified(self, event):
        if event.src_path in filterfile:
            print("modified path:" + event.src_path)
            if self.post_flag:
                self.post_local_cache_file()
            self.get_file_change(event.src_path)


if __name__ == "__main__":
    event_handler = report_files_change()
    observer = Observer()
    observer.schedule(event_handler, baseDir, recursive=True)
    observer.start()
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()
