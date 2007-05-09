From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070509082848.19219.90950.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070509082748.19219.48015.sendpatchset@skynet.skynet.ie>
References: <20070509082748.19219.48015.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 3/4] Remove unused parameter to allocflags_to_migratetype()
Date: Wed,  9 May 2007 09:28:48 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, clameter@sgi.com, Mel Gorman <mel@csn.ul.ie>, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

The patch dont-group-high-order-atomic-allocations.patch should have removed
the order parameter to allocflags_to_migratetype() but did not. This patch
addresses the problem.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Andy Whitcroft <apw@shadowen.org>
---

 page_alloc.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-mm1-001_m68knommu/mm/page_alloc.c linux-2.6.21-mm1-002_allocflagsorder/mm/page_alloc.c
--- linux-2.6.21-mm1-001_m68knommu/mm/page_alloc.c	2007-05-08 09:24:40.000000000 +0100
+++ linux-2.6.21-mm1-002_allocflagsorder/mm/page_alloc.c	2007-05-08 09:29:42.000000000 +0100
@@ -160,7 +160,7 @@ static void set_pageblock_migratetype(st
 					PB_migrate, PB_migrate_end);
 }
 
-static inline int allocflags_to_migratetype(gfp_t gfp_flags, int order)
+static inline int allocflags_to_migratetype(gfp_t gfp_flags)
 {
 	WARN_ON((gfp_flags & GFP_MOVABLE_MASK) == GFP_MOVABLE_MASK);
 
@@ -1138,7 +1138,7 @@ static struct page *buffered_rmqueue(str
 	struct page *page;
 	int cold = !!(gfp_flags & __GFP_COLD);
 	int cpu;
-	int migratetype = allocflags_to_migratetype(gfp_flags, order);
+	int migratetype = allocflags_to_migratetype(gfp_flags);
 
 again:
 	cpu  = get_cpu();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
