Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 06DA36B0032
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 05:48:00 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id rd3so38167930pab.7
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 02:47:59 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id mj3si15504278pdb.222.2015.01.19.02.47.57
        for <linux-mm@kvack.org>;
        Mon, 19 Jan 2015 02:47:58 -0800 (PST)
Date: Mon, 19 Jan 2015 18:46:42 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [next:master 3506/3880] include/trace/events/compaction.h:167:1:
 sparse: cast to restricted gfp_t
Message-ID: <201501191841.3FzmZrGr%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   a0d4287f787889e59db0fd295853a0f1f55d0699
commit: c1c531ec36aa1901a831d111eb4ec5c16bf68c30 [3506/3880] mm/compaction: more trace to understand when/why compaction start/finish
reproduce:
  # apt-get install sparse
  git checkout c1c531ec36aa1901a831d111eb4ec5c16bf68c30
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> include/trace/events/compaction.h:167:1: sparse: cast to restricted gfp_t
>> include/trace/events/compaction.h:167:1: sparse: cast to restricted gfp_t
>> include/trace/events/compaction.h:167:1: sparse: restricted gfp_t degrades to integer
>> include/trace/events/compaction.h:167:1: sparse: restricted gfp_t degrades to integer
   mm/compaction.c:1393:37: sparse: incorrect type in initializer (different base types)
   mm/compaction.c:1393:37:    expected int [signed] may_enter_fs
   mm/compaction.c:1393:37:    got restricted gfp_t
   mm/compaction.c:1394:39: sparse: incorrect type in initializer (different base types)
   mm/compaction.c:1394:39:    expected int [signed] may_perform_io
   mm/compaction.c:1394:39:    got restricted gfp_t
   include/trace/events/compaction.h:103:1: sparse: odd constant _Bool cast (ffffffffffffffff becomes 1)
   include/trace/events/compaction.h:133:1: sparse: odd constant _Bool cast (ffffffffffffffff becomes 1)
   mm/compaction.c:242:13: sparse: context imbalance in 'compact_trylock_irqsave' - wrong count at exit
   include/linux/spinlock.h:364:9: sparse: context imbalance in 'compact_unlock_should_abort' - unexpected unlock
   mm/compaction.c:449:39: sparse: context imbalance in 'isolate_freepages_block' - unexpected unlock
   mm/compaction.c:747:39: sparse: context imbalance in 'isolate_migratepages_block' - unexpected unlock

vim +167 include/trace/events/compaction.h

   151			__entry->migrate_pfn = migrate_pfn;
   152			__entry->free_pfn = free_pfn;
   153			__entry->zone_end = zone_end;
   154			__entry->sync = sync;
   155			__entry->status = status;
   156		),
   157	
   158		TP_printk("zone_start=0x%lx migrate_pfn=0x%lx free_pfn=0x%lx zone_end=0x%lx, mode=%s status=%s",
   159			__entry->zone_start,
   160			__entry->migrate_pfn,
   161			__entry->free_pfn,
   162			__entry->zone_end,
   163			__entry->sync ? "sync" : "async",
   164			compaction_status_string[__entry->status])
   165	);
   166	
 > 167	TRACE_EVENT(mm_compaction_try_to_compact_pages,
   168	
   169		TP_PROTO(
   170			int order,
   171			gfp_t gfp_mask,
   172			enum migrate_mode mode),
   173	
   174		TP_ARGS(order, gfp_mask, mode),
   175	

---
0-DAY kernel test infrastructure                Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
