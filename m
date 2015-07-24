Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 03B419003C7
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 04:00:48 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so10004541pdr.2
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 01:00:47 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id t4si18693056pdn.152.2015.07.24.01.00.46
        for <linux-mm@kvack.org>;
        Fri, 24 Jul 2015 01:00:46 -0700 (PDT)
Date: Fri, 24 Jul 2015 15:59:25 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 127/385] mm/internal.h:253:43: sparse: implicit cast
 to nocast type
Message-ID: <201507241522.TyziMu2M%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   61f5f835b6f06fbc233481b5d3c0afd71ecf54e8
commit: 3426387b81048271b9c48a2a35c1e474e4fce06f [127/385] mm-mlock-introduce-vm_lockonfault-and-add-mlock-flags-to-enable-it-v4
reproduce:
  # apt-get install sparse
  git checkout 3426387b81048271b9c48a2a35c1e474e4fce06f
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   mm/mmap.c:1345:47: sparse: implicit cast to nocast type
   mm/mmap.c:1347:45: sparse: implicit cast to nocast type
   mm/mmap.c:1356:45: sparse: implicit cast to nocast type
   mm/mmap.c:1377:47: sparse: implicit cast to nocast type
   mm/mmap.c:1397:37: sparse: implicit cast to nocast type
   mm/mmap.c:1401:37: sparse: implicit cast to nocast type
   mm/mmap.c:1445:33: sparse: implicit cast to nocast type
   mm/mmap.c:1580:29: sparse: implicit cast to nocast type
>> mm/internal.h:253:43: sparse: implicit cast to nocast type
   mm/mmap.c:2652:37: sparse: implicit cast to nocast type
   mm/mmap.c:2692:34: sparse: implicit cast to nocast type
   mm/mmap.c:2694:34: sparse: implicit cast to nocast type
   mm/mmap.c:2699:67: sparse: implicit cast to nocast type
>> mm/internal.h:253:43: sparse: implicit cast to nocast type

vim +253 mm/internal.h

   237	{
   238		return (flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE;
   239	}
   240	
   241	/* mm/util.c */
   242	void __vma_link_list(struct mm_struct *mm, struct vm_area_struct *vma,
   243			struct vm_area_struct *prev, struct rb_node *rb_parent);
   244	
   245	#ifdef CONFIG_MMU
   246	extern long populate_vma_page_range(struct vm_area_struct *vma,
   247			unsigned long start, unsigned long end, int *nonblocking);
   248	extern void munlock_vma_pages_range(struct vm_area_struct *vma,
   249				unsigned long start, unsigned long end, vm_flags_t to_drop);
   250	static inline void munlock_vma_pages_all(struct vm_area_struct *vma)
   251	{
   252		munlock_vma_pages_range(vma, vma->vm_start, vma->vm_end,
 > 253					VM_LOCKED | VM_LOCKONFAULT);
   254	}
   255	
   256	/*
   257	 * must be called with vma's mmap_sem held for read or write, and page locked.
   258	 */
   259	extern void mlock_vma_page(struct page *page);
   260	extern unsigned int munlock_vma_page(struct page *page);
   261	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
