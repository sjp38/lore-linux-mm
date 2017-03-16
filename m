Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 37DCF6B03A2
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 22:01:04 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id u69so35963317ita.1
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 19:01:04 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0233.hostedemail.com. [216.40.44.233])
        by mx.google.com with ESMTPS id g75si2038715itg.23.2017.03.15.19.01.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 19:01:03 -0700 (PDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 04/15] mm: page_alloc: fix blank lines
Date: Wed, 15 Mar 2017 19:00:01 -0700
Message-Id: <fdb2af274aff5527723da23be6e319126be387b5.1489628477.git.joe@perches.com>
In-Reply-To: <cover.1489628477.git.joe@perches.com>
References: <cover.1489628477.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

Add and remove a few blank lines.

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/page_alloc.c | 36 +++++++++++++++++++++++++++---------
 1 file changed, 27 insertions(+), 9 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1029a1dd59d9..ec9832d15d07 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -496,6 +496,7 @@ static int page_is_consistent(struct zone *zone, struct page *page)
 
 	return 1;
 }
+
 /*
  * Temporary debugging check for pages not lying within a given zone.
  */
@@ -589,6 +590,7 @@ void prep_compound_page(struct page *page, unsigned int order)
 	__SetPageHead(page);
 	for (i = 1; i < nr_pages; i++) {
 		struct page *p = page + i;
+
 		set_page_count(p, 0);
 		p->mapping = TAIL_MAPPING;
 		set_compound_head(p, page);
@@ -609,6 +611,7 @@ static int __init early_debug_pagealloc(char *buf)
 		return -EINVAL;
 	return kstrtobool(buf, &_debug_pagealloc_enabled);
 }
+
 early_param("debug_pagealloc", early_debug_pagealloc);
 
 static bool need_debug_guardpage(void)
@@ -651,6 +654,7 @@ static int __init debug_guardpage_minorder_setup(char *buf)
 	pr_info("Setting debug_guardpage_minorder to %lu\n", res);
 	return 0;
 }
