Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4CA386B0035
	for <linux-mm@kvack.org>; Fri, 16 May 2014 20:20:44 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kq14so3230287pab.10
        for <linux-mm@kvack.org>; Fri, 16 May 2014 17:20:43 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id yk1si5414308pbb.486.2014.05.16.17.20.42
        for <linux-mm@kvack.org>;
        Fri, 16 May 2014 17:20:43 -0700 (PDT)
Date: Sat, 17 May 2014 08:20:20 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 446/499] kernel/sys.c:1080:1: warning: excess
 elements in struct initializer
Message-ID: <5376ab44.fpxV4OL47w7T6+Y+%fengguang.wu@intel.com>
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
config: make ARCH=m32r mappi3.smp_defconfig

All warnings:

>> kernel/sys.c:1080:1: warning: excess elements in struct initializer [enabled by default]
>> kernel/sys.c:1080:1: warning: (near initialization for 'uts_sem') [enabled by default]
>> kernel/sys.c:1080:1: warning: excess elements in struct initializer [enabled by default]
>> kernel/sys.c:1080:1: warning: (near initialization for 'uts_sem') [enabled by default]
--
>> kernel/kmod.c:63:8: warning: excess elements in struct initializer [enabled by default]
>> kernel/kmod.c:63:8: warning: (near initialization for 'umhelper_sem') [enabled by default]
>> kernel/kmod.c:63:8: warning: excess elements in struct initializer [enabled by default]
>> kernel/kmod.c:63:8: warning: (near initialization for 'umhelper_sem') [enabled by default]
--
>> kernel/notifier.c:14:1: warning: excess elements in struct initializer [enabled by default]
>> kernel/notifier.c:14:1: warning: (near initialization for 'reboot_notifier_list.rwsem') [enabled by default]
>> kernel/notifier.c:14:1: warning: excess elements in struct initializer [enabled by default]
>> kernel/notifier.c:14:1: warning: (near initialization for 'reboot_notifier_list.rwsem') [enabled by default]
--
   kernel/module.c:156:8: warning: excess elements in struct initializer [enabled by default]
>> kernel/module.c:156:8: warning: (near initialization for 'module_notify_list.rwsem') [enabled by default]
   kernel/module.c:156:8: warning: excess elements in struct initializer [enabled by default]
>> kernel/module.c:156:8: warning: (near initialization for 'module_notify_list.rwsem') [enabled by default]
--
>> mm/oom_kill.c:543:8: warning: excess elements in struct initializer [enabled by default]
>> mm/oom_kill.c:543:8: warning: (near initialization for 'oom_notify_list.rwsem') [enabled by default]
>> mm/oom_kill.c:543:8: warning: excess elements in struct initializer [enabled by default]
>> mm/oom_kill.c:543:8: warning: (near initialization for 'oom_notify_list.rwsem') [enabled by default]
--
>> mm/vmscan.c:139:8: warning: excess elements in struct initializer [enabled by default]
>> mm/vmscan.c:139:8: warning: (near initialization for 'shrinker_rwsem') [enabled by default]
>> mm/vmscan.c:139:8: warning: excess elements in struct initializer [enabled by default]
>> mm/vmscan.c:139:8: warning: (near initialization for 'shrinker_rwsem') [enabled by default]
--
>> mm/init-mm.c:21:2: warning: excess elements in struct initializer [enabled by default]
>> mm/init-mm.c:21:2: warning: (near initialization for 'init_mm.mmap_sem') [enabled by default]
>> mm/init-mm.c:21:2: warning: excess elements in struct initializer [enabled by default]
>> mm/init-mm.c:21:2: warning: (near initialization for 'init_mm.mmap_sem') [enabled by default]
--
>> fs/namespace.c:65:8: warning: excess elements in struct initializer [enabled by default]
>> fs/namespace.c:65:8: warning: (near initialization for 'namespace_sem') [enabled by default]
>> fs/namespace.c:65:8: warning: excess elements in struct initializer [enabled by default]
>> fs/namespace.c:65:8: warning: (near initialization for 'namespace_sem') [enabled by default]
--
>> ipc/ipcns_notifier.c:22:8: warning: excess elements in struct initializer [enabled by default]
>> ipc/ipcns_notifier.c:22:8: warning: (near initialization for 'ipcns_chain.rwsem') [enabled by default]
>> ipc/ipcns_notifier.c:22:8: warning: excess elements in struct initializer [enabled by default]
>> ipc/ipcns_notifier.c:22:8: warning: (near initialization for 'ipcns_chain.rwsem') [enabled by default]
--
>> crypto/api.c:31:1: warning: excess elements in struct initializer [enabled by default]
>> crypto/api.c:31:1: warning: (near initialization for 'crypto_alg_sem') [enabled by default]
>> crypto/api.c:31:1: warning: excess elements in struct initializer [enabled by default]
>> crypto/api.c:31:1: warning: (near initialization for 'crypto_alg_sem') [enabled by default]
>> crypto/api.c:34:1: warning: excess elements in struct initializer [enabled by default]
>> crypto/api.c:34:1: warning: (near initialization for 'crypto_chain.rwsem') [enabled by default]
>> crypto/api.c:34:1: warning: excess elements in struct initializer [enabled by default]
>> crypto/api.c:34:1: warning: (near initialization for 'crypto_chain.rwsem') [enabled by default]
--
>> net/ipv4/devinet.c:179:8: warning: excess elements in struct initializer [enabled by default]
>> net/ipv4/devinet.c:179:8: warning: (near initialization for 'inetaddr_chain.rwsem') [enabled by default]
>> net/ipv4/devinet.c:179:8: warning: excess elements in struct initializer [enabled by default]
>> net/ipv4/devinet.c:179:8: warning: (near initialization for 'inetaddr_chain.rwsem') [enabled by default]
..

