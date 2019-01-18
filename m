Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 171AB8E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 18:51:34 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id d18so11304516pfe.0
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 15:51:34 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w12sor8876648plq.62.2019.01.18.15.51.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 18 Jan 2019 15:51:32 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm: fix some typo scatter in mm directory
Date: Sat, 19 Jan 2019 07:51:23 +0800
Message-Id: <20190118235123.27843-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mhocko@suse.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, Wei Yang <richard.weiyang@gmail.com>

No functional change.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 include/linux/mmzone.h | 2 +-
 mm/migrate.c           | 2 +-
 mm/mmap.c              | 8 ++++----
 mm/page_alloc.c        | 4 ++--
 mm/slub.c              | 2 +-
 mm/vmscan.c            | 2 +-
 6 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 842f9189537b..faf8cf60f900 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1299,7 +1299,7 @@ void memory_present(int nid, unsigned long start, unsigned long end);
 
 /*
  * If it is possible to have holes within a MAX_ORDER_NR_PAGES, then we
- * need to check pfn validility within that MAX_ORDER_NR_PAGES block.
+ * need to check pfn validity within that MAX_ORDER_NR_PAGES block.
  * pfn_valid_within() should be used in this case; we optimise this away
  * when we have no holes within a MAX_ORDER_NR_PAGES block.
  */
diff --git a/mm/migrate.c b/mm/migrate.c
index a16b15090df3..2122f38f569e 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -100,7 +100,7 @@ int isolate_movable_page(struct page *page, isolate_mode_t mode)
 	/*
 	 * Check PageMovable before holding a PG_lock because page's owner
 	 * assumes anybody doesn't touch PG_lock of newly allocated page
-	 * so unconditionally grapping the lock ruins page's owner side.
+	 * so unconditionally grabbing the lock ruins page's owner side.
 	 */
 	if (unlikely(!__PageMovable(page)))
 		goto out_putpage;
diff --git a/mm/mmap.c b/mm/mmap.c
index f901065c4c64..55b8e6b55738 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -438,7 +438,7 @@ static void vma_gap_update(struct vm_area_struct *vma)
 {
 	/*
 	 * As it turns out, RB_DECLARE_CALLBACKS() already created a callback
-	 * function that does exacltly what we want.
+	 * function that does exactly what we want.
 	 */
 	vma_gap_callbacks_propagate(&vma->vm_rb, NULL);
 }
@@ -1012,7 +1012,7 @@ static inline int is_mergeable_vma(struct vm_area_struct *vma,
 	 * VM_SOFTDIRTY should not prevent from VMA merging, if we
 	 * match the flags but dirty bit -- the caller should mark
 	 * merged VMA as dirty. If dirty bit won't be excluded from
-	 * comparison, we increase pressue on the memory system forcing
+	 * comparison, we increase pressure on the memory system forcing
 	 * the kernel to generate new VMAs when old one could be
 	 * extended instead.
 	 */
@@ -1115,7 +1115,7 @@ can_vma_merge_after(struct vm_area_struct *vma, unsigned long vm_flags,
  *    PPPP    NNNN    PPPPPPPPPPPP    PPPPPPPPNNNN    PPPPNNNNNNNN
  *    might become    case 1 below    case 2 below    case 3 below
  *
- * It is important for case 8 that the the vma NNNN overlapping the
+ * It is important for case 8 that the vma NNNN overlapping the
  * region AAAA is never going to extended over XXXX. Instead XXXX must
  * be extended in region AAAA and NNNN must be removed. This way in
  * all cases where vma_merge succeeds, the moment vma_adjust drops the
@@ -1645,7 +1645,7 @@ SYSCALL_DEFINE1(old_mmap, struct mmap_arg_struct __user *, arg)
 #endif /* __ARCH_WANT_SYS_OLD_MMAP */
 
 /*
- * Some shared mappigns will want the pages marked read-only
+ * Some shared mappings will want the pages marked read-only
  * to track write events. If so, we'll downgrade vm_page_prot
  * to the private version (using protection_map[] without the
  * VM_SHARED bit).
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d7073cedd087..43ceb2481ad5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7493,7 +7493,7 @@ static void __setup_per_zone_wmarks(void)
 			 * value here.
 			 *
 			 * The WMARK_HIGH-WMARK_LOW and (WMARK_LOW-WMARK_MIN)
-			 * deltas control asynch page reclaim, and so should
+			 * deltas control async page reclaim, and so should
 			 * not be capped for highmem.
 			 */
 			unsigned long min_pages;
@@ -7970,7 +7970,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 
 		/*
 		 * Hugepages are not in LRU lists, but they're movable.
-		 * We need not scan over tail pages bacause we don't
+		 * We need not scan over tail pages because we don't
 		 * handle each tail page individually in migration.
 		 */
 		if (PageHuge(page)) {
diff --git a/mm/slub.c b/mm/slub.c
index 1e3d0ec4e200..c3738f671a0c 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2111,7 +2111,7 @@ static void deactivate_slab(struct kmem_cache *s, struct page *page,
 		if (!lock) {
 			lock = 1;
 			/*
-			 * Taking the spinlock removes the possiblity
+			 * Taking the spinlock removes the possibility
 			 * that acquire_slab() will see a slab page that
 			 * is frozen
 			 */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a714c4f800e9..1b573812e546 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3537,7 +3537,7 @@ static bool kswapd_shrink_node(pg_data_t *pgdat,
  *
  * kswapd scans the zones in the highmem->normal->dma direction.  It skips
  * zones which have free_pages > high_wmark_pages(zone), but once a zone is
- * found to have free_pages <= high_wmark_pages(zone), any page is that zone
+ * found to have free_pages <= high_wmark_pages(zone), any page in that zone
  * or lower is eligible for reclaim until at least one usable zone is
  * balanced.
  */
-- 
2.15.1
