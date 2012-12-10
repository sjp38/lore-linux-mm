Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 06F506B005D
	for <linux-mm@kvack.org>; Sun,  9 Dec 2012 21:47:00 -0500 (EST)
Date: Mon, 10 Dec 2012 10:46:56 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH][RESEND] vmscan: comment too_many_isolated()
Message-ID: <20121210024656.GA15780@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>

Comment "Why it's doing so" rather than "What it does"
as proposed by Andrew Morton.

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/vmscan.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

--- linux-next.orig/mm/vmscan.c	2012-12-10 10:42:58.674928674 +0800
+++ linux-next/mm/vmscan.c	2012-12-10 10:43:06.474928860 +0800
@@ -1177,7 +1177,11 @@ int isolate_lru_page(struct page *page)
 }
 
 /*
- * Are there way too many processes in the direct reclaim path already?
+ * A direct reclaimer may isolate SWAP_CLUSTER_MAX pages from the LRU list and
+ * then get resheduled. When there are massive number of tasks doing page
+ * allocation, such sleeping direct reclaimers may keep piling up on each CPU,
+ * the LRU list will go small and be scanned faster than necessary, leading to
+ * unnecessary swapping, thrashing and OOM.
  */
 static int too_many_isolated(struct zone *zone, int file,
 		struct scan_control *sc)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
