Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8E6529000BD
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 04:58:54 -0400 (EDT)
Received: from epcpsbgm1.samsung.com (mailout3.samsung.com [203.254.224.33])
 by mailout3.samsung.com
 (Oracle Communications Messaging Exchange Server 7u4-19.01 64bit (built Sep  7
 2010)) with ESMTP id <0LRV00N677LD50I0@mailout3.samsung.com> for
 linux-mm@kvack.org; Wed, 21 Sep 2011 17:58:52 +0900 (KST)
Received: from TNRNDGASPAPP1.tn.corp.samsungelectronics.net ([165.213.149.150])
 by mmp1.samsung.com
 (Oracle Communications Messaging Exchange Server 7u4-19.01 64bit (built Sep  7
 2010)) with ESMTPA id <0LRV00AAF7M4RJ40@mmp1.samsung.com> for
 linux-mm@kvack.org; Wed, 21 Sep 2011 17:58:52 +0900 (KST)
Date: Wed, 21 Sep 2011 17:58:43 +0900
From: Kyungmin Park <kmpark@infradead.org>
Subject: [PATCH] mm: compaction: staticize compact_zone_order
Message-id: <20110921085843.GA16233@july>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Kyungmin Park <kyungmin.park@samsung.com>

There's no user to use compact_zone_order. So staticize this function.

Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index cc9f7a4..bb2bbdb 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -24,8 +24,6 @@ extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *mask,
 			bool sync);
 extern unsigned long compaction_suitable(struct zone *zone, int order);
-extern unsigned long compact_zone_order(struct zone *zone, int order,
-					gfp_t gfp_mask, bool sync);
 
 /* Do not skip compaction more than 64 times */
 #define COMPACT_MAX_DEFER_SHIFT 6
@@ -69,12 +67,6 @@ static inline unsigned long compaction_suitable(struct zone *zone, int order)
 	return COMPACT_SKIPPED;
 }
 
-static inline unsigned long compact_zone_order(struct zone *zone, int order,
-					       gfp_t gfp_mask, bool sync)
-{
-	return COMPACT_CONTINUE;
-}
-
 static inline void defer_compaction(struct zone *zone)
 {
 }
diff --git a/mm/compaction.c b/mm/compaction.c
index 6cc604b..c17079e 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -586,7 +586,7 @@ out:
 	return ret;
 }
 
-unsigned long compact_zone_order(struct zone *zone,
+static unsigned long compact_zone_order(struct zone *zone,
 				 int order, gfp_t gfp_mask,
 				 bool sync)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
