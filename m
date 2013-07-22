Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 18BAB6B0032
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 07:32:53 -0400 (EDT)
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MQC004T65ELBEU0@mailout1.samsung.com> for linux-mm@kvack.org;
 Mon, 22 Jul 2013 20:32:46 +0900 (KST)
From: Pintu Kumar <pintu.k@samsung.com>
Subject: [PATCH 1/2] mm: page_alloc: fixed checkpatch errors and spell
Date: Mon, 22 Jul 2013 17:01:19 +0530
Message-id: <1374492679-17700-1-git-send-email-pintu.k@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, jiang.liu@huawei.com, minchan@kernel.org, cody@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: cpgs@samsung.com, pintu.k@samsung.com, pintu_agarwal@yahoo.com

This patch set fixes all errors reported by checkpatch.
It also fixes the very small spell mistakes.

Signed-off-by: Pintu Kumar <pintu.k@samsung.com>
---
 mm/page_alloc.c |   45 ++++++++++++++++++++++++---------------------
 1 file changed, 24 insertions(+), 21 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b100255..202ab58 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -721,7 +721,8 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
 		return false;
 
 	if (!PageHighMem(page)) {
-		debug_check_no_locks_freed(page_address(page),PAGE_SIZE<<order);
+		debug_check_no_locks_freed(page_address(page),
+					   PAGE_SIZE << order);
 		debug_check_no_obj_freed(page_address(page),
 					   PAGE_SIZE << order);
 	}
@@ -885,7 +886,7 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 						int migratetype)
 {
 	unsigned int current_order;
-	struct free_area * area;
+	struct free_area *area;
 	struct page *page;
 
 	/* Find a page of the appropriate size in the preferred list */
@@ -1011,7 +1012,7 @@ static void change_pageblock_range(struct page *pageblock_page,
 static inline struct page *
 __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
 {
-	struct free_area * area;
+	struct free_area *area;
 	int current_order;
 	struct page *page;
 	int migratetype, i;
@@ -3104,7 +3105,7 @@ void show_free_areas(unsigned int filter)
 	}
 
 	for_each_populated_zone(zone) {
- 		unsigned long nr[MAX_ORDER], flags, order, total = 0;
+		unsigned long nr[MAX_ORDER], flags, order, total = 0;
 		unsigned char types[MAX_ORDER];
 
 		if (skip_free_areas_node(filter, zone_to_nid(zone)))
@@ -3416,11 +3417,11 @@ static void build_zonelists_in_zone_order(pg_data_t *pgdat, int nr_nodes)
 static int default_zonelist_order(void)
 {
 	int nid, zone_type;
-	unsigned long low_kmem_size,total_size;
+	unsigned long low_kmem_size, total_size;
 	struct zone *z;
 	int average_size;
 	/*
-         * ZONE_DMA and ZONE_DMA32 can be very small area in the system.
+	 * ZONE_DMA and ZONE_DMA32 can be very small area in the system.
 	 * If they are really small and used heavily, the system can fall
 	 * into OOM very easily.
 	 * This function detect ZONE_DMA/DMA32 size and configures zone order.
@@ -3452,9 +3453,9 @@ static int default_zonelist_order(void)
 		return ZONELIST_ORDER_NODE;
 	/*
 	 * look into each node's config.
-  	 * If there is a node whose DMA/DMA32 memory is very big area on
- 	 * local memory, NODE_ORDER may be suitable.
-         */
+	 * If there is a node whose DMA/DMA32 memory is very big area on
+	 * local memory, NODE_ORDER may be suitable.
+	 */
 	average_size = total_size /
 				(nodes_weight(node_states[N_MEMORY]) + 1);
 	for_each_online_node(nid) {
@@ -4180,7 +4181,7 @@ int zone_wait_table_init(struct zone *zone, unsigned long zone_size_pages)
 	if (!zone->wait_table)
 		return -ENOMEM;
 
-	for(i = 0; i < zone->wait_table_hash_nr_entries; ++i)
+	for (i = 0; i < zone->wait_table_hash_nr_entries; ++i)
 		init_waitqueue_head(zone->wait_table + i);
 
 	return 0;
@@ -4930,7 +4931,7 @@ static unsigned long __init early_calculate_totalpages(void)
 		if (pages)
 			node_set_state(nid, N_MEMORY);
 	}
-  	return totalpages;
+	return totalpages;
 }
 
 /*
@@ -5047,7 +5048,7 @@ restart:
 			/*
 			 * Some kernelcore has been met, update counts and
 			 * break if the kernelcore for this node has been
-			 * satisified
+			 * satisfied
 			 */
 			required_kernelcore -= min(required_kernelcore,
 								size_pages);
@@ -5061,7 +5062,7 @@ restart:
 	 * If there is still required_kernelcore, we do another pass with one
 	 * less node in the count. This will push zone_movable_pfn[nid] further
 	 * along on the nodes that still have memory until kernelcore is
-	 * satisified
+	 * satisfied
 	 */
 	usable_nodes--;
 	if (usable_nodes && required_kernelcore > usable_nodes)
@@ -5286,8 +5287,10 @@ void __init mem_init_print_info(const char *str)
 	 * 3) .rodata.* may be embedded into .text or .data sections.
 	 */
 #define adj_init_size(start, end, size, pos, adj) \
-	if (start <= pos && pos < end && size > adj) \
-		size -= adj;
+	do { \
+		if (start <= pos && pos < end && size > adj) \
+			size -= adj; \
+	} while (0)
 
 	adj_init_size(__init_begin, __init_end, init_data_size,
 		     _sinittext, init_code_size);
@@ -5570,7 +5573,7 @@ static void __meminit setup_per_zone_inactive_ratio(void)
  * we want it large (64MB max).  But it is not linear, because network
  * bandwidth does not increase linearly with machine size.  We use
  *
- * 	min_free_kbytes = 4 * sqrt(lowmem_kbytes), for better accuracy:
+ *	min_free_kbytes = 4 * sqrt(lowmem_kbytes), for better accuracy:
  *	min_free_kbytes = sqrt(lowmem_kbytes * 16)
  *
  * which yields
@@ -5614,11 +5617,11 @@ int __meminit init_per_zone_wmark_min(void)
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
@@ -5682,8 +5685,8 @@ int lowmem_reserve_ratio_sysctl_handler(ctl_table *table, int write,
 
 /*
  * percpu_pagelist_fraction - changes the pcp->high for each zone on each
- * cpu.  It is the fraction of total pages in each zone that a hot per cpu pagelist
- * can have before it gets flushed back to buddy allocator.
+ * cpu.  It is the fraction of total pages in each zone that a hot per cpu
+ * pagelist can have before it gets flushed back to buddy allocator.
  */
 int percpu_pagelist_fraction_sysctl_handler(ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
@@ -5900,7 +5903,7 @@ void set_pageblock_flags_group(struct page *page, unsigned long flags,
  * This function checks whether pageblock includes unmovable pages or not.
  * If @count is not zero, it is okay to include less @count unmovable pages
  *
- * PageLRU check wihtout isolation or lru_lock could race so that
+ * PageLRU check without isolation or lru_lock could race so that
  * MIGRATE_MOVABLE block might include unmovable pages. It means you can't
  * expect this function should be exact.
  */
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
