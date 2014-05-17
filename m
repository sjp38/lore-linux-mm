Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 5AC226B0036
	for <linux-mm@kvack.org>; Fri, 16 May 2014 20:38:46 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id md12so3297233pbc.1
        for <linux-mm@kvack.org>; Fri, 16 May 2014 17:38:46 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id wf9si10921721pab.230.2014.05.16.17.38.44
        for <linux-mm@kvack.org>;
        Fri, 16 May 2014 17:38:45 -0700 (PDT)
Date: Sat, 17 May 2014 08:38:04 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 446/499] init/init_task.c:14:44: warning: excess
 elements in struct initializer
Message-ID: <5376af6c.0gJ3V/8lqgY7KHOD%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   ff35dad6205c66d96feda494502753e5ed1b10f1
commit: 67039d034b422b074af336ebf8101346b6b5d441 [446/499] rwsem: Support optimistic spinning
config: make ARCH=mn10300 asb2364_defconfig

All warnings:

>> init/init_task.c:14:44: warning: excess elements in struct initializer [enabled by default]
>> init/init_task.c:14:44: warning: (near initialization for 'init_signals.group_rwsem') [enabled by default]
>> init/init_task.c:14:44: warning: excess elements in struct initializer [enabled by default]
>> init/init_task.c:14:44: warning: (near initialization for 'init_signals.group_rwsem') [enabled by default]
--
>> kernel/profile.c:133:8: warning: excess elements in struct initializer [enabled by default]
>> kernel/profile.c:133:8: warning: (near initialization for 'task_exit_notifier.rwsem') [enabled by default]
>> kernel/profile.c:133:8: warning: excess elements in struct initializer [enabled by default]
>> kernel/profile.c:133:8: warning: (near initialization for 'task_exit_notifier.rwsem') [enabled by default]
>> kernel/profile.c:135:8: warning: excess elements in struct initializer [enabled by default]
>> kernel/profile.c:135:8: warning: (near initialization for 'munmap_notifier.rwsem') [enabled by default]
>> kernel/profile.c:135:8: warning: excess elements in struct initializer [enabled by default]
>> kernel/profile.c:135:8: warning: (near initialization for 'munmap_notifier.rwsem') [enabled by default]
--
>> kernel/cgroup.c:90:8: warning: excess elements in struct initializer [enabled by default]
>> kernel/cgroup.c:90:8: warning: (near initialization for 'css_set_rwsem') [enabled by default]
>> kernel/cgroup.c:90:8: warning: excess elements in struct initializer [enabled by default]
>> kernel/cgroup.c:90:8: warning: (near initialization for 'css_set_rwsem') [enabled by default]
   kernel/cgroup.c: In function 'cgroup_mount':
   kernel/cgroup.c:1749:13: warning: 'root' may be used uninitialized in this function [-Wuninitialized]

vim +14 init/init_task.c

a4a2eb490 Thomas Gleixner 2012-05-03   1  #include <linux/init_task.h>
a4a2eb490 Thomas Gleixner 2012-05-03   2  #include <linux/export.h>
a4a2eb490 Thomas Gleixner 2012-05-03   3  #include <linux/mqueue.h>
a4a2eb490 Thomas Gleixner 2012-05-03   4  #include <linux/sched.h>
cf4aebc29 Clark Williams  2013-02-07   5  #include <linux/sched/sysctl.h>
8bd75c77b Clark Williams  2013-02-07   6  #include <linux/sched/rt.h>
a4a2eb490 Thomas Gleixner 2012-05-03   7  #include <linux/init.h>
a4a2eb490 Thomas Gleixner 2012-05-03   8  #include <linux/fs.h>
a4a2eb490 Thomas Gleixner 2012-05-03   9  #include <linux/mm.h>
a4a2eb490 Thomas Gleixner 2012-05-03  10  
a4a2eb490 Thomas Gleixner 2012-05-03  11  #include <asm/pgtable.h>
a4a2eb490 Thomas Gleixner 2012-05-03  12  #include <asm/uaccess.h>
a4a2eb490 Thomas Gleixner 2012-05-03  13  
a4a2eb490 Thomas Gleixner 2012-05-03 @14  static struct signal_struct init_signals = INIT_SIGNALS(init_signals);
a4a2eb490 Thomas Gleixner 2012-05-03  15  static struct sighand_struct init_sighand = INIT_SIGHAND(init_sighand);
a4a2eb490 Thomas Gleixner 2012-05-03  16  
a4a2eb490 Thomas Gleixner 2012-05-03  17  /* Initial task structure */
a4a2eb490 Thomas Gleixner 2012-05-03  18  struct task_struct init_task = INIT_TASK(init_task);
a4a2eb490 Thomas Gleixner 2012-05-03  19  EXPORT_SYMBOL(init_task);
a4a2eb490 Thomas Gleixner 2012-05-03  20  
a4a2eb490 Thomas Gleixner 2012-05-03  21  /*
a4a2eb490 Thomas Gleixner 2012-05-03  22   * Initial thread structure. Alignment of this is handled by a special

:::::: The code at line 14 was first introduced by commit
:::::: a4a2eb490e38aaff61eafcb8cde6725ad1be22ab init_task: Create generic init_task instance

:::::: TO: Thomas Gleixner <tglx@linutronix.de>
:::::: CC: Thomas Gleixner <tglx@linutronix.de>

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
