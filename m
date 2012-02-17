Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 7B6BC6B0103
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 14:33:39 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt1 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LZJ002VZYC10Q80@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 17 Feb 2012 19:33:37 +0000 (GMT)
Received: from ubuntu ([106.10.22.16])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LZJ00D9EY7NMA@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 17 Feb 2012 19:33:37 +0000 (GMT)
Date: Fri, 17 Feb 2012 20:30:21 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCHv22 01/16] mm: page_alloc: remove trailing whitespace
In-reply-to: <1329507036-24362-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1329507036-24362-2-git-send-email-m.szyprowski@samsung.com>
References: <1329507036-24362-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, Rob Clark <rob.clark@linaro.org>, Ohad Ben-Cohen <ohad@wizery.com>

From: Michal Nazarewicz <mina86@mina86.com>

Signed-off-by: Michal Nazarewicz <mina86@mina86.com>
Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/page_alloc.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d2186ec..7fe7697 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -513,10 +513,10 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
  * free pages of length of (1 << order) and marked with _mapcount -2. Page's
  * order is recorded in page_private(page) field.
  * So when we are allocating or freeing one, we can derive the state of the
- * other.  That is, if we allocate a small block, and both were   
- * free, the remainder of the region must be split into blocks.   
+ * other.  That is, if we allocate a small block, and both were
+ * free, the remainder of the region must be split into blocks.
  * If a block is freed, and its buddy is also free, then this
- * triggers coalescing into a block of larger size.            
+ * triggers coalescing into a block of larger size.
  *
  * -- wli
  */
@@ -1061,17 +1061,17 @@ retry_reserve:
 	return page;
 }
 
-/* 
+/*
  * Obtain a specified number of elements from the buddy allocator, all under
  * a single hold of the lock, for efficiency.  Add them to the supplied list.
  * Returns the number of new pages which were placed at *list.
  */
-static int rmqueue_bulk(struct zone *zone, unsigned int order, 
+static int rmqueue_bulk(struct zone *zone, unsigned int order,
 			unsigned long count, struct list_head *list,
 			int migratetype, int cold)
 {
 	int i;
-	
+
 	spin_lock(&zone->lock);
 	for (i = 0; i < count; ++i) {
 		struct page *page = __rmqueue(zone, order, migratetype);
@@ -4258,7 +4258,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 	init_waitqueue_head(&pgdat->kswapd_wait);
 	pgdat->kswapd_max_order = 0;
 	pgdat_page_cgroup_init(pgdat);
-	
+
 	for (j = 0; j < MAX_NR_ZONES; j++) {
 		struct zone *zone = pgdat->node_zones + j;
 		unsigned long size, realsize, memmap_pages;
@@ -5081,11 +5081,11 @@ int __meminit init_per_zone_wmark_min(void)
 module_init(init_per_zone_wmark_min)
 
 /*
- * min_free_kbytes_sysctl_handler - just a wrapper around proc_dointvec() so 
+ * min_free_kbytes_sysctl_handler - just a wrapper around proc_dointvec() so
  *	that we can call two helper functions whenever min_free_kbytes
  *	changes.
  */
-int min_free_kbytes_sysctl_handler(ctl_table *table, int write, 
+int min_free_kbytes_sysctl_handler(ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
 {
 	proc_dointvec(table, write, buffer, length, ppos);
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
