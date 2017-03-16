Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 541A46B03AA
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 22:01:48 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id z13so41869095iof.7
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 19:01:48 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0133.hostedemail.com. [216.40.44.133])
        by mx.google.com with ESMTPS id w127si2038354itd.32.2017.03.15.19.01.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 19:01:47 -0700 (PDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 11/15] mm: page_alloc: Move EXPORT_SYMBOL uses
Date: Wed, 15 Mar 2017 19:00:08 -0700
Message-Id: <f1543f1b2a4d23b4582e7bcc68899f5897e681a5.1489628477.git.joe@perches.com>
In-Reply-To: <cover.1489628477.git.joe@perches.com>
References: <cover.1489628477.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

To immediately after the declarations

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/page_alloc.c | 33 ++++++++++++++++-----------------
 1 file changed, 16 insertions(+), 17 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 286b01b4c3e7..f9e6387c0ad4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -124,6 +124,7 @@ EXPORT_SYMBOL(node_states);
 static DEFINE_SPINLOCK(managed_page_count_lock);
 
 unsigned long totalram_pages __read_mostly;
+EXPORT_SYMBOL(totalram_pages);
 unsigned long totalreserve_pages __read_mostly;
 unsigned long totalcma_pages __read_mostly;
 
@@ -215,8 +216,6 @@ int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES - 1] = {
 	32,
 };
 
-EXPORT_SYMBOL(totalram_pages);
-
 static char * const zone_names[MAX_NR_ZONES] = {
 #ifdef CONFIG_ZONE_DMA
 	"DMA",
@@ -281,8 +280,8 @@ EXPORT_SYMBOL(movable_zone);
 
 #if MAX_NUMNODES > 1
 int nr_node_ids __read_mostly = MAX_NUMNODES;
-int nr_online_nodes __read_mostly = 1;
 EXPORT_SYMBOL(nr_node_ids);
+int nr_online_nodes __read_mostly = 1;
 EXPORT_SYMBOL(nr_online_nodes);
 #endif
 
@@ -2706,9 +2705,9 @@ static inline void zone_statistics(struct zone *preferred_zone, struct zone *z)
 	if (z->node != numa_node_id())
 		local_stat = NUMA_OTHER;
 
-	if (z->node == preferred_zone->node)
+	if (z->node == preferred_zone->node) {
 		__inc_zone_state(z, NUMA_HIT);
-	else {
+	} else {
 		__inc_zone_state(z, NUMA_MISS);
 		__inc_zone_state(preferred_zone, NUMA_FOREIGN);
 	}
@@ -3578,8 +3577,9 @@ static inline unsigned int gfp_to_alloc_flags(gfp_t gfp_mask)
 		 * comment for __cpuset_node_allowed().
 		 */
 		alloc_flags &= ~ALLOC_CPUSET;
-	} else if (unlikely(rt_task(current)) && !in_interrupt())
+	} else if (unlikely(rt_task(current)) && !in_interrupt()) {
 		alloc_flags |= ALLOC_HARDER;
+	}
 
 #ifdef CONFIG_CMA
 	if (gfpflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
@@ -4129,7 +4129,6 @@ void __free_pages(struct page *page, unsigned int order)
 			__free_pages_ok(page, order);
 	}
 }
-
 EXPORT_SYMBOL(__free_pages);
 
 void free_pages(unsigned long addr, unsigned int order)
@@ -4139,7 +4138,6 @@ void free_pages(unsigned long addr, unsigned int order)
 		__free_pages(virt_to_page((void *)addr), order);
 	}
 }
-
 EXPORT_SYMBOL(free_pages);
 
 /*
@@ -4445,7 +4443,6 @@ void si_meminfo(struct sysinfo *val)
 	val->freehigh = nr_free_highpages();
 	val->mem_unit = PAGE_SIZE;
 }
-
 EXPORT_SYMBOL(si_meminfo);
 
 #ifdef CONFIG_NUMA
@@ -5189,9 +5186,8 @@ static int __build_all_zonelists(void *data)
 	memset(node_load, 0, sizeof(node_load));
 #endif
 
-	if (self && !node_online(self->node_id)) {
+	if (self && !node_online(self->node_id))
 		build_zonelists(self);
-	}
 
 	for_each_online_node(nid) {
 		pg_data_t *pgdat = NODE_DATA(nid);
@@ -5752,8 +5748,9 @@ adjust_zone_range_for_zone_movable(int nid,
 			*zone_end_pfn = zone_movable_pfn[nid];
 
 			/* Check if this whole range is within ZONE_MOVABLE */
-		} else if (*zone_start_pfn >= zone_movable_pfn[nid])
+		} else if (*zone_start_pfn >= zone_movable_pfn[nid]) {
 			*zone_start_pfn = *zone_end_pfn;
+		}
 	}
 }
 
@@ -6111,9 +6108,10 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 				if (memmap_pages)
 					printk(KERN_DEBUG "  %s zone: %lu pages used for memmap\n",
 					       zone_names[j], memmap_pages);
-			} else
+			} else {
 				pr_warn("  %s zone: %lu pages exceeds freesize %lu\n",
 					zone_names[j], memmap_pages, freesize);
+			}
 		}
 
 		/* Account for reserved pages */
@@ -7315,8 +7313,9 @@ void *__init alloc_large_system_hash(const char *tablename,
 				numentries = 1UL << *_hash_shift;
 				BUG_ON(!numentries);
 			}
-		} else if (unlikely((numentries * bucketsize) < PAGE_SIZE))
+		} else if (unlikely((numentries * bucketsize) < PAGE_SIZE)) {
 			numentries = PAGE_SIZE / bucketsize;
+		}
 	}
 	numentries = roundup_pow_of_two(numentries);
 
@@ -7341,11 +7340,11 @@ void *__init alloc_large_system_hash(const char *tablename,
 	gfp_flags = (flags & HASH_ZERO) ? GFP_ATOMIC | __GFP_ZERO : GFP_ATOMIC;
 	do {
 		size = bucketsize << log2qty;
-		if (flags & HASH_EARLY)
+		if (flags & HASH_EARLY) {
 			table = memblock_virt_alloc_nopanic(size, 0);
-		else if (hashdist)
+		} else if (hashdist) {
 			table = __vmalloc(size, gfp_flags, PAGE_KERNEL);
-		else {
+		} else {
 			/*
 			 * If bucketsize is not a power-of-two, we may free
 			 * some pages at the end of hash table which
-- 
2.10.0.rc2.1.g053435c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