vim +1080 kernel/sys.c

^1da177e Linus Torvalds        2005-04-16  1064  
e19f247a Oren Laadan           2006-01-08  1065  	group_leader->signal->leader = 1;
81dabb46 Oleg Nesterov         2013-07-03  1066  	set_special_pids(sid);
24ec839c Peter Zijlstra        2006-12-08  1067  
9c9f4ded Alan Cox              2008-10-13  1068  	proc_clear_tty(group_leader);
24ec839c Peter Zijlstra        2006-12-08  1069  
e4cc0a9c Oleg Nesterov         2008-02-08  1070  	err = session;
^1da177e Linus Torvalds        2005-04-16  1071  out:
^1da177e Linus Torvalds        2005-04-16  1072  	write_unlock_irq(&tasklist_lock);
5091faa4 Mike Galbraith        2010-11-30  1073  	if (err > 0) {
0d0df599 Christian Borntraeger 2009-10-26  1074  		proc_sid_connector(group_leader);
5091faa4 Mike Galbraith        2010-11-30  1075  		sched_autogroup_create_attach(group_leader);
5091faa4 Mike Galbraith        2010-11-30  1076  	}
^1da177e Linus Torvalds        2005-04-16  1077  	return err;
^1da177e Linus Torvalds        2005-04-16  1078  }
^1da177e Linus Torvalds        2005-04-16  1079  
^1da177e Linus Torvalds        2005-04-16 @1080  DECLARE_RWSEM(uts_sem);
^1da177e Linus Torvalds        2005-04-16  1081  
e28cbf22 Christoph Hellwig     2010-03-10  1082  #ifdef COMPAT_UTS_MACHINE
e28cbf22 Christoph Hellwig     2010-03-10  1083  #define override_architecture(name) \
46da2766 Andreas Schwab        2010-04-23  1084  	(personality(current->personality) == PER_LINUX32 && \
e28cbf22 Christoph Hellwig     2010-03-10  1085  	 copy_to_user(name->machine, COMPAT_UTS_MACHINE, \
e28cbf22 Christoph Hellwig     2010-03-10  1086  		      sizeof(COMPAT_UTS_MACHINE)))
e28cbf22 Christoph Hellwig     2010-03-10  1087  #else
e28cbf22 Christoph Hellwig     2010-03-10  1088  #define override_architecture(name)	0

:::::: The code at line 1080 was first introduced by commit
:::::: 1da177e4c3f41524e886b7f1b8a0c1fc7321cac2 Linux-2.6.12-rc2

:::::: TO: Linus Torvalds <torvalds@ppc970.osdl.org>
:::::: CC: Linus Torvalds <torvalds@ppc970.osdl.org>

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
