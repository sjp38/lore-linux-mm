Message-Id: <200509120723.j8C7NhYe011583@shell0.pdx.osdl.net>
Subject: mm-set-per-cpu-pages-lower-threshold-to-zero.patch added to -mm tree
From: akpm@osdl.org
Date: Mon, 12 Sep 2005 00:23:17 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: rohit.seth@intel.com, linux-mm@kvack.org, mm-commits@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The patch titled

     mm: set per-cpu-pages lower threshold to zero

has been added to the -mm tree.  Its filename is

     mm-set-per-cpu-pages-lower-threshold-to-zero.patch


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
--- devel/mm/page_alloc.c~mm-set-per-cpu-pages-lower-threshold-to-zero	2005-09-12 00:21:31.000000000 -0700
+++ devel-akpm/mm/page_alloc.c	2005-09-12 00:21:31.000000000 -0700
@@ -1772,7 +1772,7 @@ inline void setup_pageset(struct per_cpu
 
 	pcp = &p->pcp[0];		/* hot */
 	pcp->count = 0;
-	pcp->low = 2 * batch;
+	pcp->low = 0;
 	pcp->high = 6 * batch;
 	pcp->batch = max(1UL, 1 * batch);
 	INIT_LIST_HEAD(&pcp->list);
@@ -1781,7 +1781,7 @@ inline void setup_pageset(struct per_cpu
 	pcp->count = 0;
 	pcp->low = 0;
 	pcp->high = 2 * batch;
-	pcp->batch = max(1UL, 1 * batch);
+	pcp->batch = max(1UL, batch/2);
 	INIT_LIST_HEAD(&pcp->list);
 }
 
_

Patches currently in -mm which might be from rohit.seth@intel.com are

mm-try-to-allocate-higher-order-pages-in-rmqueue_bulk.patch
mm-try-to-allocate-higher-order-pages-in-rmqueue_bulk-fix.patch
mm-page_alloc-increase-size-of-per-cpu-pages.patch
mm-set-per-cpu-pages-lower-threshold-to-zero.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
