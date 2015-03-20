Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id EBF7B6B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 03:06:12 -0400 (EDT)
Received: by pabxg6 with SMTP id xg6so87418835pab.0
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 00:06:12 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id g12si7759927pat.50.2015.03.20.00.06.11
        for <linux-mm@kvack.org>;
        Fri, 20 Mar 2015 00:06:12 -0700 (PDT)
Date: Fri, 20 Mar 2015 15:05:51 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 332/380] kernel/fork.c:697:37: sparse: incorrect type
 in argument 1 (different base types)
Message-ID: <201503201550.I45PtavU%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   60319c74c8a7816a4b392f51a12a77cde302262b
commit: 7a5f64d9a72a65046cfdc05a02f84e6462ae5bff [332/380] mm: rcu-protected get_mm_exe_file()
reproduce:
  # apt-get install sparse
  git checkout 7a5f64d9a72a65046cfdc05a02f84e6462ae5bff
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   kernel/fork.c:552:19: sparse: incorrect type in assignment (different address spaces)
   kernel/fork.c:552:19:    expected struct task_struct [noderef] <asn:4>*owner
   kernel/fork.c:552:19:    got struct task_struct *p
>> kernel/fork.c:697:37: sparse: incorrect type in argument 1 (different base types)
   kernel/fork.c:697:37:    expected struct lockdep_map *lock
   kernel/fork.c:697:37:    got struct rw_semaphore *<noident>
   kernel/fork.c:1036:9: sparse: incorrect type in assignment (different address spaces)
   kernel/fork.c:1036:9:    expected struct sighand_struct *volatile <noident>
   kernel/fork.c:1036:9:    got struct sighand_struct [noderef] <asn:4>*<noident>
   kernel/fork.c:1186:41: sparse: implicit cast to nocast type
   kernel/fork.c:1187:41: sparse: implicit cast to nocast type
   kernel/fork.c:1314:42: sparse: implicit cast to nocast type
   kernel/fork.c:1315:43: sparse: implicit cast to nocast type
   kernel/fork.c:1317:57: sparse: implicit cast to nocast type
   kernel/fork.c:1501:32: sparse: incorrect type in assignment (different address spaces)
   kernel/fork.c:1501:32:    expected struct task_struct [noderef] <asn:4>*real_parent
   kernel/fork.c:1501:32:    got struct task_struct *
   include/linux/ptrace.h:183:45: sparse: incorrect type in argument 2 (different address spaces)
   include/linux/ptrace.h:183:45:    expected struct task_struct *new_parent
   include/linux/ptrace.h:183:45:    got struct task_struct [noderef] <asn:4>*parent
   kernel/fork.c:1544:54: sparse: incorrect type in argument 2 (different address spaces)
   kernel/fork.c:1544:54:    expected struct list_head *head
   kernel/fork.c:1544:54:    got struct list_head [noderef] <asn:4>*<noident>
   kernel/fork.c:1279:27: sparse: dereference of noderef expression
   kernel/fork.c:1281:22: sparse: dereference of noderef expression
   kernel/fork.c:1614:22: sparse: dereference of noderef expression
   In file included from include/linux/srcu.h:33:0,
                    from include/linux/notifier.h:15,
                    from include/linux/memory_hotplug.h:6,
                    from include/linux/mmzone.h:790,
                    from include/linux/gfp.h:5,
                    from include/linux/slab.h:14,
                    from kernel/fork.c:14:
   kernel/fork.c: In function 'set_mm_exe_file':
   kernel/fork.c:699:17: warning: passing argument 1 of 'lock_is_held' from incompatible pointer type
       lock_is_held(&mm->mmap_sem));
                    ^
   include/linux/rcupdate.h:528:53: note: in definition of macro 'rcu_lockdep_assert'
      if (debug_lockdep_rcu_enabled() && !__warned && !(c)) { \
                                                        ^
   include/linux/rcupdate.h:810:2: note: in expansion of macro '__rcu_dereference_protected'
     __rcu_dereference_protected((p), (c), __rcu)
     ^
   kernel/fork.c:697:30: note: in expansion of macro 'rcu_dereference_protected'
     struct file *old_exe_file = rcu_dereference_protected(mm->exe_file,
                                 ^
   In file included from include/linux/spinlock_types.h:18:0,
                    from include/linux/spinlock.h:81,
                    from include/linux/mmzone.h:7,
                    from include/linux/gfp.h:5,
                    from include/linux/slab.h:14,
                    from kernel/fork.c:14:
   include/linux/lockdep.h:341:12: note: expected 'struct lockdep_map *' but argument is of type 'struct rw_semaphore *'
    extern int lock_is_held(struct lockdep_map *lock);
               ^
--
   kernel/sys.c:886:49: sparse: incorrect type in argument 2 (different modifiers)
   kernel/sys.c:886:49:    expected unsigned long [nocast] [usertype] *ut
   kernel/sys.c:886:49:    got unsigned long *<noident>
   kernel/sys.c:886:49: sparse: implicit cast to nocast type
   kernel/sys.c:886:59: sparse: incorrect type in argument 3 (different modifiers)
   kernel/sys.c:886:59:    expected unsigned long [nocast] [usertype] *st
   kernel/sys.c:886:59:    got unsigned long *<noident>
   kernel/sys.c:886:59: sparse: implicit cast to nocast type
   kernel/sys.c:948:32: sparse: incorrect type in argument 1 (different address spaces)
   kernel/sys.c:948:32:    expected struct task_struct *p1
   kernel/sys.c:948:32:    got struct task_struct [noderef] <asn:4>*real_parent
   kernel/sys.c:1550:25: sparse: implicit cast to nocast type
   kernel/sys.c:1553:49: sparse: incorrect type in argument 2 (different modifiers)
   kernel/sys.c:1553:49:    expected unsigned long [nocast] [usertype] *ut
   kernel/sys.c:1553:49:    got unsigned long *<noident>
   kernel/sys.c:1553:49: sparse: implicit cast to nocast type
   kernel/sys.c:1553:57: sparse: incorrect type in argument 3 (different modifiers)
   kernel/sys.c:1553:57:    expected unsigned long [nocast] [usertype] *st
   kernel/sys.c:1553:57:    got unsigned long *<noident>
   kernel/sys.c:1553:57: sparse: implicit cast to nocast type
   kernel/sys.c:1579:51: sparse: incorrect type in argument 2 (different modifiers)
   kernel/sys.c:1579:51:    expected unsigned long [nocast] [usertype] *ut
   kernel/sys.c:1579:51:    got unsigned long *<noident>
   kernel/sys.c:1579:51: sparse: implicit cast to nocast type
   kernel/sys.c:1579:61: sparse: incorrect type in argument 3 (different modifiers)
   kernel/sys.c:1579:61:    expected unsigned long [nocast] [usertype] *st
   kernel/sys.c:1579:61:    got unsigned long *<noident>
   kernel/sys.c:1579:61: sparse: implicit cast to nocast type
>> kernel/sys.c:1690:43: sparse: incorrect type in argument 2 (different address spaces)
   kernel/sys.c:1690:43:    expected struct path const *path2
   kernel/sys.c:1690:43:    got struct path [noderef] <asn:4>*<noident>
   kernel/sys.c:2034:16: sparse: incorrect type in argument 1 (different address spaces)
   kernel/sys.c:2034:16:    expected void const volatile [noderef] <asn:1>*<noident>
   kernel/sys.c:2034:16:    got int [noderef] <asn:1>**tid_addr

vim +697 kernel/fork.c

   681			mmdrop(mm);
   682		}
   683	}
   684	EXPORT_SYMBOL_GPL(mmput);
   685	
   686	/**
   687	 * set_mm_exe_file - change a reference to the mm's executable file
   688	 *
   689	 * This changes mm's executale file (shown as symlink /proc/[pid]/exe).
   690	 *
   691	 * Main users are mmput(), sys_execve() and sys_prctl(PR_SET_MM_MAP/EXE_FILE).
   692	 * Callers prevent concurrent invocations: in mmput() nobody alive left,
   693	 * in execve task is single-threaded, prctl holds mmap_sem exclusively.
   694	 */
   695	void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file)
   696	{
 > 697		struct file *old_exe_file = rcu_dereference_protected(mm->exe_file,
   698				!atomic_read(&mm->mm_users) || current->in_execve ||
   699				lock_is_held(&mm->mmap_sem));
   700	
   701		if (new_exe_file)
   702			get_file(new_exe_file);
   703		rcu_assign_pointer(mm->exe_file, new_exe_file);
   704		if (old_exe_file)
   705			fput(old_exe_file);

---
0-DAY kernel test infrastructure                Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
