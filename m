Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 9C06A6B0035
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 21:45:17 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id ma3so1369202pbc.1
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 18:45:17 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id cw3si365614pbc.117.2014.06.12.18.45.16
        for <linux-mm@kvack.org>;
        Thu, 12 Jun 2014 18:45:16 -0700 (PDT)
Date: Fri, 13 Jun 2014 09:45:09 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 83/178] fs/proc/task_mmu.c:1330:9: error: call to
 '__compiletime_assert_1330' declared with attribute error: BUILD_BUG failed
Message-ID: <539a57a5.ZwFFTH050wXkgXku%fengguang.wu@intel.com>
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
config: make ARCH=ia64 allmodconfig

All error/warnings:

   fs/proc/task_mmu.c: In function 'gather_pmd_stats':
>> fs/proc/task_mmu.c:1330:9: error: call to '__compiletime_assert_1330' declared with attribute error: BUILD_BUG failed
   fs/proc/task_mmu.c: In function 'smaps_pmd':
   fs/proc/task_mmu.c:505:39: error: call to '__compiletime_assert_505' declared with attribute error: BUILD_BUG failed
   fs/proc/task_mmu.c:506:24: error: call to '__compiletime_assert_506' declared with attribute error: BUILD_BUG failed

vim +/__compiletime_assert_1330 +1330 fs/proc/task_mmu.c

  1324		pte_t huge_pte = *(pte_t *)pmd;
  1325		struct page *page;
  1326	
  1327		page = can_gather_numa_stats(huge_pte, vma, addr);
  1328		if (page)
  1329			gather_stats(page, md, pte_dirty(huge_pte),
> 1330				     HPAGE_PMD_SIZE/PAGE_SIZE);
  1331		return 0;
  1332	}
  1333	#ifdef CONFIG_HUGETLB_PAGE

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