+
 early_param("debug_guardpage_minorder", debug_guardpage_minorder_setup);
 
 static inline bool set_page_guard(struct zone *zone, struct page *page,
@@ -869,6 +873,7 @@ static inline void __free_one_page(struct page *page,
 	 */
 	if ((order < MAX_ORDER - 2) && pfn_valid_within(buddy_pfn)) {
 		struct page *higher_page, *higher_buddy;
+
 		combined_pfn = buddy_pfn & pfn;
 		higher_page = page + (combined_pfn - pfn);
 		buddy_pfn = __find_buddy_pfn(combined_pfn, order + 1);
@@ -1307,6 +1312,7 @@ static inline bool __meminit early_pfn_in_nid(unsigned long pfn, int node)
 {
 	return true;
 }
+
 static inline bool __meminit meminit_pfn_in_nid(unsigned long pfn, int node,
 						struct mminit_pfnnid_cache *state)
 {
@@ -1314,7 +1320,6 @@ static inline bool __meminit meminit_pfn_in_nid(unsigned long pfn, int node,
 }
 #endif
 
-
 void __init __free_pages_bootmem(struct page *page, unsigned long pfn,
 				 unsigned int order)
 {
@@ -1708,6 +1713,7 @@ static bool check_pcp_refill(struct page *page)
 {
 	return check_new_page(page);
 }
+
 static bool check_new_pcp(struct page *page)
 {
 	return false;
@@ -1717,6 +1723,7 @@ static bool check_new_pcp(struct page *page)
 static bool check_new_pages(struct page *page, unsigned int order)
 {
 	int i;
+
 	for (i = 0; i < (1 << order); i++) {
 		struct page *p = page + i;
 
@@ -1748,6 +1755,7 @@ static void prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags
 
 	for (i = 0; i < (1 << order); i++) {
 		struct page *p = page + i;
+
 		if (poisoned)
 			poisoned &= page_is_poisoned(p);
 	}
@@ -1803,7 +1811,6 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 	return NULL;
 }
 
-
 /*
  * This array describes the order lists are fallen back to when
  * the free lists for the desirable migrate type are depleted
@@ -2266,6 +2273,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 	spin_lock_irqsave(&zone->lock, flags);
 	for (i = 0; i < count; ++i) {
 		struct page *page = __rmqueue(zone, order, migratetype);
+
 		if (unlikely(page == NULL))
 			break;
 
@@ -2470,6 +2478,7 @@ void drain_all_pages(struct zone *zone)
 
 	for_each_cpu(cpu, &cpus_with_pcps) {
 		struct work_struct *work = per_cpu_ptr(&pcpu_drain, cpu);
+
 		INIT_WORK(work, drain_local_pages_wq);
 		queue_work_on(cpu, mm_percpu_wq, work);
 	}
@@ -2566,6 +2575,7 @@ void free_hot_cold_page(struct page *page, bool cold)
 	pcp->count++;
 	if (pcp->count >= pcp->high) {
 		unsigned long batch = READ_ONCE(pcp->batch);
+
 		free_pcppages_bulk(zone, batch, pcp);
 		pcp->count -= batch;
 	}
@@ -2653,8 +2663,10 @@ int __isolate_free_page(struct page *page, unsigned int order)
 	 */
 	if (order >= pageblock_order - 1) {
 		struct page *endpage = page + (1 << order) - 1;
+
 		for (; page < endpage; page += pageblock_nr_pages) {
 			int mt = get_pageblock_migratetype(page);
+
 			if (!is_migrate_isolate(mt) && !is_migrate_cma(mt)
 			    && !is_migrate_highatomic(mt))
 				set_pageblock_migratetype(page,
@@ -2662,7 +2674,6 @@ int __isolate_free_page(struct page *page, unsigned int order)
 		}
 	}
 
-
 	return 1UL << order;
 }
 
@@ -4260,6 +4271,7 @@ void * __meminit alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask)
 {
 	unsigned int order = get_order(size);
 	struct page *p = alloc_pages_node(nid, gfp_mask, order);
+
 	if (!p)
 		return NULL;
 	return make_alloc_exact((unsigned long)page_address(p), order, size);
@@ -4306,6 +4318,7 @@ static unsigned long nr_free_zone_pages(int offset)
 	for_each_zone_zonelist(zone, z, zonelist, offset) {
 		unsigned long size = zone->managed_pages;
 		unsigned long high = high_wmark_pages(zone);
+
 		if (size > high)
 			sum += size - high;
 	}
@@ -4721,7 +4734,6 @@ static int build_zonelists_node(pg_data_t *pgdat, struct zonelist *zonelist,
 	return nr_zones;
 }
 
-
 /*
  *  zonelist_order:
  *  0 = automatic detection of better ordering.
@@ -4741,7 +4753,6 @@ static int build_zonelists_node(pg_data_t *pgdat, struct zonelist *zonelist,
 static int current_zonelist_order = ZONELIST_ORDER_DEFAULT;
 static char zonelist_order_name[3][8] = {"Default", "Node", "Zone"};
 
-
 #ifdef CONFIG_NUMA
 /* The value user specified ....changed by config */
 static int user_zonelist_order = ZONELIST_ORDER_DEFAULT;
@@ -4785,6 +4796,7 @@ static __init int setup_numa_zonelist_order(char *s)
 
 	return ret;
 }
+
 early_param("numa_zonelist_order", setup_numa_zonelist_order);
 
 /*
@@ -4831,7 +4843,6 @@ int numa_zonelist_order_handler(struct ctl_table *table, int write,
 	return ret;
 }
 
-
 #define MAX_NODE_LOAD (nr_online_nodes)
 static int node_load[MAX_NUMNODES];
 
@@ -4894,7 +4905,6 @@ static int find_next_best_node(int node, nodemask_t *used_node_mask)
 	return best_node;
 }
 
-
 /*
  * Build zonelists ordered by node and zones within node.
  * This results in maximum locality--normal zone overflows into local
@@ -5340,6 +5350,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 static void __meminit zone_init_free_lists(struct zone *zone)
 {
 	unsigned int order, t;
+
 	for_each_migratetype_order(order, t) {
 		INIT_LIST_HEAD(&zone->free_area[order].free_list[t]);
 		zone->free_area[order].nr_free = 0;
@@ -5461,6 +5472,7 @@ static void pageset_set_high(struct per_cpu_pageset *p,
 			     unsigned long high)
 {
 	unsigned long batch = max(1UL, high / 4);
+
 	if ((high / 4) > (PAGE_SHIFT * 8))
 		batch = PAGE_SHIFT * 8;
 
@@ -5489,6 +5501,7 @@ static void __meminit zone_pageset_init(struct zone *zone, int cpu)
 static void __meminit setup_zone_pageset(struct zone *zone)
 {
 	int cpu;
+
 	zone->pageset = alloc_percpu(struct per_cpu_pageset);
 	for_each_possible_cpu(cpu)
 		zone_pageset_init(zone, cpu);
@@ -5651,6 +5664,7 @@ void __meminit get_pfn_range_for_nid(unsigned int nid,
 static void __init find_usable_zone_for_movable(void)
 {
 	int zone_index;
+
 	for (zone_index = MAX_NR_ZONES - 1; zone_index >= 0; zone_index--) {
 		if (zone_index == ZONE_MOVABLE)
 			continue;
@@ -5927,6 +5941,7 @@ static void __init setup_usemap(struct pglist_data *pgdat,
 				unsigned long zonesize)
 {
 	unsigned long usemapsize = usemap_size(zone_start_pfn, zonesize);
+
 	zone->pageblock_flags = NULL;
 	if (usemapsize)
 		zone->pageblock_flags =
@@ -6425,6 +6440,7 @@ static void __init find_zone_movable_pfns_for_nodes(void)
 			/* Account for what is only usable for kernelcore */
 			if (start_pfn < usable_startpfn) {
 				unsigned long kernel_pages;
+
 				kernel_pages = min(end_pfn, usable_startpfn)
 					- start_pfn;
 
@@ -6501,6 +6517,7 @@ static void check_for_memory(pg_data_t *pgdat, int nid)
 
 	for (zone_type = 0; zone_type <= ZONE_MOVABLE - 1; zone_type++) {
 		struct zone *zone = &pgdat->node_zones[zone_type];
+
 		if (populated_zone(zone)) {
 			node_set_state(nid, N_HIGH_MEMORY);
 			if (N_NORMAL_MEMORY != N_HIGH_MEMORY &&
@@ -6589,6 +6606,7 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
 	setup_nr_node_ids();
 	for_each_online_node(nid) {
 		pg_data_t *pgdat = NODE_DATA(nid);
+
 		free_area_init_node(nid, NULL,
 				    find_min_pfn_for_node(nid), NULL);
 
@@ -6602,6 +6620,7 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
 static int __init cmdline_parse_core(char *p, unsigned long *core)
 {
 	unsigned long long coremem;
+
 	if (!p)
 		return -EINVAL;
 
@@ -6687,7 +6706,6 @@ void free_highmem_page(struct page *page)
 }
 #endif
 
-
 void __init mem_init_print_info(const char *str)
 {
 	unsigned long physpages, codesize, datasize, rosize, bss_size;
@@ -7052,7 +7070,6 @@ static void setup_min_unmapped_ratio(void)
 							 sysctl_min_unmapped_ratio) / 100;
 }
 
-
 int sysctl_min_unmapped_ratio_sysctl_handler(struct ctl_table *table, int write,
 					     void __user *buffer, size_t *length, loff_t *ppos)
 {
@@ -7637,6 +7654,7 @@ void free_contig_range(unsigned long pfn, unsigned nr_pages)
 void __meminit zone_pcp_update(struct zone *zone)
 {
 	unsigned cpu;
+
 	mutex_lock(&pcp_batch_high_lock);
 	for_each_possible_cpu(cpu)
 		pageset_set_high_and_batch(zone,
-- 
2.10.0.rc2.1.g053435c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
