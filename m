Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1C3236B0071
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 07:04:07 -0500 (EST)
Date: Thu, 2 Dec 2010 12:03:47 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH] mm: vmscan: Rename lumpy_mode to reclaim_mode fix
Message-ID: <20101202120347.GS13268@csn.ul.ie>
References: <1290440635-30071-1-git-send-email-mel@csn.ul.ie> <1290440635-30071-3-git-send-email-mel@csn.ul.ie> <20101201102732.GK15564@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101201102732.GK15564@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

As suggested by Johannes, rename reclaim_mode to reclaim_mode_t. This is
a fix to the mmotm patch
broken-out/mm-vmscan-rename-lumpy_mode-to-reclaim_mode.patch.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/vmscan.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 42a4859..a9390fd 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -63,12 +63,12 @@
  * RECLAIM_MODE_COMPACTION: For high-order allocations, reclaim a number of
  *			order-0 pages and then compact the zone
  */
-typedef unsigned __bitwise__ reclaim_mode;
-#define RECLAIM_MODE_SINGLE		((__force reclaim_mode)0x01u)
-#define RECLAIM_MODE_ASYNC		((__force reclaim_mode)0x02u)
-#define RECLAIM_MODE_SYNC		((__force reclaim_mode)0x04u)
-#define RECLAIM_MODE_LUMPYRECLAIM	((__force reclaim_mode)0x08u)
-#define RECLAIM_MODE_COMPACTION		((__force reclaim_mode)0x10u)
+typedef unsigned __bitwise__ reclaim_mode_t;
+#define RECLAIM_MODE_SINGLE		((__force reclaim_mode_t)0x01u)
+#define RECLAIM_MODE_ASYNC		((__force reclaim_mode_t)0x02u)
+#define RECLAIM_MODE_SYNC		((__force reclaim_mode_t)0x04u)
+#define RECLAIM_MODE_LUMPYRECLAIM	((__force reclaim_mode_t)0x08u)
+#define RECLAIM_MODE_COMPACTION		((__force reclaim_mode_t)0x10u)
 
 struct scan_control {
 	/* Incremented by the number of inactive pages that were scanned */
@@ -101,7 +101,7 @@ struct scan_control {
 	 * Intend to reclaim enough continuous memory rather than reclaim
 	 * enough amount of memory. i.e, mode for high order allocation.
 	 */
-	reclaim_mode reclaim_mode;
+	reclaim_mode_t reclaim_mode;
 
 	/* Which cgroup do we reclaim from */
 	struct mem_cgroup *mem_cgroup;
@@ -287,7 +287,7 @@ unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
 static void set_reclaim_mode(int priority, struct scan_control *sc,
 				   bool sync)
 {
-	reclaim_mode syncmode = sync ? RECLAIM_MODE_SYNC : RECLAIM_MODE_ASYNC;
+	reclaim_mode_t syncmode = sync ? RECLAIM_MODE_SYNC : RECLAIM_MODE_ASYNC;
 
 	/*
 	 * Initially assume we are entering either lumpy reclaim or

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
