Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 917516B03A8
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 22:01:43 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id m27so35252225iti.7
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 19:01:43 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0189.hostedemail.com. [216.40.44.189])
        by mx.google.com with ESMTPS id m10si4692717iom.57.2017.03.15.19.01.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 19:01:42 -0700 (PDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 10/15] mm: page_alloc: 80 column neatening
Date: Wed, 15 Mar 2017 19:00:07 -0700
Message-Id: <82f1665ccf57a7da21dcf878478e01c4765d0e66.1489628477.git.joe@perches.com>
In-Reply-To: <cover.1489628477.git.joe@perches.com>
References: <cover.1489628477.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

Wrap some lines to make it easier to read.

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/page_alloc.c | 259 ++++++++++++++++++++++++++++++++++----------------------
 1 file changed, 157 insertions(+), 102 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3e1d377201b8..286b01b4c3e7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -383,10 +383,11 @@ static inline int pfn_to_bitidx(struct page *page, unsigned long pfn)
  *
  * Return: pageblock_bits flags
  */
-static __always_inline unsigned long __get_pfnblock_flags_mask(struct page *page,
-							       unsigned long pfn,
-							       unsigned long end_bitidx,
-							       unsigned long mask)
+static __always_inline
+unsigned long __get_pfnblock_flags_mask(struct page *page,
+					unsigned long pfn,
+					unsigned long end_bitidx,
+					unsigned long mask)
 {
 	unsigned long *bitmap;
 	unsigned long bitidx, word_bitidx;
@@ -409,9 +410,11 @@ unsigned long get_pfnblock_flags_mask(struct page *page, unsigned long pfn,
 	return __get_pfnblock_flags_mask(page, pfn, end_bitidx, mask);
 }
 
-static __always_inline int get_pfnblock_migratetype(struct page *page, unsigned long pfn)
+static __always_inline
+int get_pfnblock_migratetype(struct page *page, unsigned long pfn)
 {
-	return __get_pfnblock_flags_mask(page, pfn, PB_migrate_end, MIGRATETYPE_MASK);
+	return __get_pfnblock_flags_mask(page, pfn, PB_migrate_end,
+					 MIGRATETYPE_MASK);
 }
 
 /**
@@ -446,7 +449,8 @@ void set_pfnblock_flags_mask(struct page *page, unsigned long flags,
 
 	word = READ_ONCE(bitmap[word_bitidx]);
 	for (;;) {
-		old_word = cmpxchg(&bitmap[word_bitidx], word, (word & ~mask) | flags);
+		old_word = cmpxchg(&bitmap[word_bitidx],
+				   word, (word & ~mask) | flags);
 		if (word == old_word)
 			break;
 		word = old_word;
@@ -533,9 +537,8 @@ static void bad_page(struct page *page, const char *reason,
 			goto out;
 		}
 		if (nr_unshown) {
-			pr_alert(
-				"BUG: Bad page state: %lu messages suppressed\n",
-				nr_unshown);
+			pr_alert("BUG: Bad page state: %lu messages suppressed\n",
+				 nr_unshown);
 			nr_unshown = 0;
 		}
 		nr_shown = 0;
@@ -600,8 +603,8 @@ void prep_compound_page(struct page *page, unsigned int order)
 
 #ifdef CONFIG_DEBUG_PAGEALLOC
 unsigned int _debug_guardpage_minorder;
-bool _debug_pagealloc_enabled __read_mostly
-= IS_ENABLED(CONFIG_DEBUG_PAGEALLOC_ENABLE_DEFAULT);
+bool _debug_pagealloc_enabled __read_mostly =
+	IS_ENABLED(CONFIG_DEBUG_PAGEALLOC_ENABLE_DEFAULT);
 EXPORT_SYMBOL(_debug_pagealloc_enabled);
 bool _debug_guardpage_enabled __read_mostly;
 
@@ -703,9 +706,15 @@ static inline void clear_page_guard(struct zone *zone, struct page *page,
 #else
 struct page_ext_operations debug_guardpage_ops;
 static inline bool set_page_guard(struct zone *zone, struct page *page,
-				  unsigned int order, int migratetype) { return false; }
+				  unsigned int order, int migratetype)
+{
+	return false;
+}
+
 static inline void clear_page_guard(struct zone *zone, struct page *page,
-				    unsigned int order, int migratetype) {}
+				    unsigned int order, int migratetype)
+{
+}
 #endif
 
 static inline void set_page_order(struct page *page, unsigned int order)
@@ -998,8 +1007,8 @@ static int free_tail_pages_check(struct page *head_page, struct page *page)
 	return ret;
 }
 
-static __always_inline bool free_pages_prepare(struct page *page,
-					       unsigned int order, bool check_free)
+static __always_inline
+bool free_pages_prepare(struct page *page, unsigned int order, bool check_free)
 {
 	int bad = 0;
 
@@ -1269,7 +1278,7 @@ static void __init __free_pages_boot_core(struct page *page, unsigned int order)
 }
 
 #if defined(CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID) ||	\
-	defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP)
+    defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP)
 
 static struct mminit_pfnnid_cache early_pfnnid_cache __meminitdata;
 
@@ -1289,8 +1298,9 @@ int __meminit early_pfn_to_nid(unsigned long pfn)
 #endif
 
 #ifdef CONFIG_NODES_SPAN_OTHER_NODES
-static inline bool __meminit meminit_pfn_in_nid(unsigned long pfn, int node,
-						struct mminit_pfnnid_cache *state)
+static inline
+bool __meminit meminit_pfn_in_nid(unsigned long pfn, int node,
+				  struct mminit_pfnnid_cache *state)
 {
 	int nid;
 
@@ -1313,8 +1323,9 @@ static inline bool __meminit early_pfn_in_nid(unsigned long pfn, int node)
 	return true;
 }
 
-static inline bool __meminit meminit_pfn_in_nid(unsigned long pfn, int node,
-						struct mminit_pfnnid_cache *state)
+static inline
+bool __meminit meminit_pfn_in_nid(unsigned long pfn, int node,
+				  struct mminit_pfnnid_cache *state)
 {
 	return true;
 }
@@ -1564,7 +1575,8 @@ void __init page_alloc_init_late(void)
 	/* There will be num_node_state(N_MEMORY) threads */
 	atomic_set(&pgdat_init_n_undone, num_node_state(N_MEMORY));
 	for_each_node_state(nid, N_MEMORY) {
-		kthread_run(deferred_init_memmap, NODE_DATA(nid), "pgdatinit%d", nid);
+		kthread_run(deferred_init_memmap, NODE_DATA(nid),
+			    "pgdatinit%d", nid);
 	}
 
 	/* Block until all are initialised */
@@ -1747,8 +1759,8 @@ inline void post_alloc_hook(struct page *page, unsigned int order,
 	set_page_owner(page, order, gfp_flags);
 }
 
-static void prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
-			  unsigned int alloc_flags)
+static void prep_new_page(struct page *page, unsigned int order,
+			  gfp_t gfp_flags, unsigned int alloc_flags)
 {
 	int i;
 	bool poisoned = true;
@@ -1835,7 +1847,10 @@ static struct page *__rmqueue_cma_fallback(struct zone *zone,
 }
 #else
 static inline struct page *__rmqueue_cma_fallback(struct zone *zone,
-						  unsigned int order) { return NULL; }
+						  unsigned int order)
+{
+	return NULL;
+}
 #endif
 
 /*
@@ -2216,7 +2231,8 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
 	     --current_order) {
 		area = &(zone->free_area[current_order]);
 		fallback_mt = find_suitable_fallback(area, current_order,
-						     start_migratetype, false, &can_steal);
+						     start_migratetype, false,
+						     &can_steal);
 		if (fallback_mt == -1)
 			continue;
 
@@ -2780,9 +2796,11 @@ struct page *rmqueue(struct zone *preferred_zone,
 	do {
 		page = NULL;
 		if (alloc_flags & ALLOC_HARDER) {
-			page = __rmqueue_smallest(zone, order, MIGRATE_HIGHATOMIC);
+			page = __rmqueue_smallest(zone, order,
+						  MIGRATE_HIGHATOMIC);
 			if (page)
-				trace_mm_page_alloc_zone_locked(page, order, migratetype);
+				trace_mm_page_alloc_zone_locked(page, order,
+								migratetype);
 		}
 		if (!page)
 			page = __rmqueue(zone, order, migratetype);
@@ -2966,7 +2984,8 @@ bool zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
 }
 
 static inline bool zone_watermark_fast(struct zone *z, unsigned int order,
-				       unsigned long mark, int classzone_idx, unsigned int alloc_flags)
+				       unsigned long mark, int classzone_idx,
+				       unsigned int alloc_flags)
 {
 	long free_pages = zone_page_state(z, NR_FREE_PAGES);
 	long cma_pages = 0;
@@ -2984,7 +3003,8 @@ static inline bool zone_watermark_fast(struct zone *z, unsigned int order,
 	 * the caller is !atomic then it'll uselessly search the free
 	 * list. That corner case is then slower but it is harmless.
 	 */
