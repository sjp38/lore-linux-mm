Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id ED4F36B0036
	for <linux-mm@kvack.org>; Tue, 26 Aug 2014 09:18:32 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id rd3so23486008pab.14
        for <linux-mm@kvack.org>; Tue, 26 Aug 2014 06:18:32 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id oe1si4084295pbc.212.2014.08.26.06.18.31
        for <linux-mm@kvack.org>;
        Tue, 26 Aug 2014 06:18:32 -0700 (PDT)
Date: Tue, 26 Aug 2014 21:18:15 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [next:master 2145/2346] drivers/base/dma-mapping.c:294:2: error:
 implicit declaration of function 'dma_common_pages_remap'
Message-ID: <53fc8917.8odw5fgQ/XJIRB7e%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   1c9e4561f3b2afffcda007eae9d0ddd25525f50e
commit: fa44abcad042144651fa9cd0f698c7c40a59d60f [2145/2346] common: dma-mapping: introduce common remapping functions
config: make ARCH=mn10300 asb2364_defconfig

All error/warnings:

   drivers/base/dma-mapping.c: In function 'dma_common_contiguous_remap':
>> drivers/base/dma-mapping.c:294:2: error: implicit declaration of function 'dma_common_pages_remap' [-Werror=implicit-function-declaration]
     ptr = dma_common_pages_remap(pages, size, vm_flags, prot, caller);
     ^
>> drivers/base/dma-mapping.c:294:6: warning: assignment makes pointer from integer without a cast
     ptr = dma_common_pages_remap(pages, size, vm_flags, prot, caller);
         ^
   drivers/base/dma-mapping.c: At top level:
>> drivers/base/dma-mapping.c:305:7: error: conflicting types for 'dma_common_pages_remap'
    void *dma_common_pages_remap(struct page **pages, size_t size,
          ^
   drivers/base/dma-mapping.c:294:8: note: previous implicit declaration of 'dma_common_pages_remap' was here
     ptr = dma_common_pages_remap(pages, size, vm_flags, prot, caller);
           ^
   cc1: some warnings being treated as errors

vim +/dma_common_pages_remap +294 drivers/base/dma-mapping.c

   288		if (!pages)
   289			return NULL;
   290	
   291		for (i = 0, pfn = page_to_pfn(page); i < (size >> PAGE_SHIFT); i++)
   292			pages[i] = pfn_to_page(pfn + i);
   293	
 > 294		ptr = dma_common_pages_remap(pages, size, vm_flags, prot, caller);
   295	
   296		kfree(pages);
   297	
   298		return ptr;
   299	}
   300	
   301	/*
   302	 * remaps an array of PAGE_SIZE pages into another vm_area
   303	 * Cannot be used in non-sleeping contexts
   304	 */
 > 305	void *dma_common_pages_remap(struct page **pages, size_t size,
   306				unsigned long vm_flags, pgprot_t prot,
   307				const void *caller)
   308	{

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
