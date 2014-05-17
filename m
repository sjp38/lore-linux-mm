Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 5D2E06B0036
	for <linux-mm@kvack.org>; Fri, 16 May 2014 22:42:14 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so3261640pab.8
        for <linux-mm@kvack.org>; Fri, 16 May 2014 19:42:14 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id rm9si5573889pbc.122.2014.05.16.19.42.13
        for <linux-mm@kvack.org>;
        Fri, 16 May 2014 19:42:13 -0700 (PDT)
Date: Sat, 17 May 2014 10:41:06 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 446/499] kernel/power/main.c:27:8: warning: excess
 elements in struct initializer
Message-ID: <5376cc42.lvo2sg2jazqx4CF4%fengguang.wu@intel.com>
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
config: make ARCH=arm marzen_defconfig

All warnings:

>> kernel/power/main.c:27:8: warning: excess elements in struct initializer [enabled by default]
>> kernel/power/main.c:27:8: warning: (near initialization for 'pm_chain_head.rwsem') [enabled by default]
>> kernel/power/main.c:27:8: warning: excess elements in struct initializer [enabled by default]
>> kernel/power/main.c:27:8: warning: (near initialization for 'pm_chain_head.rwsem') [enabled by default]
--
>> drivers/base/power/qos.c:52:8: warning: excess elements in struct initializer [enabled by default]
>> drivers/base/power/qos.c:52:8: warning: (near initialization for 'dev_pm_notifiers.rwsem') [enabled by default]
>> drivers/base/power/qos.c:52:8: warning: excess elements in struct initializer [enabled by default]
>> drivers/base/power/qos.c:52:8: warning: (near initialization for 'dev_pm_notifiers.rwsem') [enabled by default]
--
>> drivers/leds/led-core.c:21:1: warning: excess elements in struct initializer [enabled by default]
>> drivers/leds/led-core.c:21:1: warning: (near initialization for 'leds_list_lock') [enabled by default]
>> drivers/leds/led-core.c:21:1: warning: excess elements in struct initializer [enabled by default]
>> drivers/leds/led-core.c:21:1: warning: (near initialization for 'leds_list_lock') [enabled by default]
--
>> drivers/leds/led-triggers.c:28:8: warning: excess elements in struct initializer [enabled by default]
>> drivers/leds/led-triggers.c:28:8: warning: (near initialization for 'triggers_list_lock') [enabled by default]
>> drivers/leds/led-triggers.c:28:8: warning: excess elements in struct initializer [enabled by default]
>> drivers/leds/led-triggers.c:28:8: warning: (near initialization for 'triggers_list_lock') [enabled by default]

vim +27 kernel/power/main.c

6e5fdeedc Paul Gortmaker    2011-05-26  11  #include <linux/export.h>
^1da177e4 Linus Torvalds    2005-04-16  12  #include <linux/kobject.h>
^1da177e4 Linus Torvalds    2005-04-16  13  #include <linux/string.h>
c5c6ba4e0 Rafael J. Wysocki 2006-09-25  14  #include <linux/resume-trace.h>
5e928f77a Rafael J. Wysocki 2009-08-18  15  #include <linux/workqueue.h>
2a77c46de ShuoX Liu         2011-08-10  16  #include <linux/debugfs.h>
2a77c46de ShuoX Liu         2011-08-10  17  #include <linux/seq_file.h>
^1da177e4 Linus Torvalds    2005-04-16  18  
^1da177e4 Linus Torvalds    2005-04-16  19  #include "power.h"
^1da177e4 Linus Torvalds    2005-04-16  20  
a6d709806 Stephen Hemminger 2006-12-06  21  DEFINE_MUTEX(pm_mutex);
^1da177e4 Linus Torvalds    2005-04-16  22  
cd51e61cf Rafael J. Wysocki 2011-02-11  23  #ifdef CONFIG_PM_SLEEP
cd51e61cf Rafael J. Wysocki 2011-02-11  24  
825257569 Alan Stern        2007-11-19  25  /* Routines for PM-transition notifications */
825257569 Alan Stern        2007-11-19  26  
825257569 Alan Stern        2007-11-19 @27  static BLOCKING_NOTIFIER_HEAD(pm_chain_head);
825257569 Alan Stern        2007-11-19  28  
825257569 Alan Stern        2007-11-19  29  int register_pm_notifier(struct notifier_block *nb)
825257569 Alan Stern        2007-11-19  30  {
825257569 Alan Stern        2007-11-19  31  	return blocking_notifier_chain_register(&pm_chain_head, nb);
825257569 Alan Stern        2007-11-19  32  }
825257569 Alan Stern        2007-11-19  33  EXPORT_SYMBOL_GPL(register_pm_notifier);
825257569 Alan Stern        2007-11-19  34  
825257569 Alan Stern        2007-11-19  35  int unregister_pm_notifier(struct notifier_block *nb)

:::::: The code at line 27 was first introduced by commit
:::::: 825257569350e913bee3bc918508c0aa6e3398cd PM: Convert PM notifiers to out-of-line code

:::::: TO: Alan Stern <stern@rowland.harvard.edu>
:::::: CC: Len Brown <len.brown@intel.com>

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