-	if (!order && (free_pages - cma_pages) > mark + z->lowmem_reserve[classzone_idx])
+	if (!order &&
+	    (free_pages - cma_pages) > mark + z->lowmem_reserve[classzone_idx])
 		return true;
 
 	return __zone_watermark_ok(z, order, mark, classzone_idx, alloc_flags,
@@ -3081,7 +3101,8 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 				goto try_this_zone;
 
 			if (node_reclaim_mode == 0 ||
-			    !zone_allows_reclaim(ac->preferred_zoneref->zone, zone))
+			    !zone_allows_reclaim(ac->preferred_zoneref->zone,
+						 zone))
 				continue;
 
 			ret = node_reclaim(zone->zone_pgdat, gfp_mask, order);
@@ -3095,7 +3116,8 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 			default:
 				/* did we reclaim enough */
 				if (zone_watermark_ok(zone, order, mark,
-						      ac_classzone_idx(ac), alloc_flags))
+						      ac_classzone_idx(ac),
+						      alloc_flags))
 					goto try_this_zone;
 
 				continue;
@@ -3212,7 +3234,8 @@ __alloc_pages_cpuset_fallback(gfp_t gfp_mask, unsigned int order,
 
 static inline struct page *
 __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
-		      const struct alloc_context *ac, unsigned long *did_some_progress)
+		      const struct alloc_context *ac,
+		      unsigned long *did_some_progress)
 {
 	struct oom_control oc = {
 		.zonelist = ac->zonelist,
@@ -3280,7 +3303,8 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 		 */
 		if (gfp_mask & __GFP_NOFAIL)
 			page = __alloc_pages_cpuset_fallback(gfp_mask, order,
-							     ALLOC_NO_WATERMARKS, ac);
+							     ALLOC_NO_WATERMARKS,
+							     ac);
 	}
 out:
 	mutex_unlock(&oom_lock);
