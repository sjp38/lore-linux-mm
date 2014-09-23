Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 7B95F6B0035
	for <linux-mm@kvack.org>; Mon, 22 Sep 2014 21:29:30 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id g10so4998332pdj.33
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 18:29:30 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ig2si17828844pbb.232.2014.09.22.18.29.29
        for <linux-mm@kvack.org>;
        Mon, 22 Sep 2014 18:29:29 -0700 (PDT)
Date: Tue, 23 Sep 2014 09:28:53 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 169/385] mm/debug.c:215:5: error: 'const struct
 mm_struct' has no member named 'owner'
Message-ID: <5420ccd5.miNNRyVn5wct+fk+%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   eb076320e4dbdf99513732811ed8730812b34b2f
commit: bac27df2312993aedf1cdfa2dad43e5aeb29504d [169/385] mm: introduce VM_BUG_ON_MM
config: arm-tegra_defconfig
reproduce:
  wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
  chmod +x ~/bin/make.cross
  git checkout bac27df2312993aedf1cdfa2dad43e5aeb29504d
  make.cross ARCH=arm  tegra_defconfig
  make.cross ARCH=arm 

All error/warnings:

   mm/debug.c: In function 'dump_mm':
>> mm/debug.c:215:5: error: 'const struct mm_struct' has no member named 'owner'
      mm->owner, mm->exe_file,
        ^

vim +215 mm/debug.c

   209			mm->start_brk, mm->brk, mm->start_stack,
   210			mm->arg_start, mm->arg_end, mm->env_start, mm->env_end,
   211			mm->binfmt, mm->flags, mm->core_state,
   212	#ifdef CONFIG_AIO
   213			mm->ioctx_table,
   214	#endif
 > 215			mm->owner, mm->exe_file,
   216	#ifdef CONFIG_MMU_NOTIFIER
   217			mm->mmu_notifier_mm,
   218	#endif

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
