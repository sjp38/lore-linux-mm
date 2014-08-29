Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 362476B0038
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 19:57:41 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id fp1so1436161pdb.13
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 16:57:40 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id ki10si2080089pbc.35.2014.08.29.16.57.39
        for <linux-mm@kvack.org>;
        Fri, 29 Aug 2014 16:57:40 -0700 (PDT)
Date: Sat, 30 Aug 2014 07:56:39 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 123/287] fs/proc/task_mmu.c:1426:27: error: 'task'
 undeclared
Message-ID: <54011337.obkqHml8e//Q+mnU%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   8f1fc64dc9b39fedb7390e086001ce5ec327e80d
commit: 8b38b95075137cd18b5e51bc48751c023d16c3fb [123/287] mempolicy: fix show_numa_map() vs exec() + do_set_mempolicy() race
config: make ARCH=x86_64 allmodconfig

Note: the mmotm/master HEAD 8f1fc64dc9b39fedb7390e086001ce5ec327e80d builds fine.
      It only hurts bisectibility.

All error/warnings:

   fs/proc/task_mmu.c: In function 'show_numa_map':
>> fs/proc/task_mmu.c:1426:27: error: 'task' undeclared (first use in this function)
      pid_t tid = vm_is_stack(task, vma, is_pid);
                              ^
   fs/proc/task_mmu.c:1426:27: note: each undeclared identifier is reported only once for each function it appears in

vim +/task +1426 fs/proc/task_mmu.c

f69ff943 Stephen Wilson     2011-05-24  1420  	if (file) {
17c2b4ee Fabian Frederick   2014-06-06  1421  		seq_puts(m, " file=");
f69ff943 Stephen Wilson     2011-05-24  1422  		seq_path(m, &file->f_path, "\n\t= ");
f69ff943 Stephen Wilson     2011-05-24  1423  	} else if (vma->vm_start <= mm->brk && vma->vm_end >= mm->start_brk) {
17c2b4ee Fabian Frederick   2014-06-06  1424  		seq_puts(m, " heap");
b7643757 Siddhesh Poyarekar 2012-03-21  1425  	} else {
32f8516a David Rientjes     2012-10-16 @1426  		pid_t tid = vm_is_stack(task, vma, is_pid);
b7643757 Siddhesh Poyarekar 2012-03-21  1427  		if (tid != 0) {
b7643757 Siddhesh Poyarekar 2012-03-21  1428  			/*
b7643757 Siddhesh Poyarekar 2012-03-21  1429  			 * Thread stack in /proc/PID/task/TID/maps or

:::::: The code at line 1426 was first introduced by commit
:::::: 32f8516a8c733d281faa9f6666b509035246505c mm, mempolicy: fix printing stack contents in numa_maps

:::::: TO: David Rientjes <rientjes@google.com>
:::::: CC: Linus Torvalds <torvalds@linux-foundation.org>

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
