Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id B152C6B0253
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 23:13:04 -0400 (EDT)
Received: by pachj5 with SMTP id hj5so1864605pac.3
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 20:13:04 -0700 (PDT)
Received: from e28smtp05.in.ibm.com (e28smtp05.in.ibm.com. [122.248.162.5])
        by mx.google.com with ESMTPS id d16si16517193pbu.108.2015.07.10.20.13.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Jul 2015 20:13:03 -0700 (PDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <weiyang@linux.vnet.ibm.com>;
	Sat, 11 Jul 2015 08:42:59 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 506C73940048
	for <linux-mm@kvack.org>; Sat, 11 Jul 2015 08:42:57 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t6B3CuKo9830808
	for <linux-mm@kvack.org>; Sat, 11 Jul 2015 08:42:57 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t6B1xCFn032163
	for <linux-mm@kvack.org>; Sat, 11 Jul 2015 07:29:12 +0530
From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: [PATCH] mm/page: remove unused variable of free_area_init_core()
Date: Sat, 11 Jul 2015 11:12:48 +0800
Message-Id: <1436584368-7639-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Wei Yang <weiyang@linux.vnet.ibm.com>, Gu Zheng <guz.fnst@cn.fujitsu.com>

commit <febd5949e134> ("mm/memory hotplug: init the zone's size when
calculating node totalpages") refine the function free_area_init_core().
After doing so, these two parameter is not used anymore.

This patch removes these two parameters.

Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
CC: Gu Zheng <guz.fnst@cn.fujitsu.com>
---
 mm/page_alloc.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 07aeae8..f8d0a98 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5275,8 +5275,7 @@ static unsigned long __paginginit calc_memmap_size(unsigned long spanned_pages,
  *
  * NOTE: pgdat should get zeroed by caller.
  */
-static void __paginginit free_area_init_core(struct pglist_data *pgdat,
-		unsigned long node_start_pfn, unsigned long node_end_pfn)
+static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 {
 	enum zone_type j;
 	int nid = pgdat->node_id;
@@ -5439,7 +5438,7 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 		(unsigned long)pgdat->node_mem_map);
 #endif
 
-	free_area_init_core(pgdat, start_pfn, end_pfn);
+	free_area_init_core(pgdat);
 }
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
