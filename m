Message-Id: <200510300116.j9U1GJVf006402@shell0.pdx.osdl.net>
Subject: [patch 07/86] mm: set per-cpu-pages lower threshold to zero
From: akpm@osdl.org
Date: Sat, 29 Oct 2005 18:15:48 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: akpm@osdl.org, rohit.seth@intel.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Seth, Rohit" <rohit.seth@intel.com>

Set the low water mark for hot pages in pcp to zero.

(akpm: for the life of me I cannot remember why we created pcp->low.  Neither
can Martin and the changelog is silent.  Maybe it was just a brainfart, but I
have this feeling that there was a reason.  If not, we should remove the
fields completely.  We'll see.)

Signed-off-by: Rohit Seth <rohit.seth@intel.com>
Cc: <linux-mm@kvack.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 mm/page_alloc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff -puN mm/page_alloc.c~mm-set-per-cpu-pages-lower-threshold-to-zero mm/page_alloc.c
--- devel/mm/page_alloc.c~mm-set-per-cpu-pages-lower-threshold-to-zero	2005-10-29 17:37:00.000000000 -0700
+++ devel-akpm/mm/page_alloc.c	2005-10-29 18:15:18.000000000 -0700
@@ -1755,7 +1755,7 @@ inline void setup_pageset(struct per_cpu
 
 	pcp = &p->pcp[0];		/* hot */
 	pcp->count = 0;
-	pcp->low = 2 * batch;
+	pcp->low = 0;
 	pcp->high = 6 * batch;
 	pcp->batch = max(1UL, 1 * batch);
 	INIT_LIST_HEAD(&pcp->list);
@@ -1764,7 +1764,7 @@ inline void setup_pageset(struct per_cpu
 	pcp->count = 0;
 	pcp->low = 0;
 	pcp->high = 2 * batch;
-	pcp->batch = max(1UL, 1 * batch);
+	pcp->batch = max(1UL, batch/2);
 	INIT_LIST_HEAD(&pcp->list);
 }
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