@@ -3297,8 +3321,10 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 /* Try memory compaction for high-order allocations before reclaim */
 static struct page *
 __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
-			     unsigned int alloc_flags, const struct alloc_context *ac,
-			     enum compact_priority prio, enum compact_result *compact_result)
+			     unsigned int alloc_flags,
+			     const struct alloc_context *ac,
+			     enum compact_priority prio,
+			     enum compact_result *compact_result)
 {
 	struct page *page;
 
@@ -3413,16 +3439,18 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
 #else
 static inline struct page *
 __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
-			     unsigned int alloc_flags, const struct alloc_context *ac,
-			     enum compact_priority prio, enum compact_result *compact_result)
+			     unsigned int alloc_flags,
+			     const struct alloc_context *ac,
+			     enum compact_priority prio,
+			     enum compact_result *compact_result)
 {
 	*compact_result = COMPACT_SKIPPED;
 	return NULL;
 }
 
 static inline bool
-should_compact_retry(struct alloc_context *ac, unsigned int order, int alloc_flags,
-		     enum compact_result compact_result,
+should_compact_retry(struct alloc_context *ac, unsigned int order,
+		     int alloc_flags, enum compact_result compact_result,
 		     enum compact_priority *compact_priority,
 		     int *compaction_retries)
 {
@@ -3480,7 +3508,8 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order,
 /* The really slow allocator path where we enter direct reclaim */
 static inline struct page *
 __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
-			     unsigned int alloc_flags, const struct alloc_context *ac,
+			     unsigned int alloc_flags,
+			     const struct alloc_context *ac,
 			     unsigned long *did_some_progress)
 {
 	struct page *page = NULL;
@@ -3522,8 +3551,7 @@ static void wake_all_kswapds(unsigned int order, const struct alloc_context *ac)
 	}
 }
 
