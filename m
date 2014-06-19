Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 7C1BB6B0031
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 04:10:57 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id g10so1593633pdj.0
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 01:10:57 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id ey6si4982862pab.138.2014.06.19.01.10.56
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 01:10:56 -0700 (PDT)
Date: Thu, 19 Jun 2014 16:09:35 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [next:master 77/159] fs/proc/task_mmu.c:505:193: error: call to
 '__compiletime_assert_505' declared with attribute error: BUILD_BUG failed
Message-ID: <53a29abf.v2bhnSChDbNTCQGt%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   07d0e2d232fee3ff692c50150b2aa6e3b7755f8f
commit: b0e08c526179642dccfd2c7caff31d2419492829 [77/159] mm/pagewalk: move pmd_trans_huge_lock() from callbacks to common code
config: make ARCH=i386 defconfig

Note: the next/master HEAD 07d0e2d232fee3ff692c50150b2aa6e3b7755f8f builds fine.
      It only hurts bisectibility.

All error/warnings:

   fs/proc/task_mmu.c: In function 'smaps_pmd':
>> fs/proc/task_mmu.c:505:193: error: call to '__compiletime_assert_505' declared with attribute error: BUILD_BUG failed
     smaps_pte((pte_t *)pmd, addr, addr + HPAGE_PMD_SIZE, walk);
                                                                                                                                                                                                    ^
>> fs/proc/task_mmu.c:506:178: error: call to '__compiletime_assert_506' declared with attribute error: BUILD_BUG failed
     mss->anonymous_thp += HPAGE_PMD_SIZE;
                                                                                                                                                                                     ^

vim +/__compiletime_assert_505 +505 fs/proc/task_mmu.c

   499	}
   500	
   501	static int smaps_pmd(pmd_t *pmd, unsigned long addr, unsigned long end,
   502				struct mm_walk *walk)
   503	{
   504		struct mem_size_stats *mss = walk->private;
 > 505		smaps_pte((pte_t *)pmd, addr, addr + HPAGE_PMD_SIZE, walk);
 > 506		mss->anonymous_thp += HPAGE_PMD_SIZE;
   507		return 0;
   508	}
   509	

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
