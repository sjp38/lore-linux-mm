Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id D5EB86B0253
	for <linux-mm@kvack.org>; Thu,  6 Aug 2015 05:50:13 -0400 (EDT)
Received: by pawu10 with SMTP id u10so59223093paw.1
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 02:50:13 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id w13si10458270pas.205.2015.08.06.02.50.12
        for <linux-mm@kvack.org>;
        Thu, 06 Aug 2015 02:50:12 -0700 (PDT)
Date: Thu, 6 Aug 2015 17:48:54 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [linux-next:master 6252/6518] include/linux/mmu_notifier.h:247:19:
 sparse: context imbalance in 'page_idle_clear_pte_refs_one' - unexpected
 unlock
Message-ID: <201508061748.2PzbGIFl%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   c6b169e6ffb962068153bd92b0c4ecbd731a122f
commit: cbba4e22584984bffccd07e0801fd2b8ec1ecf5f [6252/6518] Move /proc/kpageidle to /sys/kernel/mm/page_idle/bitmap
reproduce:
  # apt-get install sparse
  git checkout cbba4e22584984bffccd07e0801fd2b8ec1ecf5f
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> include/linux/mmu_notifier.h:247:19: sparse: context imbalance in 'page_idle_clear_pte_refs_one' - unexpected unlock

vim +/page_idle_clear_pte_refs_one +247 include/linux/mmu_notifier.h

cddb8a5c Andrea Arcangeli     2008-07-28  231  
cddb8a5c Andrea Arcangeli     2008-07-28  232  static inline void mmu_notifier_release(struct mm_struct *mm)
cddb8a5c Andrea Arcangeli     2008-07-28  233  {
cddb8a5c Andrea Arcangeli     2008-07-28  234  	if (mm_has_notifiers(mm))
cddb8a5c Andrea Arcangeli     2008-07-28  235  		__mmu_notifier_release(mm);
cddb8a5c Andrea Arcangeli     2008-07-28  236  }
cddb8a5c Andrea Arcangeli     2008-07-28  237  
cddb8a5c Andrea Arcangeli     2008-07-28  238  static inline int mmu_notifier_clear_flush_young(struct mm_struct *mm,
57128468 Andres Lagar-Cavilla 2014-09-22  239  					  unsigned long start,
57128468 Andres Lagar-Cavilla 2014-09-22  240  					  unsigned long end)
cddb8a5c Andrea Arcangeli     2008-07-28  241  {
cddb8a5c Andrea Arcangeli     2008-07-28  242  	if (mm_has_notifiers(mm))
57128468 Andres Lagar-Cavilla 2014-09-22  243  		return __mmu_notifier_clear_flush_young(mm, start, end);
cddb8a5c Andrea Arcangeli     2008-07-28  244  	return 0;
cddb8a5c Andrea Arcangeli     2008-07-28  245  }
cddb8a5c Andrea Arcangeli     2008-07-28  246  
632116f6 Vladimir Davydov     2015-08-06 @247  static inline int mmu_notifier_clear_young(struct mm_struct *mm,
632116f6 Vladimir Davydov     2015-08-06  248  					   unsigned long start,
632116f6 Vladimir Davydov     2015-08-06  249  					   unsigned long end)
632116f6 Vladimir Davydov     2015-08-06  250  {
632116f6 Vladimir Davydov     2015-08-06  251  	if (mm_has_notifiers(mm))
632116f6 Vladimir Davydov     2015-08-06  252  		return __mmu_notifier_clear_young(mm, start, end);
632116f6 Vladimir Davydov     2015-08-06  253  	return 0;
632116f6 Vladimir Davydov     2015-08-06  254  }
632116f6 Vladimir Davydov     2015-08-06  255  

:::::: The code at line 247 was first introduced by commit
:::::: 632116f6446375758508e1feb402a16265410ed2 mmu-notifier: add clear_young callback

:::::: TO: Vladimir Davydov <vdavydov@parallels.com>
:::::: CC: Stephen Rothwell <sfr@canb.auug.org.au>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
