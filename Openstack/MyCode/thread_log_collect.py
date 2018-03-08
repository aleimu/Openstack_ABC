#!/usr/bin/python
# -*- coding:UTF-8 -*-

import os
import shutil
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
import time
import threading
from multiprocessing.pool import ThreadPool

try:
    import queue
except Exception as e:
    import Queue as queue

baseDir = '/var/log/fusionsphere/operate/'
filterfile = [baseDir + 'nova-api/nova-api.log',
              baseDir + 'cinder-api/cinder-api.log',
              baseDir + 'neutron-api/neutron-api.log',
              baseDir + 'glance-api/glance-api.log']

#filterfile = [baseDir + 'nova-api/nova-api.log']

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
iam_address = '172.30.48.18'
iam_port = '31943'
cts_domain = 'XXX'
cts_user = 'XXX'
cts_password = 'XXX'
cts_address = '172.30.49.15'
send_req = 'true'
local_cache_file_path = '/var/log/fusionsphere/local_body_cache.log'

mysum = 0
time_nterval_1 = 1
time_nterval_10 = 10
time_nterval_60 = 60
q_post = queue.Queue()

# file_lock = threading.RLock() #测试发现本地缓存文件并不需要加读写锁


class report_files_changes():
    def __init__(self):
        self.token = None
        self.location = '定位信息'
        self.resource = '告警源信息'
        self.alarm_flag = False
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
        logging.info("self.get_token_payload: %s " % self.get_token_payload)
        self.get_token_url = 'https://%s:%s/v3/auth/tokens' % (iam_address,
                                                               iam_port)

    # 上报失败后缓存入本地文件
    def write_local_cache_file(self, project_id, body):
        # file_lock.acquire()
        lines_tmp = {'project_id': project_id, 'body': body}
        with open(local_cache_file_path, 'a+') as tmp_file:
            tmp_file.writelines(str(lines_tmp) + '\n')
            tmp_file.flush()
        # file_lock.release()

    # 上报本地缓存文件中的消息
    def post_local_cache_file(self):
        # 复用IO，不会每次都建立新的连接
        session = requests.session()
        with open(local_cache_file_path, 'r+') as tmp_file:
            tmp_lines = tmp_file.readlines()
            tmp_file.close()
            if tmp_lines:
                for body_line in tmp_lines:
                    body_map = eval(body_line)
                    status_code, context = self.request_post(
                        session, body_map['project_id'], body_map['body'])
                    if status_code == 200:
                        #self.post_flag = True
                        continue
                    else:
                        logging.debug("post body: %s ,respones context: %s"
                                      % (body_line, context))
                        break
                return True
            else:
                return None

    def async_threadpool_post(self):
        pool = ThreadPool(4)
        return_list = pool.map_async(func=self.request_do_post,
                                     iterable=range(8))
        pool.close()
        # logging.info("post result: %s " % return_list.get())
        # 这里会阻塞后面的语句，建议放在全文的后面
        return pool

    # 上报行为处理
    def request_do_post(self, number):
        # 复用IO，不会每次都建立新的连接
        session = requests.session()
        while True:
            if not q_post.empty():
                project_id, body = q_post.get()
                status_code, context = self.request_post(session, project_id,
                                                         body)
                if status_code == 200:
                    logging.info("message was sent successfully, "
                                 "content is: %s " % str(body))
                    if self.alarm_flag:
                        self.send_alarm(1506011, "cts_plugin",
                                        self.resource, self.location, "", 1)
                    # break
                if status_code == 401:
                    self.get_token()
                    logging.info("refush token failed, code: %s ,response: %s"
                                 % (status_code, context))
                    break
                if status_code == 400:
                    logging.info("request failed, code: %s ,response: %s"
                                 % (status_code, context))
                    self.send_alarm(1506011, "cts_plugin", self.resource,
                                    self.location, "", 0)
                    break
                if status_code == 404:
                    logging.info("request failed, code: %s ,response: %s"
                                 % (status_code, context))
                    break
                if status_code == 403 or status_code >= 500:
                    logging.warning("%s,%s will be written to the cache file"
                                    % (project_id, body))
                    logging.info("request failed, code: %s ,response: %s"
                                 % (status_code, context))
                    self.write_local_cache_file(project_id, body)
            else:
                time.sleep(5)

    # 通用请求
    def request_post(self, session, project_id, body):
        post_url = 'https://%s:60000/v1.0/%s/system/trace' % (cts_address,
                                                              project_id)
        code = None
        context = None
        for x in range(2):
            r = session.post(post_url,
                              headers=self.post_headers,
                              json=[body], verify=False, timeout=5)
            code = r.status_code
            context = r.text
            if code == 401:
                new_token = self.get_token()
                if new_token:
                    self.post_headers[
                        "X-Auth-Token"] = new_token
                else:
                    logging.warning(
                        "iam auth is error,can not get new token for CTS!")
                    break
            elif code == 200:
                self.post_flag = True
        return code, context

    # 对于post失败的本地文件中的消息延迟发送
    def delay_post(self):
        try_times = 5
        tried_times = 0
        while True:
            if not self.post_local_cache_file():
                continue
            tried_times = tried_times + 1
            if tried_times <= try_times:
                time.sleep(time_nterval_1)
                logging.info("log_info_sleep_1")
            if tried_times > try_times and tried_times <= 2 * try_times:
                time.sleep(time_nterval_10)
                logging.warning("log_info_sleep_10")
            if tried_times > 2 * try_times:
                time.sleep(time_nterval_60)
                logging.warning("log_info_sleep_60")
                if not self.alarm_flag:
                    self.alarm_flag = True
                    self.send_alarm(1506011, "cts_plugin",
                                    self.resource, self.location, "", 0)

    # 单线程读取本地缓存文件，上报
    def delay_post_thread(self):
        delay_post_th = threading.Thread(target=self.delay_post)
        delay_post_th.start()
        return delay_post_th

    # 获取token
    def get_token(self):
        r = requests.post(self.get_token_url, headers=self.get_token_headers,
                          data=self.get_token_payload, verify=False)
        if r.status_code == 401 or r.status_code == 400:
            self.send_alarm(1506011, "cts_plugin", self.resource,
                            self.location, "", 0)
        if r.status_code == 201:
            self.token = r.headers['X-Subject-Token']
            logging.info("get new token: %s " % self.token)
            return self.token

    # 发送告警
    def send_alarm(self, alarm_id, moc, resource, location, addition='',
                   alarm_type=0, level=2, cause=0):
        pass
        # alarm_cmd = 'sendAlarm %d %d %d %d "" "%s" "%s" "%s" "%s"' % \
        #             (alarm_id, alarm_type, level, cause,
        #              moc, resource, location, addition)
        # subprocess.check_call(args=alarm_cmd)


