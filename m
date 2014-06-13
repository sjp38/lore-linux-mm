Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id B2D4F6B0031
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 21:35:17 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id fp1so1553309pdb.10
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 18:35:17 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ka9si2903993pad.137.2014.06.12.18.35.16
        for <linux-mm@kvack.org>;
        Thu, 12 Jun 2014 18:35:16 -0700 (PDT)
Date: Fri, 13 Jun 2014 09:34:45 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 83/178] fs/proc/task_mmu.c:505:193: error: call to
 '__compiletime_assert_505' declared with attribute error: BUILD_BUG failed
Message-ID: <539a5535.0bA/HpUPLxngi4u7%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   a621774e0e7bbd9e8a024230af4704cc489bd40e
commit: d6dc10868bc1439159231b2353dbbfc635a0c104 [83/178] mm/pagewalk: move pmd_trans_huge_lock() from callbacks to common code
config: make ARCH=sh titan_defconfig

All error/warnings:

   fs/proc/task_mmu.c: In function 'smaps_pmd':
>> fs/proc/task_mmu.c:505:193: error: call to '__compiletime_assert_505' declared with attribute error: BUILD_BUG failed
>> fs/proc/task_mmu.c:506:178: error: call to '__compiletime_assert_506' declared with attribute error: BUILD_BUG failed

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
