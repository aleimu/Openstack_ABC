from multiprocessing.pool import Pool as ThreadPool
#from multiprocessing.dummy import Pool as ThreadPool


# pool.map_async
def _check_other_comps_ssl(self, new_ssl):
    templates = self.comp_util.get_have_cfg_templates("rabbit_use_ssl")

    def task(template):
        ret1 = self._wait_use_ssl_changed(template["service"],
                                          template["name"],
                                          new_ssl)
        ret2 = self.comp_util.wait_instances_normal(template["service"],
                                                    template["name"])
        ret1 = None
        if (ret1 and ret2) is None:
            LOG.info('ret1,ret2:%s %s ' % (ret1, ret2))
            return
        else:
            raise Exception('ret1 or ret2 timeout')

    results = []
    pool = ThreadPool(20)
    result = pool.map_async(task, templates)
    pool.close()
    pool.join()
    result.wait(timeout=60 * 20)
    try:
        LOG.info('==result.ready==: %s ' % (result.ready()))
        LOG.info('==result.successful==: %s ' % (result.successful()))
        LOG.info('==result.get==: %s ' % (result.get(timeout=60 * 2)))
        while result.ready():
            if result.successful():
                results.append(result.get(timeout=60 * 20))
                break
    except Exception as e:
        LOG.error("_check_comp_use_ssl exc = %s" % str(e))
    LOG.info("results %s" % results)
    # 如果不相等,则表明子线程中出现了异常,可能是超时,或者组件异常
    LOG.info('len of results: %s' % len(results[0]))
    LOG.info('len of templates: %s' % len(templates))
    assert len(results[0]) == len(templates)


# pool.apply_async
def _check_other_comps_ssl_app(self, new_ssl):
    templates = self.comp_util.get_have_cfg_templates("rabbit_use_ssl")

    def task(template, new_ssl):
        ret1 = self._wait_use_ssl_changed(template["service"],
                                          template["name"],
                                          new_ssl)
        ret2 = self.comp_util.wait_instances_normal(template["service"],
                                                    template["name"])
        if (ret1 and ret2) is None:
            return
        else:
            raise Exception('timeout')

    result1 = []
    result2 = []
    pool = ThreadPool(5)
    for template in templates:
        result = pool.apply_async(func=task, args=(template, new_ssl,))
        result1.append(result)
    pool.close()
    pool.join()
    for i in result1:
        i.wait(timeout=60 * 20)
        LOG.info("wait %s" % len(result2))
        while i.ready():
            LOG.info("ready %s" % len(result2))
            LOG.info("successful %s" % i.successful())
            LOG.info("i.get %s" % i.get())
            if i.successful():
                LOG.info(i.get(timeout=60 * 20))
                result2.append(i.get(timeout=60 * 20))
                break

    assert len(result2) == len(templates)
    # 如果不相等,则表明子线程中出现了异常,可能是超时
    LOG.info('len of result2: %s' % len(result2))
    LOG.info('len of templates: %s' % len(templates))

