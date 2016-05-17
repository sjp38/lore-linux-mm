Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 499276B0005
	for <linux-mm@kvack.org>; Tue, 17 May 2016 01:32:28 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 77so12082240pfz.3
        for <linux-mm@kvack.org>; Mon, 16 May 2016 22:32:28 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id ia2si2054057pad.150.2016.05.16.22.32.26
        for <linux-mm@kvack.org>;
        Mon, 16 May 2016 22:32:26 -0700 (PDT)
Date: Tue, 17 May 2016 13:31:59 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: Do not build vmstat_refresh if there is no procfs support
Message-ID: <201605171333.ANqJcwpy%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="/04w6evG8XlLl3ft"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1605111011260.9351@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: kbuild-all@01.org, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--/04w6evG8XlLl3ft
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

[auto build test ERROR on next-20160511]
[cannot apply to v4.6-rc7 v4.6-rc6 v4.6-rc5 v4.6]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Christoph-Lameter/Do-not-build-vmstat_refresh-if-there-is-no-procfs-support/20160511-233405
config: arm64-allnoconfig (attached as .config)
compiler: aarch64-linux-gnu-gcc (Debian 5.3.1-8) 5.3.1 20160205
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=arm64 

All error/warnings (new ones prefixed by >>):

   mm/vmstat.c: In function 'vmstat_update':