class get_files_changes(FileSystemEventHandler):
    def __init__(self, pattern='*'):
        self.pattern = pattern
        self.alarm_flag = False
        self.log_re = re.compile(re_cts_out)
        # 上报通信是否正常，正常则直接上报，False不正常则写入文件
        self.post_flag = False
        # 初始化filecache的map用来存放需要上报的文件名和对应行
        self.filecache = {}
        for x in filterfile:
            self.old_cache = linecache.getlines(x)
            self.filecache[x] = self.old_cache

    # 正则过滤，放入队列
    def re_files_changes(self, path):
        # 获取最新的cache并与旧的cache对比，再找出不同行，返回
        linecache.updatecache(path)
        new_cache = linecache.getlines(path)
        old_cache = self.filecache[path]
        change_cache = new_cache[len(old_cache):len(new_cache)]
        # 更新filecache中对应的文件
        self.filecache[path] = new_cache
        logging.info("modified path: %s  changes:%s" %
                     (path, str(change_cache)))
        #print("change is :", new_cache)
        for line_cache in change_cache:
            project_id_body = self.filter_context(line_cache)
            if project_id_body:
                #logging.info("==============%s " % project_id_body)
                q_post.put(project_id_body)
            #print("Producer %s has produced %s baozi.." % (name, count))
            if q_post.qsize() >= 500:
                logging.info("Now queue size: %s Sending may be too slow, "
                             "check CTS server!" % q_post.qsize())
                # break
            # if project_id:
            #     #if self.post_flag:
            #     if True:
            #         self.write_local_cache_file(project_id, body)
            #     else:
            #         self.do_post_request(project_id, body)

    # 过滤行提取关键信息
    def filter_context(self, cache):
        get_context = self.log_re.search(cache)
        if get_context:
            logging.info('The original log message: %s'
                         % str(get_context.groups()))
        else:
            return None
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
        if project_id:
            global mysum
            mysum = mysum + 1
            logging.info('Message After regular,project_id: %s ,body: %s' %
                         (project_id, body_tmp))
            return [project_id, body_tmp]

    def on_any_event(self, event):
        # print("event noticed: " + event.event_type + "on file" +
        #       event.src_path.encode('utf-8') + " at " + time.asctime())
        pass

    def on_moved(self, event):
        if event.src_path in filterfile:
            logging.info("moved src path:" + event.src_path +
                         "moved dest path:" + event.dest_path)

    def on_created(self, event):
        if event.src_path in filterfile:
            logging.info("created path:" + event.src_path)

    def on_deleted(self, event):
        if event.src_path in filterfile:
            logging.info("deleted path:" + event.src_path)

    def should_reload(self, event):
        if isinstance(event, FileSystemMovedEvent):
            return True
        return False

    # 文件被写入时触发
    def on_modified(self, event):
        if event.src_path in filterfile:
            #logging.info("modified path:" + event.src_path)
            # if self.post_flag:
            #     self.post_local_cache_file()
            self.re_files_changes(event.src_path)
            #print("mysum:", mysum)


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO,
                        format='%(asctime)s %(filename)s[line:%(lineno)d] '
                               '%(levelname)s %(message)s',
                        datefmt='%Y-%m-%d %H:%M:%S',
                        filename='myapp.log',
                        filemode='w')
    event_handler = get_files_changes()
    report_thread = report_files_changes()
    pool = report_thread.async_threadpool_post()
    delay_thread = report_thread.delay_post_thread()
    observer = Observer()
    observer.schedule(event_handler, baseDir, recursive=True)
    observer.start()
    # delay_thread.join()
    try:
        while True:
            print("-----time.sleep(1)-------")
            time.sleep(5)
    except KeyboardInterrupt:
        print("KeyboardInterrupt!!")
        observer.stop()
    delay_thread.join()
    observer.join()
    pool.join()
