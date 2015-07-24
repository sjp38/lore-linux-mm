Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 93AE29003C7
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 04:18:58 -0400 (EDT)
Received: by pdjr16 with SMTP id r16so10319291pdj.3
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 01:18:58 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id fi7si18765297pac.187.2015.07.24.01.18.57
        for <linux-mm@kvack.org>;
        Fri, 24 Jul 2015 01:18:57 -0700 (PDT)
Date: Fri, 24 Jul 2015 16:18:30 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 371/385] arch/x86/mm/mpx.c:71:54: sparse: implicit
 cast to nocast type
Message-ID: <201507241628.EnDEXbaF%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   61f5f835b6f06fbc233481b5d3c0afd71ecf54e8
commit: b9e95c5dd1134d35b6c9aeaa3967ab5b3945ba73 [371/385] mm, mpx: add "vm_flags_t vm_flags" arg to do_mmap_pgoff()
reproduce:
  # apt-get install sparse
  git checkout b9e95c5dd1134d35b6c9aeaa3967ab5b3945ba73
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> arch/x86/mm/mpx.c:71:54: sparse: implicit cast to nocast type
   arch/x86/mm/mpx.c:312:27: sparse: incompatible types in comparison expression (different address spaces)
--
>> include/linux/mm.h:1812:54: sparse: implicit cast to nocast type
--
   mm/mmap.c:1343:47: sparse: implicit cast to nocast type
   mm/mmap.c:1345:45: sparse: implicit cast to nocast type
   mm/mmap.c:1354:45: sparse: implicit cast to nocast type
   mm/mmap.c:1375:47: sparse: implicit cast to nocast type
   mm/mmap.c:1395:37: sparse: implicit cast to nocast type
   mm/mmap.c:1399:37: sparse: implicit cast to nocast type
   mm/mmap.c:1443:33: sparse: implicit cast to nocast type
   mm/mmap.c:1578:29: sparse: implicit cast to nocast type
   mm/internal.h:253:43: sparse: implicit cast to nocast type
   mm/mmap.c:2650:37: sparse: implicit cast to nocast type
   mm/mmap.c:2690:34: sparse: implicit cast to nocast type
   mm/mmap.c:2693:34: sparse: implicit cast to nocast type
>> include/linux/mm.h:1812:54: sparse: implicit cast to nocast type
   mm/internal.h:253:43: sparse: implicit cast to nocast type

vim +71 arch/x86/mm/mpx.c

    55	 * bounds tables (the bounds directory is user-allocated).
    56	 *
    57	 * Later on, we use the vma->vm_ops to uniquely identify these
    58	 * VMAs.
    59	 */
    60	static unsigned long mpx_mmap(unsigned long len)
    61	{
    62		struct mm_struct *mm = current->mm;
    63		unsigned long addr, populate;
    64	
    65		/* Only bounds table can be allocated here */
    66		if (len != mpx_bt_size_bytes(mm))
    67			return -EINVAL;
    68	
    69		down_write(&mm->mmap_sem);
    70		addr = do_mmap(NULL, 0, len, PROT_READ | PROT_WRITE,
  > 71				MAP_ANONYMOUS | MAP_PRIVATE, VM_MPX, 0, &populate);
    72		up_write(&mm->mmap_sem);
    73		if (populate)
    74			mm_populate(addr, populate);
    75	
    76		return addr;
    77	}
    78	
    79	enum reg_type {

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