>> mm/vmstat.c:1436:45: error: 'vmstat_wq' undeclared (first use in this function)
      queue_delayed_work_on(smp_processor_id(), vmstat_wq,
                                                ^
   mm/vmstat.c:1436:45: note: each undeclared identifier is reported only once for each function it appears in
   In file included from include/asm-generic/percpu.h:6:0,
                    from arch/arm64/include/asm/percpu.h:276,
                    from include/linux/percpu.h:12,
                    from include/linux/percpu-rwsem.h:6,
                    from include/linux/fs.h:30,
                    from mm/vmstat.c:12:
>> mm/vmstat.c:1437:19: error: 'vmstat_work' undeclared (first use in this function)
        this_cpu_ptr(&vmstat_work),
                      ^
   include/linux/percpu-defs.h:206:47: note: in definition of macro '__verify_pcpu_ptr'
     const void __percpu *__vpp_verify = (typeof((ptr) + 0))NULL; \
                                                  ^
   include/linux/percpu-defs.h:239:27: note: in expansion of macro 'raw_cpu_ptr'
    #define this_cpu_ptr(ptr) raw_cpu_ptr(ptr)
                              ^
>> mm/vmstat.c:1437:5: note: in expansion of macro 'this_cpu_ptr'
        this_cpu_ptr(&vmstat_work),
        ^
   In file included from include/linux/fs.h:32:0,
                    from mm/vmstat.c:12:
   mm/vmstat.c: In function 'quiet_vmstat':
   mm/vmstat.c:1480:42: error: 'vmstat_work' undeclared (first use in this function)
     if (!delayed_work_pending(this_cpu_ptr(&vmstat_work)))
                                             ^
   include/linux/workqueue.h:26:51: note: in definition of macro 'work_data_bits'
    #define work_data_bits(work) ((unsigned long *)(&(work)->data))
                                                      ^
   include/linux/workqueue.h:271:2: note: in expansion of macro 'work_pending'
     work_pending(&(w)->work)
     ^
>> mm/vmstat.c:1480:7: note: in expansion of macro 'delayed_work_pending'
     if (!delayed_work_pending(this_cpu_ptr(&vmstat_work)))
          ^
   include/linux/percpu-defs.h:228:2: note: in expansion of macro '__verify_pcpu_ptr'
     __verify_pcpu_ptr(ptr);      \
     ^
   include/linux/percpu-defs.h:239:27: note: in expansion of macro 'raw_cpu_ptr'
    #define this_cpu_ptr(ptr) raw_cpu_ptr(ptr)
                              ^
   mm/vmstat.c:1480:28: note: in expansion of macro 'this_cpu_ptr'
     if (!delayed_work_pending(this_cpu_ptr(&vmstat_work)))
                               ^
   In file included from include/asm-generic/percpu.h:6:0,
                    from arch/arm64/include/asm/percpu.h:276,
                    from include/linux/percpu.h:12,
                    from include/linux/percpu-rwsem.h:6,
                    from include/linux/fs.h:30,
                    from mm/vmstat.c:12:
   mm/vmstat.c: In function 'vmstat_shepherd':
   mm/vmstat.c:1512:38: error: 'vmstat_work' undeclared (first use in this function)
      struct delayed_work *dw = &per_cpu(vmstat_work, cpu);
                                         ^
   include/linux/percpu-defs.h:206:47: note: in definition of macro '__verify_pcpu_ptr'
     const void __percpu *__vpp_verify = (typeof((ptr) + 0))NULL; \
                                                  ^
   include/linux/percpu-defs.h:256:29: note: in expansion of macro 'per_cpu_ptr'
    #define per_cpu(var, cpu) (*per_cpu_ptr(&(var), cpu))
                                ^
>> mm/vmstat.c:1512:30: note: in expansion of macro 'per_cpu'
      struct delayed_work *dw = &per_cpu(vmstat_work, cpu);
                                 ^
   mm/vmstat.c:1515:32: error: 'vmstat_wq' undeclared (first use in this function)
        queue_delayed_work_on(cpu, vmstat_wq, dw, 0);
                                   ^
   In file included from include/linux/fs.h:32:0,
                    from mm/vmstat.c:12:
   mm/vmstat.c: In function 'start_shepherd_timer':
   mm/vmstat.c:1528:37: error: 'vmstat_work' undeclared (first use in this function)
      INIT_DEFERRABLE_WORK(per_cpu_ptr(&vmstat_work, cpu),
                                        ^
   include/linux/workqueue.h:216:16: note: in definition of macro '__INIT_WORK'
      __init_work((_work), _onstack);    \
                   ^
   include/linux/workqueue.h:231:3: note: in expansion of macro 'INIT_WORK'
      INIT_WORK(&(_work)->work, (_func));   \
      ^
   include/linux/workqueue.h:253:2: note: in expansion of macro '__INIT_DELAYED_WORK'
     __INIT_DELAYED_WORK(_work, _func, TIMER_DEFERRABLE)
     ^
>> mm/vmstat.c:1528:3: note: in expansion of macro 'INIT_DEFERRABLE_WORK'
      INIT_DEFERRABLE_WORK(per_cpu_ptr(&vmstat_work, cpu),
      ^
   include/linux/percpu-defs.h:222:2: note: in expansion of macro '__verify_pcpu_ptr'
     __verify_pcpu_ptr(ptr);      \
     ^
>> mm/vmstat.c:1528:24: note: in expansion of macro 'per_cpu_ptr'
      INIT_DEFERRABLE_WORK(per_cpu_ptr(&vmstat_work, cpu),
                           ^
   mm/vmstat.c:1531:2: error: 'vmstat_wq' undeclared (first use in this function)
     vmstat_wq = alloc_workqueue("vmstat", WQ_FREEZABLE|WQ_MEM_RECLAIM, 0);
     ^
   In file included from include/asm-generic/percpu.h:6:0,
                    from arch/arm64/include/asm/percpu.h:276,
                    from include/linux/percpu.h:12,
                    from include/linux/percpu-rwsem.h:6,
                    from include/linux/fs.h:30,
                    from mm/vmstat.c:12:
   mm/vmstat.c: In function 'vmstat_cpuup_callback':
   mm/vmstat.c:1568:37: error: 'vmstat_work' undeclared (first use in this function)
      cancel_delayed_work_sync(&per_cpu(vmstat_work, cpu));
                                        ^
   include/linux/percpu-defs.h:206:47: note: in definition of macro '__verify_pcpu_ptr'
     const void __percpu *__vpp_verify = (typeof((ptr) + 0))NULL; \
                                                  ^
   include/linux/percpu-defs.h:256:29: note: in expansion of macro 'per_cpu_ptr'
    #define per_cpu(var, cpu) (*per_cpu_ptr(&(var), cpu))
                                ^
   mm/vmstat.c:1568:29: note: in expansion of macro 'per_cpu'
      cancel_delayed_work_sync(&per_cpu(vmstat_work, cpu));
                                ^

vim +/vmstat_wq +1436 mm/vmstat.c

0eb77e988 Christoph Lameter 2016-01-14  1430  	if (refresh_cpu_vm_stats(true)) {
7cc36bbdd Christoph Lameter 2014-10-09  1431  		/*
7cc36bbdd Christoph Lameter 2014-10-09  1432  		 * Counters were updated so we expect more updates
7cc36bbdd Christoph Lameter 2014-10-09  1433  		 * to occur in the future. Keep on running the
7cc36bbdd Christoph Lameter 2014-10-09  1434  		 * update worker thread.
7cc36bbdd Christoph Lameter 2014-10-09  1435  		 */
373ccbe59 Michal Hocko      2015-12-11 @1436  		queue_delayed_work_on(smp_processor_id(), vmstat_wq,
176bed1de Linus Torvalds    2015-10-15 @1437  				this_cpu_ptr(&vmstat_work),
98f4ebb29 Anton Blanchard   2009-04-02  1438  				round_jiffies_relative(sysctl_stat_interval));
f01f17d37 Michal Hocko      2016-02-05  1439  	}
7cc36bbdd Christoph Lameter 2014-10-09  1440  }
7cc36bbdd Christoph Lameter 2014-10-09  1441  
7cc36bbdd Christoph Lameter 2014-10-09  1442  /*
0eb77e988 Christoph Lameter 2016-01-14  1443   * Switch off vmstat processing and then fold all the remaining differentials
0eb77e988 Christoph Lameter 2016-01-14  1444   * until the diffs stay at zero. The function is used by NOHZ and can only be
0eb77e988 Christoph Lameter 2016-01-14  1445   * invoked when tick processing is not active.
0eb77e988 Christoph Lameter 2016-01-14  1446   */
0eb77e988 Christoph Lameter 2016-01-14  1447  /*
7cc36bbdd Christoph Lameter 2014-10-09  1448   * Check if the diffs for a certain cpu indicate that
7cc36bbdd Christoph Lameter 2014-10-09  1449   * an update is needed.
7cc36bbdd Christoph Lameter 2014-10-09  1450   */
7cc36bbdd Christoph Lameter 2014-10-09  1451  static bool need_update(int cpu)
7cc36bbdd Christoph Lameter 2014-10-09  1452  {
7cc36bbdd Christoph Lameter 2014-10-09  1453  	struct zone *zone;
7cc36bbdd Christoph Lameter 2014-10-09  1454  
7cc36bbdd Christoph Lameter 2014-10-09  1455  	for_each_populated_zone(zone) {
7cc36bbdd Christoph Lameter 2014-10-09  1456  		struct per_cpu_pageset *p = per_cpu_ptr(zone->pageset, cpu);
7cc36bbdd Christoph Lameter 2014-10-09  1457  
7cc36bbdd Christoph Lameter 2014-10-09  1458  		BUILD_BUG_ON(sizeof(p->vm_stat_diff[0]) != 1);
7cc36bbdd Christoph Lameter 2014-10-09  1459  		/*
7cc36bbdd Christoph Lameter 2014-10-09  1460  		 * The fast way of checking if there are any vmstat diffs.
7cc36bbdd Christoph Lameter 2014-10-09  1461  		 * This works because the diffs are byte sized items.
7cc36bbdd Christoph Lameter 2014-10-09  1462  		 */
7cc36bbdd Christoph Lameter 2014-10-09  1463  		if (memchr_inv(p->vm_stat_diff, 0, NR_VM_ZONE_STAT_ITEMS))
7cc36bbdd Christoph Lameter 2014-10-09  1464  			return true;
7cc36bbdd Christoph Lameter 2014-10-09  1465  
7cc36bbdd Christoph Lameter 2014-10-09  1466  	}
7cc36bbdd Christoph Lameter 2014-10-09  1467  	return false;
7cc36bbdd Christoph Lameter 2014-10-09  1468  }
7cc36bbdd Christoph Lameter 2014-10-09  1469  
043daba0d Christoph Lameter 2016-05-11  1470  /*
043daba0d Christoph Lameter 2016-05-11  1471   * Switch off vmstat processing and then fold all the remaining differentials
043daba0d Christoph Lameter 2016-05-11  1472   * until the diffs stay at zero. The function is used by NOHZ and can only be
043daba0d Christoph Lameter 2016-05-11  1473   * invoked when tick processing is not active.
043daba0d Christoph Lameter 2016-05-11  1474   */
f01f17d37 Michal Hocko      2016-02-05  1475  void quiet_vmstat(void)
f01f17d37 Michal Hocko      2016-02-05  1476  {
f01f17d37 Michal Hocko      2016-02-05  1477  	if (system_state != SYSTEM_RUNNING)
f01f17d37 Michal Hocko      2016-02-05  1478  		return;
f01f17d37 Michal Hocko      2016-02-05  1479  
043daba0d Christoph Lameter 2016-05-11 @1480  	if (!delayed_work_pending(this_cpu_ptr(&vmstat_work)))
f01f17d37 Michal Hocko      2016-02-05  1481  		return;
f01f17d37 Michal Hocko      2016-02-05  1482  
f01f17d37 Michal Hocko      2016-02-05  1483  	if (!need_update(smp_processor_id()))
f01f17d37 Michal Hocko      2016-02-05  1484  		return;
f01f17d37 Michal Hocko      2016-02-05  1485  
f01f17d37 Michal Hocko      2016-02-05  1486  	/*
f01f17d37 Michal Hocko      2016-02-05  1487  	 * Just refresh counters and do not care about the pending delayed
f01f17d37 Michal Hocko      2016-02-05  1488  	 * vmstat_update. It doesn't fire that often to matter and canceling
f01f17d37 Michal Hocko      2016-02-05  1489  	 * it would be too expensive from this path.
f01f17d37 Michal Hocko      2016-02-05  1490  	 * vmstat_shepherd will take care about that for us.
f01f17d37 Michal Hocko      2016-02-05  1491  	 */
f01f17d37 Michal Hocko      2016-02-05  1492  	refresh_cpu_vm_stats(false);
f01f17d37 Michal Hocko      2016-02-05  1493  }
f01f17d37 Michal Hocko      2016-02-05  1494  
7cc36bbdd Christoph Lameter 2014-10-09  1495  /*
7cc36bbdd Christoph Lameter 2014-10-09  1496   * Shepherd worker thread that checks the
7cc36bbdd Christoph Lameter 2014-10-09  1497   * differentials of processors that have their worker
7cc36bbdd Christoph Lameter 2014-10-09  1498   * threads for vm statistics updates disabled because of
7cc36bbdd Christoph Lameter 2014-10-09  1499   * inactivity.
7cc36bbdd Christoph Lameter 2014-10-09  1500   */
7cc36bbdd Christoph Lameter 2014-10-09  1501  static void vmstat_shepherd(struct work_struct *w);
7cc36bbdd Christoph Lameter 2014-10-09  1502  
0eb77e988 Christoph Lameter 2016-01-14  1503  static DECLARE_DEFERRABLE_WORK(shepherd, vmstat_shepherd);
7cc36bbdd Christoph Lameter 2014-10-09  1504  
7cc36bbdd Christoph Lameter 2014-10-09  1505  static void vmstat_shepherd(struct work_struct *w)
7cc36bbdd Christoph Lameter 2014-10-09  1506  {
7cc36bbdd Christoph Lameter 2014-10-09  1507  	int cpu;
7cc36bbdd Christoph Lameter 2014-10-09  1508  
7cc36bbdd Christoph Lameter 2014-10-09  1509  	get_online_cpus();
7cc36bbdd Christoph Lameter 2014-10-09  1510  	/* Check processors whose vmstat worker threads have been disabled */
043daba0d Christoph Lameter 2016-05-11  1511  	for_each_online_cpu(cpu) {
f01f17d37 Michal Hocko      2016-02-05 @1512  		struct delayed_work *dw = &per_cpu(vmstat_work, cpu);
7cc36bbdd Christoph Lameter 2014-10-09  1513  
043daba0d Christoph Lameter 2016-05-11  1514  		if (!delayed_work_pending(dw) && need_update(cpu))
f01f17d37 Michal Hocko      2016-02-05  1515  				queue_delayed_work_on(cpu, vmstat_wq, dw, 0);
f01f17d37 Michal Hocko      2016-02-05  1516  	}
7cc36bbdd Christoph Lameter 2014-10-09  1517  	put_online_cpus();
7cc36bbdd Christoph Lameter 2014-10-09  1518  
7cc36bbdd Christoph Lameter 2014-10-09  1519  	schedule_delayed_work(&shepherd,
7cc36bbdd Christoph Lameter 2014-10-09  1520  		round_jiffies_relative(sysctl_stat_interval));
d1187ed21 Christoph Lameter 2007-05-09  1521  }
d1187ed21 Christoph Lameter 2007-05-09  1522  
7cc36bbdd Christoph Lameter 2014-10-09  1523  static void __init start_shepherd_timer(void)
d1187ed21 Christoph Lameter 2007-05-09  1524  {
7cc36bbdd Christoph Lameter 2014-10-09  1525  	int cpu;
7cc36bbdd Christoph Lameter 2014-10-09  1526  
7cc36bbdd Christoph Lameter 2014-10-09  1527  	for_each_possible_cpu(cpu)
ccde8bd40 Michal Hocko      2016-02-05 @1528  		INIT_DEFERRABLE_WORK(per_cpu_ptr(&vmstat_work, cpu),
7cc36bbdd Christoph Lameter 2014-10-09  1529  			vmstat_update);
7cc36bbdd Christoph Lameter 2014-10-09  1530  
751e5f5c7 Michal Hocko      2016-01-08  1531  	vmstat_wq = alloc_workqueue("vmstat", WQ_FREEZABLE|WQ_MEM_RECLAIM, 0);

:::::: The code at line 1436 was first introduced by commit
:::::: 373ccbe5927034b55bdc80b0f8b54d6e13fe8d12 mm, vmstat: allow WQ concurrency to discover memory reclaim doesn't make any progress

:::::: TO: Michal Hocko <mhocko@suse.com>
:::::: CC: Linus Torvalds <torvalds@linux-foundation.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--/04w6evG8XlLl3ft
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
AA==

--/04w6evG8XlLl3ft--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
