Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
        by fgwmail6.fujitsu.co.jp (Fujitsu Gateway)
        with ESMTP id k137jftZ013690 for <linux-mm@kvack.org>; Fri, 3 Feb 2006 16:45:41 +0900
        (envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s2.gw.fujitsu.co.jp by m1.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id k137jetL014690 for <linux-mm@kvack.org>; Fri, 3 Feb 2006 16:45:40 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s2.gw.fujitsu.co.jp (s2 [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DBF6F4E00AA
	for <linux-mm@kvack.org>; Fri,  3 Feb 2006 16:45:39 +0900 (JST)
Received: from fjm504.ms.jp.fujitsu.com (fjm504.ms.jp.fujitsu.com [10.56.99.80])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1639C4E00B2
	for <linux-mm@kvack.org>; Fri,  3 Feb 2006 16:45:38 +0900 (JST)
Received: from [127.0.0.1] (fjmscan503.ms.jp.fujitsu.com [10.56.99.143])by fjm504.ms.jp.fujitsu.com with ESMTP id k137jTRF009222
	for <linux-mm@kvack.org>; Fri, 3 Feb 2006 16:45:30 +0900
Message-ID: <43E30A55.3070500@jp.fujitsu.com>
Date: Fri, 03 Feb 2006 16:46:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC] pealing off zone from physical memory layout [5/10] register
 memory map
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

memory_map registlation in zone initialization.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: hogehoge/mm/page_alloc.c
===================================================================
--- hogehoge.orig/mm/page_alloc.c
+++ hogehoge/mm/page_alloc.c
@@ -37,6 +37,7 @@
  #include <linux/nodemask.h>
  #include <linux/vmalloc.h>
  #include <linux/mempolicy.h>
+#include <linux/memorymap.h>

  #include <asm/tlbflush.h>
  #include "internal.h"
@@ -2014,6 +2015,7 @@ static __meminit void init_currently_emp
  	memmap_init(size, pgdat->node_id, zone_idx(zone), zone_start_pfn);

  	zone_init_free_lists(pgdat, zone, zone->spanned_pages);
+	arch_register_memory_zone(zone, zone_start_pfn, size);
  }

  /*
@@ -2029,6 +2031,8 @@ static void __init free_area_init_core(s
  	int nid = pgdat->node_id;
  	unsigned long zone_start_pfn = pgdat->node_start_pfn;

+	if (nid == 0)
+		setup_memory_map();
  	pgdat_resize_init(pgdat);
  	pgdat->nr_zones = 0;
  	init_waitqueue_head(&pgdat->kswapd_wait);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