-static inline unsigned int
-gfp_to_alloc_flags(gfp_t gfp_mask)
+static inline unsigned int gfp_to_alloc_flags(gfp_t gfp_mask)
 {
 	unsigned int alloc_flags = ALLOC_WMARK_MIN | ALLOC_CPUSET;
 
@@ -3635,9 +3663,11 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned int order,
 		 * reclaimable pages?
 		 */
 		wmark = __zone_watermark_ok(zone, order, min_wmark,
-					    ac_classzone_idx(ac), alloc_flags, available);
+					    ac_classzone_idx(ac), alloc_flags,
+					    available);
 		trace_reclaim_retry_zone(z, order, reclaimable,
-					 available, min_wmark, *no_progress_loops, wmark);
+					 available, min_wmark,
+					 *no_progress_loops, wmark);
 		if (wmark) {
 			/*
 			 * If we didn't make any progress and have a lot of
@@ -3734,7 +3764,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	 * could end up iterating over non-eligible zones endlessly.
 	 */
 	ac->preferred_zoneref = first_zones_zonelist(ac->zonelist,
-						     ac->high_zoneidx, ac->nodemask);
+						     ac->high_zoneidx,
+						     ac->nodemask);
 	if (!ac->preferred_zoneref->zone)
 		goto nopage;
 
@@ -3807,10 +3838,12 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	 * These allocations are high priority and system rather than user
 	 * orientated.
 	 */
-	if (!(alloc_flags & ALLOC_CPUSET) || (alloc_flags & ALLOC_NO_WATERMARKS)) {
+	if (!(alloc_flags & ALLOC_CPUSET) ||
+	    (alloc_flags & ALLOC_NO_WATERMARKS)) {
 		ac->zonelist = node_zonelist(numa_node_id(), gfp_mask);
 		ac->preferred_zoneref = first_zones_zonelist(ac->zonelist,
-							     ac->high_zoneidx, ac->nodemask);
+							     ac->high_zoneidx,
+							     ac->nodemask);
 	}
 
 	/* Attempt with potentially adjusted zonelist and alloc_flags */
@@ -3939,7 +3972,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		 * could deplete whole memory reserves which would just make
 		 * the situation worse
 		 */
-		page = __alloc_pages_cpuset_fallback(gfp_mask, order, ALLOC_HARDER, ac);
+		page = __alloc_pages_cpuset_fallback(gfp_mask, order,
+						     ALLOC_HARDER, ac);
 		if (page)
 			goto got_pg;
 
@@ -3953,10 +3987,11 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	return page;
 }
 
