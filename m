Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 5EAA76B0068
	for <linux-mm@kvack.org>; Sun, 17 Jun 2012 00:12:43 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so8418799pbb.14
        for <linux-mm@kvack.org>; Sat, 16 Jun 2012 21:12:42 -0700 (PDT)
From: Wanpeng Li <liwp.linux@gmail.com>
Subject: [PATCH] mm: cleanup comments error in mm subsystem
Date: Sun, 17 Jun 2012 12:12:19 +0800
Message-Id: <1339906339-8680-1-git-send-email-liwp.linux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Kosina <trivial@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwp.linux@gmail.com>, David Rientjes <rientjes@google.com>, Gavin Shan <shangw@linux.vnet.ibm.com>

From: Wanpeng Li <liwp@linux.vnet.ibm.com>

Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>
Acked-by: Minchan Kim <minchan@kernel.org>
Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Rik van Riel <riel@redhat.com>

---
 Documentation/vm/frontswap.txt |    4 ++--
 include/linux/mmzone.h         |    2 +-
 mm/frontswap.c                 |    2 +-
 mm/memblock.c                  |   12 ++++++------
 mm/memcontrol.c                |    4 ++--
 mm/oom_kill.c                  |    2 +-
 mm/page_cgroup.c               |    4 ++--
 mm/pagewalk.c                  |    1 -
 mm/percpu-vm.c                 |    1 -
 mm/vmscan.c                    |    5 +++--
 10 files changed, 18 insertions(+), 19 deletions(-)

diff --git a/Documentation/vm/frontswap.txt b/Documentation/vm/frontswap.txt
index 37067cf..5ef2d13 100644
--- a/Documentation/vm/frontswap.txt
+++ b/Documentation/vm/frontswap.txt
@@ -25,7 +25,7 @@ with the specified swap device number (aka "type").  A "store" will
 copy the page to transcendent memory and associate it with the type and
 offset associated with the page. A "load" will copy the page, if found,
 from transcendent memory into kernel memory, but will NOT remove the page
-from from transcendent memory.  An "invalidate_page" will remove the page
+from transcendent memory.  An "invalidate_page" will remove the page
 from transcendent memory and an "invalidate_area" will remove ALL pages
 associated with the swap type (e.g., like swapoff) and notify the "device"
 to refuse further stores with that swap type.
@@ -99,7 +99,7 @@ server configured with a large amount of RAM... without pre-configuring
 how much of the RAM is available for each of the clients!
 
 In the virtual case, the whole point of virtualization is to statistically
