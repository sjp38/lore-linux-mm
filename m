Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 44FA682F64
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 10:13:07 -0400 (EDT)
Received: by obcqt19 with SMTP id qt19so41731000obc.3
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 07:13:07 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id r184si5534826oih.53.2015.10.21.07.12.25
        for <linux-mm@kvack.org>;
        Wed, 21 Oct 2015 07:12:26 -0700 (PDT)
Date: Wed, 21 Oct 2015 22:04:37 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [linux-review:Tetsuo-Handa/mm-vmscan-Use-accurate-values-for-zone_reclaimable-checks/20151021-203036
 9489/9695] include/linux/cpu.h:48:13: error: storage class specified for
 parameter 'unregister_cpu'
Message-ID: <201510212218.wFmGHXJp%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="W/nzBZO5zC0uMSeA"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--W/nzBZO5zC0uMSeA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Minchan,

[auto build test ERROR on v4.3-rc6-108-gce1fad2 -- if it's inappropriate base, please suggest rules for selecting the more suitable base]

url:    https://github.com/0day-ci/linux/commits/Tetsuo-Handa/mm-vmscan-Use-accurate-values-for-zone_reclaimable-checks/20151021-203036
config: blackfin-BF561-EZKIT-SMP_defconfig (attached as .config)
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=blackfin 

All error/warnings (new ones prefixed by >>):

   In file included from mm/page-writeback.c:28:0:
   include/linux/rmap.h:274:1: error: expected declaration specifiers or '...' before '{' token
   In file included from mm/page-writeback.c:33:0:
   include/linux/cpu.h:30:12: error: storage class specified for parameter 'register_cpu'
   include/linux/cpu.h:31:23: error: storage class specified for parameter 'get_cpu_device'
   include/linux/cpu.h:32:13: error: storage class specified for parameter 'cpu_is_hotpluggable'
   include/linux/cpu.h:33:13: error: storage class specified for parameter 'arch_match_cpu_phys_id'
   include/linux/cpu.h:34:13: error: storage class specified for parameter 'arch_find_n_match_cpu_physical_id'
   include/linux/cpu.h:37:12: error: storage class specified for parameter 'cpu_add_dev_attr'
   include/linux/cpu.h:38:13: error: storage class specified for parameter 'cpu_remove_dev_attr'
   include/linux/cpu.h:40:12: error: storage class specified for parameter 'cpu_add_dev_attr_group'
   include/linux/cpu.h:41:13: error: storage class specified for parameter 'cpu_remove_dev_attr_group'
   include/linux/cpu.h:44:16: error: storage class specified for parameter 'cpu_device_create'
>> include/linux/cpu.h:48:13: error: storage class specified for parameter 'unregister_cpu'
>> include/linux/cpu.h:49:16: error: storage class specified for parameter 'arch_cpu_probe'
>> include/linux/cpu.h:50:16: error: storage class specified for parameter 'arch_cpu_release'
   include/linux/cpu.h:140:12: error: storage class specified for parameter 'register_cpu_notifier'
>> include/linux/cpu.h:141:12: error: storage class specified for parameter '__register_cpu_notifier'
>> include/linux/cpu.h:142:13: error: storage class specified for parameter 'unregister_cpu_notifier'
>> include/linux/cpu.h:143:13: error: storage class specified for parameter '__unregister_cpu_notifier'
>> include/linux/cpu.h:173:13: error: storage class specified for parameter 'cpu_maps_update_begin'
>> include/linux/cpu.h:174:13: error: storage class specified for parameter 'cpu_maps_update_done'
   include/linux/cpu.h:223:24: error: storage class specified for parameter 'cpu_subsys'
>> include/linux/cpu.h:228:13: error: storage class specified for parameter 'cpu_hotplug_begin'
>> include/linux/cpu.h:229:13: error: storage class specified for parameter 'cpu_hotplug_done'
>> include/linux/cpu.h:230:13: error: storage class specified for parameter 'get_online_cpus'
   include/linux/cpu.h:231:13: error: storage class specified for parameter 'try_get_online_cpus'
>> include/linux/cpu.h:232:13: error: storage class specified for parameter 'put_online_cpus'
>> include/linux/cpu.h:233:13: error: storage class specified for parameter 'cpu_hotplug_disable'
>> include/linux/cpu.h:234:13: error: storage class specified for parameter 'cpu_hotplug_enable'
>> include/linux/cpu.h:263:12: error: storage class specified for parameter 'disable_nonboot_cpus'
>> include/linux/cpu.h:264:13: error: storage class specified for parameter 'enable_nonboot_cpus'
   include/linux/cpu.h:285:1: error: storage class specified for parameter 'cpu_dead_idle'
   include/linux/cpu.h:285:1: error: section attribute not allowed for 'cpu_dead_idle'
   In file included from include/linux/syscalls.h:71:0,
                    from mm/page-writeback.c:34:
   include/uapi/linux/aio_abi.h:33:26: error: storage class specified for parameter 'aio_context_t'
   In file included from include/trace/syscall.h:4:0,
                    from include/linux/syscalls.h:81,
                    from mm/page-writeback.c:34:
   include/linux/tracepoint.h:46:1: error: storage class specified for parameter 'tracepoint_probe_register'
   include/linux/tracepoint.h:48:1: error: storage class specified for parameter 'tracepoint_probe_unregister'
   include/linux/tracepoint.h:50:1: error: storage class specified for parameter 'for_each_kernel_tracepoint'
   include/linux/tracepoint.h:60:12: error: storage class specified for parameter 'register_tracepoint_module_notifier'
   include/linux/tracepoint.h:61:12: error: storage class specified for parameter 'unregister_tracepoint_module_notifier'
>> include/linux/tracepoint.h:84:20: error: storage class specified for parameter 'tracepoint_synchronize_unregister'
>> include/linux/tracepoint.h:84:20: warning: parameter 'tracepoint_synchronize_unregister' declared 'inline' [enabled by default]
>> include/linux/tracepoint.h:85:1: warning: 'always_inline' attribute ignored [-Wattributes]
>> include/linux/tracepoint.h:84:20: error: 'no_instrument_function' attribute applies only to functions
--
   In file included from mm/vmscan.c:33:0:
   include/linux/rmap.h:274:1: error: expected declaration specifiers or '...' before '{' token
   In file included from mm/vmscan.c:35:0:
   include/linux/cpu.h:30:12: error: storage class specified for parameter 'register_cpu'
   include/linux/cpu.h:31:23: error: storage class specified for parameter 'get_cpu_device'
   include/linux/cpu.h:32:13: error: storage class specified for parameter 'cpu_is_hotpluggable'
   include/linux/cpu.h:33:13: error: storage class specified for parameter 'arch_match_cpu_phys_id'
   include/linux/cpu.h:34:13: error: storage class specified for parameter 'arch_find_n_match_cpu_physical_id'
   include/linux/cpu.h:37:12: error: storage class specified for parameter 'cpu_add_dev_attr'
   include/linux/cpu.h:38:13: error: storage class specified for parameter 'cpu_remove_dev_attr'
   include/linux/cpu.h:40:12: error: storage class specified for parameter 'cpu_add_dev_attr_group'
   include/linux/cpu.h:41:13: error: storage class specified for parameter 'cpu_remove_dev_attr_group'
   include/linux/cpu.h:44:16: error: storage class specified for parameter 'cpu_device_create'
>> include/linux/cpu.h:48:13: error: storage class specified for parameter 'unregister_cpu'
>> include/linux/cpu.h:49:16: error: storage class specified for parameter 'arch_cpu_probe'
>> include/linux/cpu.h:50:16: error: storage class specified for parameter 'arch_cpu_release'
   include/linux/cpu.h:140:12: error: storage class specified for parameter 'register_cpu_notifier'
>> include/linux/cpu.h:141:12: error: storage class specified for parameter '__register_cpu_notifier'
>> include/linux/cpu.h:142:13: error: storage class specified for parameter 'unregister_cpu_notifier'
>> include/linux/cpu.h:143:13: error: storage class specified for parameter '__unregister_cpu_notifier'
>> include/linux/cpu.h:173:13: error: storage class specified for parameter 'cpu_maps_update_begin'
>> include/linux/cpu.h:174:13: error: storage class specified for parameter 'cpu_maps_update_done'
   include/linux/cpu.h:223:24: error: storage class specified for parameter 'cpu_subsys'
>> include/linux/cpu.h:228:13: error: storage class specified for parameter 'cpu_hotplug_begin'
>> include/linux/cpu.h:229:13: error: storage class specified for parameter 'cpu_hotplug_done'
>> include/linux/cpu.h:230:13: error: storage class specified for parameter 'get_online_cpus'
   include/linux/cpu.h:231:13: error: storage class specified for parameter 'try_get_online_cpus'
>> include/linux/cpu.h:232:13: error: storage class specified for parameter 'put_online_cpus'
>> include/linux/cpu.h:233:13: error: storage class specified for parameter 'cpu_hotplug_disable'
>> include/linux/cpu.h:234:13: error: storage class specified for parameter 'cpu_hotplug_enable'
>> include/linux/cpu.h:263:12: error: storage class specified for parameter 'disable_nonboot_cpus'
>> include/linux/cpu.h:264:13: error: storage class specified for parameter 'enable_nonboot_cpus'
   include/linux/cpu.h:285:1: error: storage class specified for parameter 'cpu_dead_idle'
   include/linux/cpu.h:285:1: error: section attribute not allowed for 'cpu_dead_idle'
   In file included from mm/vmscan.c:36:0:
>> include/linux/cpuset.h:142:20: error: storage class specified for parameter 'cpusets_enabled'
>> include/linux/cpuset.h:142:20: warning: parameter 'cpusets_enabled' declared 'inline' [enabled by default]
>> include/linux/cpuset.h:142:1: warning: 'always_inline' attribute ignored [-Wattributes]
>> include/linux/cpuset.h:142:20: error: 'no_instrument_function' attribute applies only to functions

vim +/unregister_cpu +48 include/linux/cpu.h

^1da177e Linus Torvalds      2005-04-16   25  	int node_id;		/* The node which contains the CPU */
72486f1f Siddha, Suresh B    2006-12-07   26  	int hotpluggable;	/* creates sysfs control file if hotpluggable */
8a25a2fd Kay Sievers         2011-12-21   27  	struct device dev;
^1da177e Linus Torvalds      2005-04-16   28  };
^1da177e Linus Torvalds      2005-04-16   29  
76b67ed9 KAMEZAWA Hiroyuki   2006-06-27   30  extern int register_cpu(struct cpu *cpu, int num);
8a25a2fd Kay Sievers         2011-12-21  @31  extern struct device *get_cpu_device(unsigned cpu);
2987557f Josh Triplett       2011-12-03  @32  extern bool cpu_is_hotpluggable(unsigned cpu);
183912d3 Sudeep Holla        2013-08-15  @33  extern bool arch_match_cpu_phys_id(int cpu, u64 phys_id);
d1cb9d1a David Miller        2013-10-03   34  extern bool arch_find_n_match_cpu_physical_id(struct device_node *cpun,
d1cb9d1a David Miller        2013-10-03   35  					      int cpu, unsigned int *thread);
0344c6c5 Christian Krafft    2006-10-24   36  
8a25a2fd Kay Sievers         2011-12-21  @37  extern int cpu_add_dev_attr(struct device_attribute *attr);
8a25a2fd Kay Sievers         2011-12-21  @38  extern void cpu_remove_dev_attr(struct device_attribute *attr);
0344c6c5 Christian Krafft    2006-10-24   39  
8a25a2fd Kay Sievers         2011-12-21  @40  extern int cpu_add_dev_attr_group(struct attribute_group *attrs);
8a25a2fd Kay Sievers         2011-12-21  @41  extern void cpu_remove_dev_attr_group(struct attribute_group *attrs);
0344c6c5 Christian Krafft    2006-10-24   42  
8db14860 Nicolas Iooss       2015-07-17   43  extern __printf(4, 5)
8db14860 Nicolas Iooss       2015-07-17  @44  struct device *cpu_device_create(struct device *parent, void *drvdata,
3d52943b Sudeep Holla        2014-09-30   45  				 const struct attribute_group **groups,
3d52943b Sudeep Holla        2014-09-30   46  				 const char *fmt, ...);
^1da177e Linus Torvalds      2005-04-16   47  #ifdef CONFIG_HOTPLUG_CPU
76b67ed9 KAMEZAWA Hiroyuki   2006-06-27  @48  extern void unregister_cpu(struct cpu *cpu);
12633e80 Nathan Fontenot     2009-11-25  @49  extern ssize_t arch_cpu_probe(const char *, size_t);
12633e80 Nathan Fontenot     2009-11-25  @50  extern ssize_t arch_cpu_release(const char *, size_t);
^1da177e Linus Torvalds      2005-04-16   51  #endif
^1da177e Linus Torvalds      2005-04-16   52  struct notifier_block;
^1da177e Linus Torvalds      2005-04-16   53  
50a323b7 Tejun Heo           2010-06-08   54  /*
50a323b7 Tejun Heo           2010-06-08   55   * CPU notifier priorities.
50a323b7 Tejun Heo           2010-06-08   56   */
50a323b7 Tejun Heo           2010-06-08   57  enum {
3a101d05 Tejun Heo           2010-06-08   58  	/*
3a101d05 Tejun Heo           2010-06-08   59  	 * SCHED_ACTIVE marks a cpu which is coming up active during
3a101d05 Tejun Heo           2010-06-08   60  	 * CPU_ONLINE and CPU_DOWN_FAILED and must be the first
3a101d05 Tejun Heo           2010-06-08   61  	 * notifier.  CPUSET_ACTIVE adjusts cpuset according to
3a101d05 Tejun Heo           2010-06-08   62  	 * cpu_active mask right after SCHED_ACTIVE.  During
3a101d05 Tejun Heo           2010-06-08   63  	 * CPU_DOWN_PREPARE, SCHED_INACTIVE and CPUSET_INACTIVE are
3a101d05 Tejun Heo           2010-06-08   64  	 * ordered in the similar way.
3a101d05 Tejun Heo           2010-06-08   65  	 *
3a101d05 Tejun Heo           2010-06-08   66  	 * This ordering guarantees consistent cpu_active mask and
3a101d05 Tejun Heo           2010-06-08   67  	 * migration behavior to all cpu notifiers.
3a101d05 Tejun Heo           2010-06-08   68  	 */
3a101d05 Tejun Heo           2010-06-08   69  	CPU_PRI_SCHED_ACTIVE	= INT_MAX,
3a101d05 Tejun Heo           2010-06-08   70  	CPU_PRI_CPUSET_ACTIVE	= INT_MAX - 1,
3a101d05 Tejun Heo           2010-06-08   71  	CPU_PRI_SCHED_INACTIVE	= INT_MIN + 1,
3a101d05 Tejun Heo           2010-06-08   72  	CPU_PRI_CPUSET_INACTIVE	= INT_MIN,
3a101d05 Tejun Heo           2010-06-08   73  
50a323b7 Tejun Heo           2010-06-08   74  	/* migration should happen before other stuff but after perf */
50a323b7 Tejun Heo           2010-06-08   75  	CPU_PRI_PERF		= 20,
50a323b7 Tejun Heo           2010-06-08   76  	CPU_PRI_MIGRATION	= 10,
00df35f9 Paul E. McKenney    2015-04-12   77  	CPU_PRI_SMPBOOT		= 9,
65758202 Tejun Heo           2012-07-17   78  	/* bring up workqueues before normal notifiers and down after */
65758202 Tejun Heo           2012-07-17   79  	CPU_PRI_WORKQUEUE_UP	= 5,
65758202 Tejun Heo           2012-07-17   80  	CPU_PRI_WORKQUEUE_DOWN	= -5,
50a323b7 Tejun Heo           2010-06-08   81  };
50a323b7 Tejun Heo           2010-06-08   82  
80f1ff97 Amerigo Wang        2011-07-25   83  #define CPU_ONLINE		0x0002 /* CPU (unsigned)v is up */
80f1ff97 Amerigo Wang        2011-07-25   84  #define CPU_UP_PREPARE		0x0003 /* CPU (unsigned)v coming up */
80f1ff97 Amerigo Wang        2011-07-25   85  #define CPU_UP_CANCELED		0x0004 /* CPU (unsigned)v NOT coming up */
80f1ff97 Amerigo Wang        2011-07-25   86  #define CPU_DOWN_PREPARE	0x0005 /* CPU (unsigned)v going down */
80f1ff97 Amerigo Wang        2011-07-25   87  #define CPU_DOWN_FAILED		0x0006 /* CPU (unsigned)v NOT going down */
80f1ff97 Amerigo Wang        2011-07-25   88  #define CPU_DEAD		0x0007 /* CPU (unsigned)v dead */
80f1ff97 Amerigo Wang        2011-07-25   89  #define CPU_DYING		0x0008 /* CPU (unsigned)v not running any task,
80f1ff97 Amerigo Wang        2011-07-25   90  					* not handling interrupts, soon dead.
80f1ff97 Amerigo Wang        2011-07-25   91  					* Called on the dying cpu, interrupts
80f1ff97 Amerigo Wang        2011-07-25   92  					* are already disabled. Must not
80f1ff97 Amerigo Wang        2011-07-25   93  					* sleep, must not fail */
80f1ff97 Amerigo Wang        2011-07-25   94  #define CPU_POST_DEAD		0x0009 /* CPU (unsigned)v dead, cpu_hotplug
80f1ff97 Amerigo Wang        2011-07-25   95  					* lock is dropped */
80f1ff97 Amerigo Wang        2011-07-25   96  #define CPU_STARTING		0x000A /* CPU (unsigned)v soon running.
80f1ff97 Amerigo Wang        2011-07-25   97  					* Called on the new cpu, just before
80f1ff97 Amerigo Wang        2011-07-25   98  					* enabling interrupts. Must not sleep,
80f1ff97 Amerigo Wang        2011-07-25   99  					* must not fail */
88428cc5 Paul E. McKenney    2015-01-28  100  #define CPU_DYING_IDLE		0x000B /* CPU (unsigned)v dying, reached
88428cc5 Paul E. McKenney    2015-01-28  101  					* idle loop. */
8038dad7 Paul E. McKenney    2015-02-25  102  #define CPU_BROKEN		0x000C /* CPU (unsigned)v did not die properly,
8038dad7 Paul E. McKenney    2015-02-25  103  					* perhaps due to preemption. */
80f1ff97 Amerigo Wang        2011-07-25  104  
80f1ff97 Amerigo Wang        2011-07-25  105  /* Used for CPU hotplug events occurring while tasks are frozen due to a suspend
80f1ff97 Amerigo Wang        2011-07-25  106   * operation in progress
80f1ff97 Amerigo Wang        2011-07-25  107   */
80f1ff97 Amerigo Wang        2011-07-25  108  #define CPU_TASKS_FROZEN	0x0010
80f1ff97 Amerigo Wang        2011-07-25  109  
80f1ff97 Amerigo Wang        2011-07-25  110  #define CPU_ONLINE_FROZEN	(CPU_ONLINE | CPU_TASKS_FROZEN)
80f1ff97 Amerigo Wang        2011-07-25  111  #define CPU_UP_PREPARE_FROZEN	(CPU_UP_PREPARE | CPU_TASKS_FROZEN)
80f1ff97 Amerigo Wang        2011-07-25  112  #define CPU_UP_CANCELED_FROZEN	(CPU_UP_CANCELED | CPU_TASKS_FROZEN)
80f1ff97 Amerigo Wang        2011-07-25  113  #define CPU_DOWN_PREPARE_FROZEN	(CPU_DOWN_PREPARE | CPU_TASKS_FROZEN)
80f1ff97 Amerigo Wang        2011-07-25  114  #define CPU_DOWN_FAILED_FROZEN	(CPU_DOWN_FAILED | CPU_TASKS_FROZEN)
80f1ff97 Amerigo Wang        2011-07-25  115  #define CPU_DEAD_FROZEN		(CPU_DEAD | CPU_TASKS_FROZEN)
80f1ff97 Amerigo Wang        2011-07-25  116  #define CPU_DYING_FROZEN	(CPU_DYING | CPU_TASKS_FROZEN)
80f1ff97 Amerigo Wang        2011-07-25  117  #define CPU_STARTING_FROZEN	(CPU_STARTING | CPU_TASKS_FROZEN)
80f1ff97 Amerigo Wang        2011-07-25  118  
80f1ff97 Amerigo Wang        2011-07-25  119  
^1da177e Linus Torvalds      2005-04-16  120  #ifdef CONFIG_SMP
^1da177e Linus Torvalds      2005-04-16  121  /* Need to know about CPUs going up/down? */
799e64f0 Paul E. McKenney    2009-08-15  122  #if defined(CONFIG_HOTPLUG_CPU) || !defined(MODULE)
799e64f0 Paul E. McKenney    2009-08-15  123  #define cpu_notifier(fn, pri) {					\
0db0628d Paul Gortmaker      2013-06-19  124  	static struct notifier_block fn##_nb =			\
799e64f0 Paul E. McKenney    2009-08-15  125  		{ .notifier_call = fn, .priority = pri };	\
799e64f0 Paul E. McKenney    2009-08-15  126  	register_cpu_notifier(&fn##_nb);			\
799e64f0 Paul E. McKenney    2009-08-15  127  }
93ae4f97 Srivatsa S. Bhat    2014-03-11  128  
93ae4f97 Srivatsa S. Bhat    2014-03-11  129  #define __cpu_notifier(fn, pri) {				\
93ae4f97 Srivatsa S. Bhat    2014-03-11  130  	static struct notifier_block fn##_nb =			\
93ae4f97 Srivatsa S. Bhat    2014-03-11  131  		{ .notifier_call = fn, .priority = pri };	\
93ae4f97 Srivatsa S. Bhat    2014-03-11  132  	__register_cpu_notifier(&fn##_nb);			\
93ae4f97 Srivatsa S. Bhat    2014-03-11  133  }
799e64f0 Paul E. McKenney    2009-08-15  134  #else /* #if defined(CONFIG_HOTPLUG_CPU) || !defined(MODULE) */
799e64f0 Paul E. McKenney    2009-08-15  135  #define cpu_notifier(fn, pri)	do { (void)(fn); } while (0)
93ae4f97 Srivatsa S. Bhat    2014-03-11  136  #define __cpu_notifier(fn, pri)	do { (void)(fn); } while (0)
799e64f0 Paul E. McKenney    2009-08-15  137  #endif /* #else #if defined(CONFIG_HOTPLUG_CPU) || !defined(MODULE) */
93ae4f97 Srivatsa S. Bhat    2014-03-11  138  
65edc68c Chandra Seetharaman 2006-06-27  139  #ifdef CONFIG_HOTPLUG_CPU
47e627bc Avi Kivity          2007-02-12 @140  extern int register_cpu_notifier(struct notifier_block *nb);
93ae4f97 Srivatsa S. Bhat    2014-03-11 @141  extern int __register_cpu_notifier(struct notifier_block *nb);
^1da177e Linus Torvalds      2005-04-16 @142  extern void unregister_cpu_notifier(struct notifier_block *nb);
93ae4f97 Srivatsa S. Bhat    2014-03-11 @143  extern void __unregister_cpu_notifier(struct notifier_block *nb);
65edc68c Chandra Seetharaman 2006-06-27  144  #else
47e627bc Avi Kivity          2007-02-12  145  
47e627bc Avi Kivity          2007-02-12  146  #ifndef MODULE
47e627bc Avi Kivity          2007-02-12  147  extern int register_cpu_notifier(struct notifier_block *nb);
93ae4f97 Srivatsa S. Bhat    2014-03-11  148  extern int __register_cpu_notifier(struct notifier_block *nb);
47e627bc Avi Kivity          2007-02-12  149  #else
47e627bc Avi Kivity          2007-02-12  150  static inline int register_cpu_notifier(struct notifier_block *nb)
47e627bc Avi Kivity          2007-02-12  151  {
47e627bc Avi Kivity          2007-02-12  152  	return 0;
47e627bc Avi Kivity          2007-02-12  153  }
93ae4f97 Srivatsa S. Bhat    2014-03-11  154  
93ae4f97 Srivatsa S. Bhat    2014-03-11  155  static inline int __register_cpu_notifier(struct notifier_block *nb)
93ae4f97 Srivatsa S. Bhat    2014-03-11  156  {
93ae4f97 Srivatsa S. Bhat    2014-03-11  157  	return 0;
93ae4f97 Srivatsa S. Bhat    2014-03-11  158  }
47e627bc Avi Kivity          2007-02-12  159  #endif
47e627bc Avi Kivity          2007-02-12  160  
65edc68c Chandra Seetharaman 2006-06-27  161  static inline void unregister_cpu_notifier(struct notifier_block *nb)
65edc68c Chandra Seetharaman 2006-06-27  162  {
65edc68c Chandra Seetharaman 2006-06-27  163  }
93ae4f97 Srivatsa S. Bhat    2014-03-11  164  
93ae4f97 Srivatsa S. Bhat    2014-03-11  165  static inline void __unregister_cpu_notifier(struct notifier_block *nb)
93ae4f97 Srivatsa S. Bhat    2014-03-11  166  {
93ae4f97 Srivatsa S. Bhat    2014-03-11  167  }
65edc68c Chandra Seetharaman 2006-06-27  168  #endif
^1da177e Linus Torvalds      2005-04-16  169  
00df35f9 Paul E. McKenney    2015-04-12  170  void smpboot_thread_init(void);
^1da177e Linus Torvalds      2005-04-16  171  int cpu_up(unsigned int cpu);
e545a614 Manfred Spraul      2008-09-07  172  void notify_cpu_starting(unsigned int cpu);
3da1c84c Oleg Nesterov       2008-07-25 @173  extern void cpu_maps_update_begin(void);
3da1c84c Oleg Nesterov       2008-07-25 @174  extern void cpu_maps_update_done(void);
d0d23b54 Ingo Molnar         2008-01-25  175  
93ae4f97 Srivatsa S. Bhat    2014-03-11  176  #define cpu_notifier_register_begin	cpu_maps_update_begin
93ae4f97 Srivatsa S. Bhat    2014-03-11  177  #define cpu_notifier_register_done	cpu_maps_update_done
93ae4f97 Srivatsa S. Bhat    2014-03-11  178  
3da1c84c Oleg Nesterov       2008-07-25  179  #else	/* CONFIG_SMP */
^1da177e Linus Torvalds      2005-04-16  180  
799e64f0 Paul E. McKenney    2009-08-15  181  #define cpu_notifier(fn, pri)	do { (void)(fn); } while (0)
93ae4f97 Srivatsa S. Bhat    2014-03-11  182  #define __cpu_notifier(fn, pri)	do { (void)(fn); } while (0)
799e64f0 Paul E. McKenney    2009-08-15  183  
^1da177e Linus Torvalds      2005-04-16  184  static inline int register_cpu_notifier(struct notifier_block *nb)
^1da177e Linus Torvalds      2005-04-16  185  {
^1da177e Linus Torvalds      2005-04-16  186  	return 0;
^1da177e Linus Torvalds      2005-04-16  187  }
d0d23b54 Ingo Molnar         2008-01-25  188  
93ae4f97 Srivatsa S. Bhat    2014-03-11  189  static inline int __register_cpu_notifier(struct notifier_block *nb)
93ae4f97 Srivatsa S. Bhat    2014-03-11  190  {
93ae4f97 Srivatsa S. Bhat    2014-03-11  191  	return 0;
93ae4f97 Srivatsa S. Bhat    2014-03-11  192  }
93ae4f97 Srivatsa S. Bhat    2014-03-11  193  
^1da177e Linus Torvalds      2005-04-16  194  static inline void unregister_cpu_notifier(struct notifier_block *nb)
^1da177e Linus Torvalds      2005-04-16  195  {
^1da177e Linus Torvalds      2005-04-16  196  }
^1da177e Linus Torvalds      2005-04-16  197  
93ae4f97 Srivatsa S. Bhat    2014-03-11  198  static inline void __unregister_cpu_notifier(struct notifier_block *nb)
93ae4f97 Srivatsa S. Bhat    2014-03-11  199  {
93ae4f97 Srivatsa S. Bhat    2014-03-11  200  }
93ae4f97 Srivatsa S. Bhat    2014-03-11  201  
3da1c84c Oleg Nesterov       2008-07-25  202  static inline void cpu_maps_update_begin(void)
3da1c84c Oleg Nesterov       2008-07-25  203  {
3da1c84c Oleg Nesterov       2008-07-25  204  }
3da1c84c Oleg Nesterov       2008-07-25  205  
3da1c84c Oleg Nesterov       2008-07-25  206  static inline void cpu_maps_update_done(void)
3da1c84c Oleg Nesterov       2008-07-25  207  {
3da1c84c Oleg Nesterov       2008-07-25  208  }
3da1c84c Oleg Nesterov       2008-07-25  209  
93ae4f97 Srivatsa S. Bhat    2014-03-11  210  static inline void cpu_notifier_register_begin(void)
93ae4f97 Srivatsa S. Bhat    2014-03-11  211  {
93ae4f97 Srivatsa S. Bhat    2014-03-11  212  }
93ae4f97 Srivatsa S. Bhat    2014-03-11  213  
93ae4f97 Srivatsa S. Bhat    2014-03-11  214  static inline void cpu_notifier_register_done(void)
93ae4f97 Srivatsa S. Bhat    2014-03-11  215  {
93ae4f97 Srivatsa S. Bhat    2014-03-11  216  }
93ae4f97 Srivatsa S. Bhat    2014-03-11  217  
590ee7db Ingo Molnar         2015-04-13  218  static inline void smpboot_thread_init(void)
590ee7db Ingo Molnar         2015-04-13  219  {
590ee7db Ingo Molnar         2015-04-13  220  }
590ee7db Ingo Molnar         2015-04-13  221  
^1da177e Linus Torvalds      2005-04-16  222  #endif /* CONFIG_SMP */
8a25a2fd Kay Sievers         2011-12-21 @223  extern struct bus_type cpu_subsys;
^1da177e Linus Torvalds      2005-04-16  224  
^1da177e Linus Torvalds      2005-04-16  225  #ifdef CONFIG_HOTPLUG_CPU
^1da177e Linus Torvalds      2005-04-16  226  /* Stop CPUs going up and down. */
f7dff2b1 Gautham R Shenoy    2006-12-06  227  
b9d10be7 Toshi Kani          2013-08-12 @228  extern void cpu_hotplug_begin(void);
b9d10be7 Toshi Kani          2013-08-12 @229  extern void cpu_hotplug_done(void);
86ef5c9a Gautham R Shenoy    2008-01-25 @230  extern void get_online_cpus(void);
dd56af42 Paul E. McKenney    2014-08-25  231  extern bool try_get_online_cpus(void);
86ef5c9a Gautham R Shenoy    2008-01-25 @232  extern void put_online_cpus(void);
16e53dbf Srivatsa S. Bhat    2013-06-12 @233  extern void cpu_hotplug_disable(void);
16e53dbf Srivatsa S. Bhat    2013-06-12 @234  extern void cpu_hotplug_enable(void);
799e64f0 Paul E. McKenney    2009-08-15  235  #define hotcpu_notifier(fn, pri)	cpu_notifier(fn, pri)
93ae4f97 Srivatsa S. Bhat    2014-03-11  236  #define __hotcpu_notifier(fn, pri)	__cpu_notifier(fn, pri)
39f4885c Chandra Seetharaman 2006-06-27  237  #define register_hotcpu_notifier(nb)	register_cpu_notifier(nb)

:::::: The code at line 48 was first introduced by commit
:::::: 76b67ed9dce69a6a329cdd66f94af1787f417b62 [PATCH] node hotplug: register cpu: remove node struct

:::::: TO: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
:::::: CC: Linus Torvalds <torvalds@g5.osdl.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--W/nzBZO5zC0uMSeA
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--W/nzBZO5zC0uMSeA--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