-static inline bool prepare_alloc_pages(gfp_t gfp_mask, unsigned int order,
-				       struct zonelist *zonelist, nodemask_t *nodemask,
-				       struct alloc_context *ac, gfp_t *alloc_mask,
-				       unsigned int *alloc_flags)
+static inline
+bool prepare_alloc_pages(gfp_t gfp_mask, unsigned int order,
+			 struct zonelist *zonelist, nodemask_t *nodemask,
+			 struct alloc_context *ac, gfp_t *alloc_mask,
+			 unsigned int *alloc_flags)
 {
 	ac->high_zoneidx = gfp_zone(gfp_mask);
 	ac->zonelist = zonelist;
@@ -3997,7 +4032,8 @@ static inline void finalise_ac(gfp_t gfp_mask,
 	 * may get reset for allocations that ignore memory policies.
 	 */
 	ac->preferred_zoneref = first_zones_zonelist(ac->zonelist,
-						     ac->high_zoneidx, ac->nodemask);
+						     ac->high_zoneidx,
+						     ac->nodemask);
 }
 
 /*
@@ -4013,7 +4049,8 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	struct alloc_context ac = { };
 
 	gfp_mask &= gfp_allowed_mask;
-	if (!prepare_alloc_pages(gfp_mask, order, zonelist, nodemask, &ac, &alloc_mask, &alloc_flags))
+	if (!prepare_alloc_pages(gfp_mask, order, zonelist, nodemask, &ac,
+				 &alloc_mask, &alloc_flags))
 		return NULL;
 
 	finalise_ac(gfp_mask, order, &ac);
@@ -4448,7 +4485,8 @@ void si_meminfo_node(struct sysinfo *val, int nid)
  * Determine whether the node should be displayed or not, depending on whether
  * SHOW_MEM_FILTER_NODES was passed to show_free_areas().
  */
-static bool show_mem_node_skip(unsigned int flags, int nid, nodemask_t *nodemask)
+static bool show_mem_node_skip(unsigned int flags, int nid,
+			       nodemask_t *nodemask)
 {
 	if (!(flags & SHOW_MEM_FILTER_NODES))
 		return false;
@@ -5187,7 +5225,8 @@ static int __build_all_zonelists(void *data)
 		 * node/memory hotplug, we'll fixup all on-line cpus.
 		 */
 		if (cpu_online(cpu))
-			set_cpu_numa_mem(cpu, local_memory_node(cpu_to_node(cpu)));
+			set_cpu_numa_mem(cpu,
+					 local_memory_node(cpu_to_node(cpu)));
 #endif
 	}
 
@@ -5690,12 +5729,13 @@ static void __init find_usable_zone_for_movable(void)
  * highest usable zone for ZONE_MOVABLE. This preserves the assumption that
  * zones within a node are in order of monotonic increases memory addresses
  */
