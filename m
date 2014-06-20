Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id EB1A46B0035
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 22:10:29 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id ft15so2421466pdb.35
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 19:10:29 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id il2si7795321pbc.87.2014.06.19.19.10.28
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 19:10:28 -0700 (PDT)
Date: Fri, 20 Jun 2014 10:09:27 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 130/230] mm/swap.c:719:2: error: implicit
 declaration of function 'TestSetPageMlocked'
Message-ID: <53a397d7.WKpm75H8yvJSkNsS%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   df25ba7db0775d87018e2cd92f26b9b087093840
commit: 8d72d7b20fab14a779df2f7ea7632d4ee223dfcc [130/230] mm: memcontrol: rewrite charge API
config: make ARCH=m32r m32104ut_defconfig

All error/warnings:

   mm/swap.c: In function 'lru_cache_add_active_or_unevictable':
>> mm/swap.c:719:2: error: implicit declaration of function 'TestSetPageMlocked' [-Werror=implicit-function-declaration]
   cc1: some warnings being treated as errors

vim +/TestSetPageMlocked +719 mm/swap.c

   713		if (likely((vma->vm_flags & (VM_LOCKED | VM_SPECIAL)) != VM_LOCKED)) {
   714			SetPageActive(page);
   715			lru_cache_add(page);
   716			return;
   717		}
   718	
 > 719		if (!TestSetPageMlocked(page)) {
   720			/*
   721			 * We use the irq-unsafe __mod_zone_page_stat because this
   722			 * counter is not modified from interrupt context, and the pte

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
