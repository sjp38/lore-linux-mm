Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 3BEF16B0005
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 17:27:11 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id x65so20517324pfb.1
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 14:27:11 -0800 (PST)
Received: from us-alimail-mta2.hst.scl.en.alidc.net (mail113-249.mail.alibaba.com. [205.204.113.249])
        by mx.google.com with ESMTP id w18si7582387pfi.224.2016.02.24.14.27.08
        for <linux-mm@kvack.org>;
        Wed, 24 Feb 2016 14:27:10 -0800 (PST)
From: chengang@emindsoft.com.cn
Subject: [PATCH trivial] include/linux/gfp.h: Improve the coding styles
Date: Thu, 25 Feb 2016 06:26:31 +0800
Message-Id: <1456352791-2363-1-git-send-email-chengang@emindsoft.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: trivial@kernel.org
Cc: akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, linux-kernel@vger.kernel.org, mhocko@suse.cz, hannes@cmpxchg.org, mgorman@techsingularity.net, vdavydov@virtuozzo.com, dan.j.williams@intel.com, linux-mm@kvack.org, Chen Gang <chengang@emindsoft.com.cn>, Chen Gang <gang.chen.5i5j@gmail.com>

From: Chen Gang <chengang@emindsoft.com.cn>

Always notice about 80 columns, and the white space near '|'.

Let the wrapped function parameters align as the same styles.

Remove redundant statement "enum zone_type z;" in function gfp_zone.

Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
---
 include/linux/gfp.h | 35 ++++++++++++++++++++---------------
 1 file changed, 20 insertions(+), 15 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 36e0c5e..cf904ef 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -53,8 +53,10 @@ struct vm_area_struct;
 #define __GFP_DMA	((__force gfp_t)___GFP_DMA)
 #define __GFP_HIGHMEM	((__force gfp_t)___GFP_HIGHMEM)
 #define __GFP_DMA32	((__force gfp_t)___GFP_DMA32)
-#define __GFP_MOVABLE	((__force gfp_t)___GFP_MOVABLE)  /* ZONE_MOVABLE allowed */
-#define GFP_ZONEMASK	(__GFP_DMA|__GFP_HIGHMEM|__GFP_DMA32|__GFP_MOVABLE)
+#define __GFP_MOVABLE	((__force gfp_t)___GFP_MOVABLE) \
+						/* ZONE_MOVABLE allowed */
+#define GFP_ZONEMASK	(__GFP_DMA | __GFP_HIGHMEM | __GFP_DMA32 | \
+			 __GFP_MOVABLE)
 
 /*
  * Page mobility and placement hints
@@ -151,9 +153,12 @@ struct vm_area_struct;
  */
 #define __GFP_IO	((__force gfp_t)___GFP_IO)
 #define __GFP_FS	((__force gfp_t)___GFP_FS)
-#define __GFP_DIRECT_RECLAIM	((__force gfp_t)___GFP_DIRECT_RECLAIM) /* Caller can reclaim */
-#define __GFP_KSWAPD_RECLAIM	((__force gfp_t)___GFP_KSWAPD_RECLAIM) /* kswapd can wake */
-#define __GFP_RECLAIM ((__force gfp_t)(___GFP_DIRECT_RECLAIM|___GFP_KSWAPD_RECLAIM))
+#define __GFP_DIRECT_RECLAIM ((__force gfp_t)___GFP_DIRECT_RECLAIM) \
+							/* Caller can reclaim */
+#define __GFP_KSWAPD_RECLAIM ((__force gfp_t)___GFP_KSWAPD_RECLAIM) \
+							/* kswapd can wake */
+#define __GFP_RECLAIM	((__force gfp_t)(___GFP_DIRECT_RECLAIM | \
+			 ___GFP_KSWAPD_RECLAIM))
 #define __GFP_REPEAT	((__force gfp_t)___GFP_REPEAT)
 #define __GFP_NOFAIL	((__force gfp_t)___GFP_NOFAIL)
 #define __GFP_NORETRY	((__force gfp_t)___GFP_NORETRY)
@@ -262,7 +267,7 @@ struct vm_area_struct;
 			 ~__GFP_KSWAPD_RECLAIM)
 
 /* Convert GFP flags to their corresponding migrate type */
-#define GFP_MOVABLE_MASK (__GFP_RECLAIMABLE|__GFP_MOVABLE)
+#define GFP_MOVABLE_MASK (__GFP_RECLAIMABLE | __GFP_MOVABLE)
 #define GFP_MOVABLE_SHIFT 3
 
 static inline int gfpflags_to_migratetype(const gfp_t gfp_flags)
@@ -377,11 +382,10 @@ static inline bool gfpflags_allow_blocking(const gfp_t gfp_flags)
 
 static inline enum zone_type gfp_zone(gfp_t flags)
 {
-	enum zone_type z;
 	int bit = (__force int) (flags & GFP_ZONEMASK);
+	enum zone_type z = (GFP_ZONE_TABLE >> (bit * GFP_ZONES_SHIFT)) &
+			    ((1 << GFP_ZONES_SHIFT) - 1);
 
-	z = (GFP_ZONE_TABLE >> (bit * GFP_ZONES_SHIFT)) &
-					 ((1 << GFP_ZONES_SHIFT) - 1);
 	VM_BUG_ON((GFP_ZONE_BAD >> bit) & 1);
 	return z;
 }
@@ -428,8 +432,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 		       struct zonelist *zonelist, nodemask_t *nodemask);
 
 static inline struct page *
-__alloc_pages(gfp_t gfp_mask, unsigned int order,
-		struct zonelist *zonelist)
+__alloc_pages(gfp_t gfp_mask, unsigned int order, struct zonelist *zonelist)
 {
 	return __alloc_pages_nodemask(gfp_mask, order, zonelist, NULL);
 }
@@ -453,7 +456,7 @@ __alloc_pages_node(int nid, gfp_t gfp_mask, unsigned int order)
  * online.
  */
 static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
-						unsigned int order)
+					    unsigned int order)
 {
 	if (nid == NUMA_NO_NODE)
 		nid = numa_mem_id();
@@ -470,8 +473,9 @@ alloc_pages(gfp_t gfp_mask, unsigned int order)
 	return alloc_pages_current(gfp_mask, order);
 }
 extern struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
-			struct vm_area_struct *vma, unsigned long addr,
-			int node, bool hugepage);
+				    struct vm_area_struct *vma,
+				    unsigned long addr, int node,
+				    bool hugepage);
 #define alloc_hugepage_vma(gfp_mask, vma, addr, order)	\
 	alloc_pages_vma(gfp_mask, order, vma, addr, numa_node_id(), true)
 #else
@@ -552,7 +556,8 @@ static inline bool pm_suspended_storage(void)
 }
 #endif /* CONFIG_PM_SLEEP */
 
-#if (defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || defined(CONFIG_CMA)
+#if (defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || \
+     defined(CONFIG_CMA)
 /* The below functions must be run on a range from a single zone. */
 extern int alloc_contig_range(unsigned long start, unsigned long end,
 			      unsigned migratetype);
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
