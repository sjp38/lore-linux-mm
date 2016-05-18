Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1A63A6B007E
	for <linux-mm@kvack.org>; Tue, 17 May 2016 22:36:33 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id xm6so49994693pab.3
        for <linux-mm@kvack.org>; Tue, 17 May 2016 19:36:33 -0700 (PDT)
Received: from smtp2203-239.mail.aliyun.com (smtp2203-239.mail.aliyun.com. [121.197.203.239])
        by mx.google.com with ESMTP id 20si8685528pfr.90.2016.05.17.19.36.30
        for <linux-mm@kvack.org>;
        Tue, 17 May 2016 19:36:31 -0700 (PDT)
From: Li Peng <lip@dtdream.com>
Subject: [PATCH] mm: fix duplicate words and typos
Date: Wed, 18 May 2016 10:35:56 +0800
Message-Id: <1463538956-7342-1-git-send-email-lip@dtdream.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Li Peng <lip@dtdream.com>

Signed-off-by: Li Peng <lip@dtdream.com>
---
 mm/memcontrol.c | 2 +-
 mm/page_alloc.c | 6 +++---
 mm/vmscan.c     | 7 +++----
 mm/zswap.c      | 2 +-
 4 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index fe787f5..4b74255 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2293,7 +2293,7 @@ struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
 
 	/*
 	 * If we are in a safe context (can wait, and not in interrupt
-	 * context), we could be be predictable and return right away.
+	 * context), we could be predictable and return right away.
 	 * This would guarantee that the allocation being performed
 	 * already belongs in the new cache.
 	 *
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c1069ef..93824cb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3030,7 +3030,7 @@ retry:
 	/*
 	 * If an allocation failed after direct reclaim, it could be because
 	 * pages are pinned on the per-cpu lists or in high alloc reserves.
-	 * Shrink them them and try again
+	 * Shrink them and try again.
 	 */
 	if (!page && !drained) {
 		unreserve_highatomic_pageblock(ac);
@@ -4812,7 +4812,7 @@ static int zone_batchsize(struct zone *zone)
  * locking.
  *
  * Any new users of pcp->batch and pcp->high should ensure they can cope with
- * those fields changing asynchronously (acording the the above rule).
+ * those fields changing asynchronously (according to the above rule).
  *
  * mutex_is_locked(&pcp_batch_high_lock) required when calling this function
  * outside of boot time (or some other assurance that no concurrent updaters
@@ -5024,7 +5024,7 @@ int __meminit __early_pfn_to_nid(unsigned long pfn,
  * @max_low_pfn: The highest PFN that will be passed to memblock_free_early_nid
  *
  * If an architecture guarantees that all ranges registered contain no holes
- * and may be freed, this this function may be used instead of calling
+ * and may be freed, this function may be used instead of calling
  * memblock_free_early_nid() manually.
  */
 void __init free_bootmem_with_active_regions(int nid, unsigned long max_low_pfn)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 142cb61..8ff5a79 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1683,8 +1683,8 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 			set_bit(ZONE_DIRTY, &zone->flags);
 
 		/*
-		 * If kswapd scans pages marked marked for immediate
-		 * reclaim and under writeback (nr_immediate), it implies
+		 * If kswapd scans pages marked for immediate reclaim
+		 * and under writeback (nr_immediate), it implies
 		 * that pages are cycling through the LRU faster than
 		 * they are written so also forcibly stall.
 		 */
@@ -3267,8 +3267,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 			/*
 			 * There should be no need to raise the scanning
 			 * priority if enough pages are already being scanned
-			 * that that high watermark would be met at 100%
-			 * efficiency.
+			 * that high watermark would be met at 100% efficiency.
 			 */
 			if (kswapd_shrink_zone(zone, end_zone, &sc))
 				raise_priority = false;
diff --git a/mm/zswap.c b/mm/zswap.c
index de0f119b..6d829d7 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -928,7 +928,7 @@ static int zswap_writeback_entry(struct zpool *pool, unsigned long handle)
 	* a load may happening concurrently
 	* it is safe and okay to not free the entry
 	* if we free the entry in the following put
-	* it it either okay to return !0
+	* it either okay to return !0
 	*/
 fail:
 	spin_lock(&tree->lock);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