-static void __meminit adjust_zone_range_for_zone_movable(int nid,
-							 unsigned long zone_type,
-							 unsigned long node_start_pfn,
-							 unsigned long node_end_pfn,
-							 unsigned long *zone_start_pfn,
-							 unsigned long *zone_end_pfn)
+static void __meminit
+adjust_zone_range_for_zone_movable(int nid,
+				   unsigned long zone_type,
+				   unsigned long node_start_pfn,
+				   unsigned long node_end_pfn,
+				   unsigned long *zone_start_pfn,
+				   unsigned long *zone_end_pfn)
 {
 	/* Only adjust if ZONE_MOVABLE is on this node */
 	if (zone_movable_pfn[nid]) {
@@ -5721,13 +5761,14 @@ static void __meminit adjust_zone_range_for_zone_movable(int nid,
  * Return the number of pages a zone spans in a node, including holes
  * present_pages = zone_spanned_pages_in_node() - zone_absent_pages_in_node()
  */
-static unsigned long __meminit zone_spanned_pages_in_node(int nid,
-							  unsigned long zone_type,
-							  unsigned long node_start_pfn,
-							  unsigned long node_end_pfn,
-							  unsigned long *zone_start_pfn,
-							  unsigned long *zone_end_pfn,
-							  unsigned long *ignored)
+static unsigned long __meminit
+zone_spanned_pages_in_node(int nid,
+			   unsigned long zone_type,
+			   unsigned long node_start_pfn,
+			   unsigned long node_end_pfn,
+			   unsigned long *zone_start_pfn,
+			   unsigned long *zone_end_pfn,
+			   unsigned long *ignored)
 {
 	/* When hotadd a new node from cpu_up(), the node should be empty */
 	if (!node_start_pfn && !node_end_pfn)
@@ -5786,11 +5827,12 @@ unsigned long __init absent_pages_in_range(unsigned long start_pfn,
 }
 
 /* Return the number of page frames in holes in a zone on a node */
-static unsigned long __meminit zone_absent_pages_in_node(int nid,
-							 unsigned long zone_type,
-							 unsigned long node_start_pfn,
-							 unsigned long node_end_pfn,
-							 unsigned long *ignored)
+static unsigned long __meminit
+zone_absent_pages_in_node(int nid,
+			  unsigned long zone_type,
+			  unsigned long node_start_pfn,
+			  unsigned long node_end_pfn,
+			  unsigned long *ignored)
 {
 	unsigned long zone_low = arch_zone_lowest_possible_pfn[zone_type];
 	unsigned long zone_high = arch_zone_highest_possible_pfn[zone_type];
@@ -5843,13 +5885,14 @@ static unsigned long __meminit zone_absent_pages_in_node(int nid,
 }
 
 #else /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
-static inline unsigned long __meminit zone_spanned_pages_in_node(int nid,
-								 unsigned long zone_type,
-								 unsigned long node_start_pfn,
-								 unsigned long node_end_pfn,
-								 unsigned long *zone_start_pfn,
-								 unsigned long *zone_end_pfn,
-								 unsigned long *zones_size)
+static inline unsigned long __meminit
+zone_spanned_pages_in_node(int nid,
+			   unsigned long zone_type,
+			   unsigned long node_start_pfn,
+			   unsigned long node_end_pfn,
+			   unsigned long *zone_start_pfn,
+			   unsigned long *zone_end_pfn,
+			   unsigned long *zones_size)
 {
 	unsigned int zone;
 
@@ -5862,11 +5905,12 @@ static inline unsigned long __meminit zone_spanned_pages_in_node(int nid,
 	return zones_size[zone_type];
 }
 
-static inline unsigned long __meminit zone_absent_pages_in_node(int nid,
-								unsigned long zone_type,
-								unsigned long node_start_pfn,
-								unsigned long node_end_pfn,
-								unsigned long *zholes_size)
+static inline unsigned long __meminit
+zone_absent_pages_in_node(int nid,
+			  unsigned long zone_type,
+			  unsigned long node_start_pfn,
+			  unsigned long node_end_pfn,
+			  unsigned long *zholes_size)
 {
 	if (!zholes_size)
 		return 0;
@@ -5924,7 +5968,8 @@ static void __meminit calculate_node_totalpages(struct pglist_data *pgdat,
  * round what is now in bits to nearest long in bits, then return it in
  * bytes.
  */
-static unsigned long __init usemap_size(unsigned long zone_start_pfn, unsigned long zonesize)
+static unsigned long __init usemap_size(unsigned long zone_start_pfn,
+					unsigned long zonesize)
 {
 	unsigned long usemapsize;
 
@@ -6158,7 +6203,8 @@ static void __ref alloc_node_mem_map(struct pglist_data *pgdat)
 }
 
 void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
-				      unsigned long node_start_pfn, unsigned long *zholes_size)
+				      unsigned long node_start_pfn,
+				      unsigned long *zholes_size)
 {
 	pg_data_t *pgdat = NODE_DATA(nid);
 	unsigned long start_pfn = 0;
@@ -7028,7 +7074,8 @@ core_initcall(init_per_zone_wmark_min)
  *	changes.
  */
 int min_free_kbytes_sysctl_handler(struct ctl_table *table, int write,
-				   void __user *buffer, size_t *length, loff_t *ppos)
+				   void __user *buffer, size_t *length,
+				   loff_t *ppos)
 {
 	int rc;
 
@@ -7044,7 +7091,8 @@ int min_free_kbytes_sysctl_handler(struct ctl_table *table, int write,
 }
 
 int watermark_scale_factor_sysctl_handler(struct ctl_table *table, int write,
-					  void __user *buffer, size_t *length, loff_t *ppos)
+					  void __user *buffer, size_t *length,
+					  loff_t *ppos)
 {
 	int rc;
 
@@ -7068,8 +7116,8 @@ static void setup_min_unmapped_ratio(void)
 		pgdat->min_unmapped_pages = 0;
 
 	for_each_zone(zone)
-		zone->zone_pgdat->min_unmapped_pages += (zone->managed_pages *
-							 sysctl_min_unmapped_ratio) / 100;
+		zone->zone_pgdat->min_unmapped_pages +=
+			(zone->managed_pages * sysctl_min_unmapped_ratio) / 100;
 }
 
 int sysctl_min_unmapped_ratio_sysctl_handler(struct ctl_table *table, int write,
@@ -7095,12 +7143,13 @@ static void setup_min_slab_ratio(void)
 		pgdat->min_slab_pages = 0;
 
 	for_each_zone(zone)
-		zone->zone_pgdat->min_slab_pages += (zone->managed_pages *
-						     sysctl_min_slab_ratio) / 100;
+		zone->zone_pgdat->min_slab_pages +=
+			(zone->managed_pages * sysctl_min_slab_ratio) / 100;
 }
 
 int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *table, int write,
-					 void __user *buffer, size_t *length, loff_t *ppos)
+					 void __user *buffer, size_t *length,
+					 loff_t *ppos)
 {
 	int rc;
 
@@ -7124,7 +7173,8 @@ int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *table, int write,
  * if in function of the boot time zone sizes.
  */
 int lowmem_reserve_ratio_sysctl_handler(struct ctl_table *table, int write,
-					void __user *buffer, size_t *length, loff_t *ppos)
+					void __user *buffer, size_t *length,
+					loff_t *ppos)
 {
 	proc_dointvec_minmax(table, write, buffer, length, ppos);
 	setup_per_zone_lowmem_reserve();
@@ -7137,7 +7187,8 @@ int lowmem_reserve_ratio_sysctl_handler(struct ctl_table *table, int write,
  * pagelist can have before it gets flushed back to buddy allocator.
  */
 int percpu_pagelist_fraction_sysctl_handler(struct ctl_table *table, int write,
-					    void __user *buffer, size_t *length, loff_t *ppos)
+					    void __user *buffer, size_t *length,
+					    loff_t *ppos)
 {
 	struct zone *zone;
 	int old_percpu_pagelist_fraction;
@@ -7167,7 +7218,8 @@ int percpu_pagelist_fraction_sysctl_handler(struct ctl_table *table, int write,
 
 		for_each_possible_cpu(cpu)
 			pageset_set_high_and_batch(zone,
-						   per_cpu_ptr(zone->pageset, cpu));
+						   per_cpu_ptr(zone->pageset,
+							       cpu));
 	}
 out:
 	mutex_unlock(&pcp_batch_high_lock);
@@ -7238,7 +7290,8 @@ void *__init alloc_large_system_hash(const char *tablename,
 
 		/* It isn't necessary when PAGE_SIZE >= 1MB */
 		if (PAGE_SHIFT < 20)
-			numentries = round_up(numentries, (1 << 20) / PAGE_SIZE);
+			numentries = round_up(numentries,
+					      (1 << 20) / PAGE_SIZE);
 
 		if (flags & HASH_ADAPT) {
 			unsigned long adapt;
@@ -7359,7 +7412,8 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 		 * handle each tail page individually in migration.
 		 */
 		if (PageHuge(page)) {
-			iter = round_up(iter + 1, 1 << compound_order(page)) - 1;
+			iter = round_up(iter + 1,
+					1 << compound_order(page)) - 1;
 			continue;
 		}
 
@@ -7429,7 +7483,8 @@ bool is_pageblock_removable_nolock(struct page *page)
 	return !has_unmovable_pages(zone, page, 0, true);
 }
 
-#if (defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || defined(CONFIG_CMA)
+#if (defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || \
+     defined(CONFIG_CMA)
 
 static unsigned long pfn_max_align_down(unsigned long pfn)
 {
-- 
2.10.0.rc2.1.g053435c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
