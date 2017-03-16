Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id E90736B0395
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 22:00:29 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id n76so41720599ioe.1
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 19:00:29 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0148.hostedemail.com. [216.40.44.148])
        by mx.google.com with ESMTPS id 35si4693229iom.23.2017.03.15.19.00.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 19:00:28 -0700 (PDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 01/15] mm: page_alloc: whitespace neatening
Date: Wed, 15 Mar 2017 18:59:58 -0700
Message-Id: <cad154f193b480792825e20ba50bf15e40a4a33d.1489628477.git.joe@perches.com>
In-Reply-To: <cover.1489628477.git.joe@perches.com>
References: <cover.1489628477.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

whitespace changes only - git diff -w shows no difference

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/page_alloc.c | 54 +++++++++++++++++++++++++++---------------------------
 1 file changed, 27 insertions(+), 27 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2d3c10734874..504749032400 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -202,7 +202,7 @@ static void __free_pages_ok(struct page *page, unsigned int order);
  * TBD: should special case ZONE_DMA32 machines here - in those we normally
  * don't need any ZONE_NORMAL reservation
  */
-int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1] = {
+int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES - 1] = {
 #ifdef CONFIG_ZONE_DMA
 	 256,
 #endif
@@ -366,7 +366,7 @@ static inline unsigned long *get_pageblock_bitmap(struct page *page,
 static inline int pfn_to_bitidx(struct page *page, unsigned long pfn)
 {
 #ifdef CONFIG_SPARSEMEM
-	pfn &= (PAGES_PER_SECTION-1);
+	pfn &= (PAGES_PER_SECTION - 1);
 	return (pfn >> pageblock_order) * NR_PAGEBLOCK_BITS;
 #else
 	pfn = pfn - round_down(page_zone(page)->zone_start_pfn, pageblock_nr_pages);
@@ -395,7 +395,7 @@ static __always_inline unsigned long __get_pfnblock_flags_mask(struct page *page
 	bitmap = get_pageblock_bitmap(page, pfn);
 	bitidx = pfn_to_bitidx(page, pfn);
 	word_bitidx = bitidx / BITS_PER_LONG;
-	bitidx &= (BITS_PER_LONG-1);
+	bitidx &= (BITS_PER_LONG - 1);
 
 	word = bitmap[word_bitidx];
 	bitidx += end_bitidx;
@@ -436,7 +436,7 @@ void set_pfnblock_flags_mask(struct page *page, unsigned long flags,
 	bitmap = get_pageblock_bitmap(page, pfn);
 	bitidx = pfn_to_bitidx(page, pfn);
 	word_bitidx = bitidx / BITS_PER_LONG;
-	bitidx &= (BITS_PER_LONG-1);
+	bitidx &= (BITS_PER_LONG - 1);
 
 	VM_BUG_ON_PAGE(!zone_spans_pfn(page_zone(page), pfn), page);
 
@@ -867,7 +867,7 @@ static inline void __free_one_page(struct page *page,
 	 * so it's less likely to be used soon and more likely to be merged
 	 * as a higher order page
 	 */
-	if ((order < MAX_ORDER-2) && pfn_valid_within(buddy_pfn)) {
+	if ((order < MAX_ORDER - 2) && pfn_valid_within(buddy_pfn)) {
 		struct page *higher_page, *higher_buddy;
 		combined_pfn = buddy_pfn & pfn;
 		higher_page = page + (combined_pfn - pfn);
@@ -1681,7 +1681,7 @@ static void check_new_page_bad(struct page *page)
 static inline int check_new_page(struct page *page)
 {
 	if (likely(page_expected_state(page,
-				PAGE_FLAGS_CHECK_AT_PREP|__PG_HWPOISON)))
+				PAGE_FLAGS_CHECK_AT_PREP | __PG_HWPOISON)))
 		return 0;
 
 	check_new_page_bad(page);
@@ -1899,7 +1899,7 @@ int move_freepages_block(struct zone *zone, struct page *page,
 	struct page *start_page, *end_page;
 
 	start_pfn = page_to_pfn(page);
-	start_pfn = start_pfn & ~(pageblock_nr_pages-1);
+	start_pfn = start_pfn & ~(pageblock_nr_pages - 1);
 	start_page = pfn_to_page(start_pfn);
 	end_page = start_page + pageblock_nr_pages - 1;
 	end_pfn = start_pfn + pageblock_nr_pages - 1;
@@ -2021,7 +2021,7 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
 	 * If a sufficient number of pages in the block are either free or of
 	 * comparable migratability as our allocation, claim the whole block.
 	 */
-	if (free_pages + alike_pages >= (1 << (pageblock_order-1)) ||
+	if (free_pages + alike_pages >= (1 << (pageblock_order - 1)) ||
 			page_group_by_mobility_disabled)
 		set_pageblock_migratetype(page, start_type);
 
@@ -2205,8 +2205,8 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
 	bool can_steal;
 
 	/* Find the largest possible block of pages in the other list */
-	for (current_order = MAX_ORDER-1;
-				current_order >= order && current_order <= MAX_ORDER-1;
+	for (current_order = MAX_ORDER - 1;
+				current_order >= order && current_order <= MAX_ORDER - 1;
 				--current_order) {
 		area = &(zone->free_area[current_order]);
 		fallback_mt = find_suitable_fallback(area, current_order,
@@ -3188,7 +3188,7 @@ __alloc_pages_cpuset_fallback(gfp_t gfp_mask, unsigned int order,
 	struct page *page;
 
 	page = get_page_from_freelist(gfp_mask, order,
-			alloc_flags|ALLOC_CPUSET, ac);
+			alloc_flags | ALLOC_CPUSET, ac);
 	/*
 	 * fallback to ignore cpuset restriction if our nodes
 	 * are depleted
@@ -3231,7 +3231,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	 * we're still under heavy pressure.
 	 */
 	page = get_page_from_freelist(gfp_mask | __GFP_HARDWALL, order,
-					ALLOC_WMARK_HIGH|ALLOC_CPUSET, ac);
+					ALLOC_WMARK_HIGH | ALLOC_CPUSET, ac);
 	if (page)
 		goto out;
 
@@ -3518,7 +3518,7 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 	unsigned int alloc_flags = ALLOC_WMARK_MIN | ALLOC_CPUSET;
 
 	/* __GFP_HIGH is assumed to be the same as ALLOC_HIGH to save a branch. */
-	BUILD_BUG_ON(__GFP_HIGH != (__force gfp_t) ALLOC_HIGH);
+	BUILD_BUG_ON(__GFP_HIGH != (__force gfp_t)ALLOC_HIGH);
 
 	/*
 	 * The caller may dip into page reserves a bit more if the caller
@@ -3526,7 +3526,7 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 	 * policy or is asking for __GFP_HIGH memory.  GFP_ATOMIC requests will
 	 * set both ALLOC_HARDER (__GFP_ATOMIC) and ALLOC_HIGH (__GFP_HIGH).
 	 */
-	alloc_flags |= (__force int) (gfp_mask & __GFP_HIGH);
+	alloc_flags |= (__force int)(gfp_mask & __GFP_HIGH);
 
 	if (gfp_mask & __GFP_ATOMIC) {
 		/*
@@ -3642,7 +3642,7 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 							NR_ZONE_WRITE_PENDING);
 
 				if (2 * write_pending > reclaimable) {
-					congestion_wait(BLK_RW_ASYNC, HZ/10);
+					congestion_wait(BLK_RW_ASYNC, HZ / 10);
 					return true;
 				}
 			}
@@ -3700,8 +3700,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	 * We also sanity check to catch abuse of atomic reserves being used by
 	 * callers that are not in atomic context.
 	 */
-	if (WARN_ON_ONCE((gfp_mask & (__GFP_ATOMIC|__GFP_DIRECT_RECLAIM)) ==
-				(__GFP_ATOMIC|__GFP_DIRECT_RECLAIM)))
+	if (WARN_ON_ONCE((gfp_mask & (__GFP_ATOMIC | __GFP_DIRECT_RECLAIM)) ==
+				(__GFP_ATOMIC | __GFP_DIRECT_RECLAIM)))
 		gfp_mask &= ~__GFP_ATOMIC;
 
 retry_cpuset:
@@ -3816,7 +3816,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	if (time_after(jiffies, alloc_start + stall_timeout)) {
 		warn_alloc(gfp_mask & ~__GFP_NOWARN, ac->nodemask,
 			"page allocation stalls for %ums, order:%u",
-			jiffies_to_msecs(jiffies-alloc_start), order);
+			jiffies_to_msecs(jiffies - alloc_start), order);
 		stall_timeout += 10 * HZ;
 	}
 
@@ -4063,7 +4063,7 @@ unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order)
 	page = alloc_pages(gfp_mask, order);
 	if (!page)
 		return 0;
-	return (unsigned long) page_address(page);
+	return (unsigned long)page_address(page);
 }
 EXPORT_SYMBOL(__get_free_pages);
 
@@ -4452,7 +4452,7 @@ static bool show_mem_node_skip(unsigned int flags, int nid, nodemask_t *nodemask
 	return !node_isset(nid, *nodemask);
 }
 
-#define K(x) ((x) << (PAGE_SHIFT-10))
+#define K(x) ((x) << (PAGE_SHIFT - 10))
 
 static void show_migration_types(unsigned char type)
 {
@@ -4754,7 +4754,7 @@ char numa_zonelist_order[16] = "default";
  * interface for configure zonelist ordering.
  * command line option "numa_zonelist_order"
  *	= "[dD]efault	- default, automatic configuration.
- *	= "[nN]ode 	- order by node locality, then by zone within node
+ *	= "[nN]ode	- order by node locality, then by zone within node
  *	= "[zZ]one      - order by zone, then by locality within zone
  */
 
@@ -4881,7 +4881,7 @@ static int find_next_best_node(int node, nodemask_t *used_node_mask)
 			val += PENALTY_FOR_NODE_WITH_CPUS;
 
 		/* Slight preference for less loaded node */
-		val *= (MAX_NODE_LOAD*MAX_NUMNODES);
+		val *= (MAX_NODE_LOAD * MAX_NUMNODES);
 		val += node_load[n];
 
 		if (val < min_val) {
@@ -5381,7 +5381,7 @@ static int zone_batchsize(struct zone *zone)
 	 * of pages of one half of the possible page colors
 	 * and the other with pages of the other colors.
 	 */
-	batch = rounddown_pow_of_two(batch + batch/2) - 1;
+	batch = rounddown_pow_of_two(batch + batch / 2) - 1;
 
 	return batch;
 
@@ -5914,7 +5914,7 @@ static unsigned long __init usemap_size(unsigned long zone_start_pfn, unsigned l
 {
 	unsigned long usemapsize;
 
-	zonesize += zone_start_pfn & (pageblock_nr_pages-1);
+	zonesize += zone_start_pfn & (pageblock_nr_pages - 1);
 	usemapsize = roundup(zonesize, pageblock_nr_pages);
 	usemapsize = usemapsize >> pageblock_order;
 	usemapsize *= NR_PAGEBLOCK_BITS;
@@ -7224,7 +7224,7 @@ void *__init alloc_large_system_hash(const char *tablename,
 
 		/* It isn't necessary when PAGE_SIZE >= 1MB */
 		if (PAGE_SHIFT < 20)
-			numentries = round_up(numentries, (1<<20)/PAGE_SIZE);
+			numentries = round_up(numentries, (1 << 20) / PAGE_SIZE);
 
 		if (flags & HASH_ADAPT) {
 			unsigned long adapt;
@@ -7345,7 +7345,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 		 * handle each tail page individually in migration.
 		 */
 		if (PageHuge(page)) {
-			iter = round_up(iter + 1, 1<<compound_order(page)) - 1;
+			iter = round_up(iter + 1, 1 << compound_order(page)) - 1;
 			continue;
 		}
 
@@ -7718,7 +7718,7 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 		rmv_page_order(page);
 		zone->free_area[order].nr_free--;
 		for (i = 0; i < (1 << order); i++)
-			SetPageReserved((page+i));
+			SetPageReserved((page + i));
 		pfn += (1 << order);
 	}
 	spin_unlock_irqrestore(&zone->lock, flags);
-- 
2.10.0.rc2.1.g053435c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
