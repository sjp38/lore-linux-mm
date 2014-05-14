Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 887346B0036
	for <linux-mm@kvack.org>; Tue, 13 May 2014 21:11:44 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id ma3so965686pbc.10
        for <linux-mm@kvack.org>; Tue, 13 May 2014 18:11:44 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id iv2si120084pbd.39.2014.05.13.18.11.42
        for <linux-mm@kvack.org>;
        Tue, 13 May 2014 18:11:43 -0700 (PDT)
Date: Wed, 14 May 2014 09:10:21 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 233/499] include/linux/cpuset.h:21:2: error:
 implicit declaration of function 'static_key_false'
Message-ID: <5372c27d.kgJgiWwfZgW8gVhE%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   1055821ba3c83218cbba4481f8349e3326cdaa32
commit: 444d6ecdef95deb6009e1b8f9eae3ac32ba5ec57 [233/499] mm: page_alloc: use jump labels to avoid checking number_of_cpusets
config: make ARCH=tile tilegx_defconfig

All error/warnings:

   In file included from kernel/kthread.c:12:0:
   include/linux/cpuset.h: In function 'cpusets_enabled':
>> include/linux/cpuset.h:21:2: error: implicit declaration of function 'static_key_false'
   include/linux/cpuset.h: In function 'nr_cpusets':
>> include/linux/cpuset.h:27:2: error: implicit declaration of function 'static_key_count'
   include/linux/cpuset.h: In function 'cpuset_inc':
>> include/linux/cpuset.h:32:2: error: implicit declaration of function 'static_key_slow_inc'
   include/linux/cpuset.h: In function 'cpuset_dec':
>> include/linux/cpuset.h:37:2: error: implicit declaration of function 'static_key_slow_dec'
   In file included from include/linux/static_key.h:1:0,
   from include/linux/tracepoint.h:20,
   from include/trace/events/sched.h:8,
   from kernel/kthread.c:21:
   include/linux/jump_label.h: At top level:
>> include/linux/jump_label.h:87:19: error: static declaration of 'static_key_count' follows non-static declaration
   include/linux/cpuset.h:27:9: note: previous implicit declaration of 'static_key_count' was here
>> include/linux/jump_label.h:152:29: error: conflicting types for 'static_key_false'
   include/linux/cpuset.h:21:9: note: previous implicit declaration of 'static_key_false' was here
>> include/linux/jump_label.h:166:20: warning: conflicting types for 'static_key_slow_inc' [enabled by default]
>> include/linux/jump_label.h:166:20: error: static declaration of 'static_key_slow_inc' follows non-static declaration
   include/linux/cpuset.h:32:2: note: previous implicit declaration of 'static_key_slow_inc' was here
>> include/linux/jump_label.h:172:20: warning: conflicting types for 'static_key_slow_dec' [enabled by default]
>> include/linux/jump_label.h:172:20: error: static declaration of 'static_key_slow_dec' follows non-static declaration
   include/linux/cpuset.h:37:2: note: previous implicit declaration of 'static_key_slow_dec' was here
   cc1: some warnings being treated as errors
--
   In file included from kernel/cpuset.c:27:0:
   include/linux/cpuset.h: In function 'cpusets_enabled':
>> include/linux/cpuset.h:21:2: error: implicit declaration of function 'static_key_false'
   include/linux/cpuset.h: In function 'nr_cpusets':
>> include/linux/cpuset.h:27:2: error: implicit declaration of function 'static_key_count'
   include/linux/cpuset.h: In function 'cpuset_inc':
>> include/linux/cpuset.h:32:2: error: implicit declaration of function 'static_key_slow_inc'
   include/linux/cpuset.h: In function 'cpuset_dec':
>> include/linux/cpuset.h:37:2: error: implicit declaration of function 'static_key_slow_dec'
   In file included from include/linux/static_key.h:1:0,
   from include/linux/context_tracking_state.h:5,
   from include/linux/vtime.h:4,
   from include/linux/hardirq.h:7,
   from include/linux/interrupt.h:12,
   from kernel/cpuset.c:33:
   include/linux/jump_label.h: At top level:
>> include/linux/jump_label.h:87:19: error: static declaration of 'static_key_count' follows non-static declaration
   include/linux/cpuset.h:27:9: note: previous implicit declaration of 'static_key_count' was here
>> include/linux/jump_label.h:152:29: error: conflicting types for 'static_key_false'
   include/linux/cpuset.h:21:9: note: previous implicit declaration of 'static_key_false' was here
>> include/linux/jump_label.h:166:20: warning: conflicting types for 'static_key_slow_inc' [enabled by default]
>> include/linux/jump_label.h:166:20: error: static declaration of 'static_key_slow_inc' follows non-static declaration
   include/linux/cpuset.h:32:2: note: previous implicit declaration of 'static_key_slow_inc' was here
>> include/linux/jump_label.h:172:20: warning: conflicting types for 'static_key_slow_dec' [enabled by default]
>> include/linux/jump_label.h:172:20: error: static declaration of 'static_key_slow_dec' follows non-static declaration
   include/linux/cpuset.h:37:2: note: previous implicit declaration of 'static_key_slow_dec' was here
   cc1: some warnings being treated as errors

vim +/static_key_false +21 include/linux/cpuset.h

    15	
    16	#ifdef CONFIG_CPUSETS
    17	
    18	extern struct static_key cpusets_enabled_key;
    19	static inline bool cpusets_enabled(void)
    20	{
  > 21		return static_key_false(&cpusets_enabled_key);
    22	}
    23	
    24	static inline int nr_cpusets(void)
    25	{
    26		/* jump label reference count + the top-level cpuset */
    27		return static_key_count(&cpusets_enabled_key) + 1;
    28	}
    29	
    30	static inline void cpuset_inc(void)
    31	{
    32		static_key_slow_inc(&cpusets_enabled_key);
    33	}
    34	
    35	static inline void cpuset_dec(void)
    36	{
    37		static_key_slow_dec(&cpusets_enabled_key);
    38	}
    39	
    40	extern int cpuset_init(void);

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
