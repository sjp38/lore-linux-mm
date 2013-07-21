Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 70FB06B0031
	for <linux-mm@kvack.org>; Sat, 20 Jul 2013 23:55:07 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id kq13so305908pab.11
        for <linux-mm@kvack.org>; Sat, 20 Jul 2013 20:55:06 -0700 (PDT)
From: SeungHun Lee <waydi1@gmail.com>
Subject: [PATCH] mm: fix coding style
Date: Sun, 21 Jul 2013 12:54:44 +0900
Message-Id: <1374378884-19886-1-git-send-email-waydi1@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Seunghun Lee <waydi1@gmail.com>

From: Seunghun Lee <waydi1@gmail.com>

Fix coding style of page_alloc.c

Signed-off-by: SeungHun Lee <waydi1@gmail.com>
---
 mm/page_alloc.c |   32 +++++++++++++++++---------------
 1 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b100255..049724c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -721,7 +721,7 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
 		return false;
 
 	if (!PageHighMem(page)) {
-		debug_check_no_locks_freed(page_address(page),PAGE_SIZE<<order);
+		debug_check_no_locks_freed(page_address(page), PAGE_SIZE<<order);
 		debug_check_no_obj_freed(page_address(page),
 					   PAGE_SIZE << order);
 	}
@@ -885,7 +885,7 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 						int migratetype)
 {
 	unsigned int current_order;
-	struct free_area * area;
+	struct free_area *area;
 	struct page *page;
 
 	/* Find a page of the appropriate size in the preferred list */
@@ -1011,7 +1011,7 @@ static void change_pageblock_range(struct page *pageblock_page,
 static inline struct page *
 __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
 {
-	struct free_area * area;
+	struct free_area *area;
 	int current_order;
 	struct page *page;
 	int migratetype, i;
@@ -3104,7 +3104,7 @@ void show_free_areas(unsigned int filter)
 	}
 
 	for_each_populated_zone(zone) {
- 		unsigned long nr[MAX_ORDER], flags, order, total = 0;
+		unsigned long nr[MAX_ORDER], flags, order, total = 0;
 		unsigned char types[MAX_ORDER];
 
 		if (skip_free_areas_node(filter, zone_to_nid(zone)))
@@ -3416,11 +3416,11 @@ static void build_zonelists_in_zone_order(pg_data_t *pgdat, int nr_nodes)
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
@@ -3452,9 +3452,9 @@ static int default_zonelist_order(void)
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
@@ -4180,7 +4180,7 @@ int zone_wait_table_init(struct zone *zone, unsigned long zone_size_pages)
 	if (!zone->wait_table)
 		return -ENOMEM;
 
-	for(i = 0; i < zone->wait_table_hash_nr_entries; ++i)
+	for (i = 0; i < zone->wait_table_hash_nr_entries; ++i)
 		init_waitqueue_head(zone->wait_table + i);
 
 	return 0;
@@ -4930,7 +4930,7 @@ static unsigned long __init early_calculate_totalpages(void)
 		if (pages)
 			node_set_state(nid, N_MEMORY);
 	}
-  	return totalpages;
+	return totalpages;
 }
 
 /*
@@ -5286,8 +5286,10 @@ void __init mem_init_print_info(const char *str)
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
@@ -5614,11 +5616,11 @@ int __meminit init_per_zone_wmark_min(void)
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
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