-multiplex physical resources acrosst the varying demands of multiple
+multiplex physical resources across the varying demands of multiple
 virtual machines.  This is really hard to do with RAM and efforts to do
 it well with no kernel changes have essentially failed (except in some
 well-publicized special-case workloads).
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 2427706..d6a5f83 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -188,7 +188,7 @@ static inline int is_unevictable_lru(enum lru_list lru)
 struct zone_reclaim_stat {
 	/*
 	 * The pageout code in vmscan.c keeps track of how many of the
-	 * mem/swap backed and file backed pages are refeferenced.
+	 * mem/swap backed and file backed pages are referenced.
 	 * The higher the rotated/scanned ratio, the more valuable
 	 * that cache is.
 	 *
diff --git a/mm/frontswap.c b/mm/frontswap.c
index e250255..174c3f3 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -119,7 +119,7 @@ EXPORT_SYMBOL(__frontswap_init);
  * "Store" data from a page to frontswap and associate it with the page's
  * swaptype and offset.  Page must be locked and in the swap cache.
  * If frontswap already contains a page with matching swaptype and
- * offset, the frontswap implmentation may either overwrite the data and
+ * offset, the frontswap implementation may either overwrite the data and
  * return success or invalidate the page from frontswap and return failure.
  */
 int __frontswap_store(struct page *page)
diff --git a/mm/memblock.c b/mm/memblock.c
index 32a0a5e..b65b687 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -540,9 +540,9 @@ int __init_memblock memblock_reserve(phys_addr_t base, phys_addr_t size)
  * __next_free_mem_range - next function for for_each_free_mem_range()
  * @idx: pointer to u64 loop variable
  * @nid: nid: node selector, %MAX_NUMNODES for all nodes
- * @p_start: ptr to phys_addr_t for start address of the range, can be %NULL
- * @p_end: ptr to phys_addr_t for end address of the range, can be %NULL
- * @p_nid: ptr to int for nid of the range, can be %NULL
+ * @out_start: ptr to phys_addr_t for start address of the range, can be %NULL
+ * @out_end: ptr to phys_addr_t for end address of the range, can be %NULL
+ * @out_nid: ptr to int for nid of the range, can be %NULL
  *
  * Find the first free area from *@idx which matches @nid, fill the out
  * parameters, and update *@idx for the next iteration.  The lower 32bit of
@@ -616,9 +616,9 @@ void __init_memblock __next_free_mem_range(u64 *idx, int nid,
  * __next_free_mem_range_rev - next function for for_each_free_mem_range_reverse()
  * @idx: pointer to u64 loop variable
  * @nid: nid: node selector, %MAX_NUMNODES for all nodes
- * @p_start: ptr to phys_addr_t for start address of the range, can be %NULL
- * @p_end: ptr to phys_addr_t for end address of the range, can be %NULL
- * @p_nid: ptr to int for nid of the range, can be %NULL
+ * @out_start: ptr to phys_addr_t for start address of the range, can be %NULL
+ * @out_end: ptr to phys_addr_t for end address of the range, can be %NULL
+ * @out_nid: ptr to int for nid of the range, can be %NULL
  *
  * Reverse of __next_free_mem_range().
  */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ac35bcc..a9c3d01 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1234,7 +1234,7 @@ int mem_cgroup_inactive_file_is_low(struct lruvec *lruvec)
 
 /**
  * mem_cgroup_margin - calculate chargeable space of a memory cgroup
- * @mem: the memory cgroup
+ * @memcg: the memory cgroup
  *
  * Returns the maximum amount of memory @mem can be charged with, in
  * pages.
@@ -1508,7 +1508,7 @@ static unsigned long mem_cgroup_reclaim(struct mem_cgroup *memcg,
 
 /**
  * test_mem_cgroup_node_reclaimable
- * @mem: the target memcg
+ * @memcg: the target memcg
  * @nid: the node ID to be checked.
  * @noswap : specify true here if the user wants flle only information.
  *
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 416637f..c1956f1 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -366,7 +366,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 
 /**
  * dump_tasks - dump current memory state of all system tasks
- * @mem: current's memory controller, if constrained
+ * @memcg: current's memory controller, if constrained
  * @nodemask: nodemask passed to page allocator for mempolicy ooms
  *
  * Dumps the current memory state of all eligible tasks.  Tasks not in the same
diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 1ccbd71..eb750f8 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -392,7 +392,7 @@ static struct swap_cgroup *lookup_swap_cgroup(swp_entry_t ent,
 
 /**
  * swap_cgroup_cmpxchg - cmpxchg mem_cgroup's id for this swp_entry.
- * @end: swap entry to be cmpxchged
+ * @ent: swap entry to be cmpxchged
  * @old: old id
  * @new: new id
  *
@@ -422,7 +422,7 @@ unsigned short swap_cgroup_cmpxchg(swp_entry_t ent,
 /**
  * swap_cgroup_record - record mem_cgroup for this swp_entry.
  * @ent: swap entry to be recorded into
- * @mem: mem_cgroup to be recorded
+ * @id: mem_cgroup to be recorded
  *
  * Returns old value at success, 0 at failure.
  * (Of course, old value can be 0.)
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index aa9701e..6c118d0 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -162,7 +162,6 @@ static int walk_hugetlb_range(struct vm_area_struct *vma,
 
 /**
  * walk_page_range - walk a memory map's page tables with a callback
- * @mm: memory map to walk
  * @addr: starting address
  * @end: ending address
  * @walk: set of callbacks to invoke for each level of the tree
diff --git a/mm/percpu-vm.c b/mm/percpu-vm.c
index 405d331..3707c71 100644
--- a/mm/percpu-vm.c
+++ b/mm/percpu-vm.c
@@ -360,7 +360,6 @@ err_free:
  * @chunk: chunk to depopulate
  * @off: offset to the area to depopulate
  * @size: size of the area to depopulate in bytes
- * @flush: whether to flush cache and tlb or not
  *
  * For each cpu, depopulate and unmap pages [@page_start,@page_end)
  * from @chunk.  If @flush is true, vcache is flushed before unmapping
diff --git a/mm/vmscan.c b/mm/vmscan.c
index eeb3bc9..3356135 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1567,7 +1567,8 @@ static int vmscan_swappiness(struct scan_control *sc)
  * by looking at the fraction of the pages scanned we did rotate back
  * onto the active list instead of evict.
  *
- * nr[0] = anon pages to scan; nr[1] = file pages to scan
+ * nr[0] = anon inactive pages to scan; nr[1] = anon active pages to scan
+ * nr[2] = file inactive pages to scan; nr[3] = file active pages to scan
  */
 static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
 			   unsigned long *nr)
@@ -2537,7 +2538,7 @@ loop_again:
 				 * consider it to be no longer congested. It's
 				 * possible there are dirty pages backed by
 				 * congested BDIs but as pressure is relieved,
-				 * spectulatively avoid congestion waits
+				 * speculatively avoid congestion waits
 				 */
 				zone_clear_flag(zone, ZONE_CONGESTED);
 				if (i <= *classzone_idx)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
