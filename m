Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 6587F6B0038
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 00:20:16 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so4370484igb.0
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 21:20:16 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id u16si823937ioi.37.2015.09.16.21.20.15
        for <linux-mm@kvack.org>;
        Wed, 16 Sep 2015 21:20:15 -0700 (PDT)
Date: Thu, 17 Sep 2015 12:18:52 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 69/200] include/trace/events/huge_memory.h:46:1:
 sparse: odd constant _Bool cast (ffffffffffffffff becomes 1)
Message-ID: <201509171249.4lzXaybj%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   cf181493809bf6f55f40f0380d4e2f10e2588544
commit: 7d302a9cb0d503a0fd8396bd423e3e57c54c6751 [69/200] mm: add tracepoint for scanning pages
reproduce:
  # apt-get install sparse
  git checkout 7d302a9cb0d503a0fd8396bd423e3e57c54c6751
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> include/trace/events/huge_memory.h:46:1: sparse: odd constant _Bool cast (ffffffffffffffff becomes 1)
>> include/trace/events/huge_memory.h:46:1: sparse: odd constant _Bool cast (ffffffffffffffff becomes 1)
   include/trace/events/huge_memory.h:104:1: sparse: odd constant _Bool cast (ffffffffffffffff becomes 1)
   include/trace/events/huge_memory.h:104:1: sparse: odd constant _Bool cast (ffffffffffffffff becomes 1)
   mm/huge_memory.c:1501:28: sparse: context imbalance in 'zap_huge_pmd' - unexpected unlock
   mm/huge_memory.c:1569:28: sparse: context imbalance in 'move_huge_pmd' - unexpected unlock
   mm/huge_memory.c:1599:36: sparse: context imbalance in 'change_huge_pmd' - unexpected unlock
   mm/huge_memory.c:1625:5: sparse: context imbalance in '__pmd_trans_huge_lock' - different lock contexts for basic block
   mm/huge_memory.c:1652:7: sparse: context imbalance in 'page_check_address_pmd' - different lock contexts for basic block
   mm/huge_memory.c:1721:17: sparse: context imbalance in '__split_huge_page_splitting' - unexpected unlock
   arch/x86/include/asm/paravirt.h:515:17: sparse: context imbalance in '__split_huge_page_map' - unexpected unlock

vim +46 include/trace/events/huge_memory.h

    30		EM( SCAN_DEL_PAGE_LRU,		"could_not_delete_page_from_lru")\
    31		EM( SCAN_ALLOC_HUGE_PAGE_FAIL,	"alloc_huge_page_failed")	\
    32		EMe( SCAN_CGROUP_CHARGE_FAIL,	"ccgroup_charge_failed")
    33	
    34	#undef EM
    35	#undef EMe
    36	#define EM(a, b)	TRACE_DEFINE_ENUM(a);
    37	#define EMe(a, b)	TRACE_DEFINE_ENUM(a);
    38	
    39	SCAN_STATUS
    40	
    41	#undef EM
    42	#undef EMe
    43	#define EM(a, b)	{a, b},
    44	#define EMe(a, b)	{a, b}
    45	
  > 46	TRACE_EVENT(mm_khugepaged_scan_pmd,
    47	
    48		TP_PROTO(struct mm_struct *mm, unsigned long pfn, bool writable,
    49			 bool referenced, int none_or_zero, int status),
    50	
    51		TP_ARGS(mm, pfn, writable, referenced, none_or_zero, status),
    52	
    53		TP_STRUCT__entry(
    54			__field(struct mm_struct *, mm)

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
