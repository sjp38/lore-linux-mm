Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 06 of 11] balance_pgdat doesn't return the number of pages
	freed
Message-Id: <4ef302dd29164e19111c.1199326152@v2.random>
In-Reply-To: <patchbomb.1199326146@v2.random>
Date: Thu, 03 Jan 2008 03:09:12 +0100
From: Andrea Arcangeli <andrea@cpushare.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1199324665 -3600
# Node ID 4ef302dd29164e19111c49bb0db2ad4840eace18
# Parent  fc9148f0ddd0ef11be29dba89e3fc96df8f0b9bf
balance_pgdat doesn't return the number of pages freed

nr_reclaimed would be the number of pages freed in the last pass.

Signed-off-by: Andrea Arcangeli <andrea@suse.de>

diff --git a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1298,8 +1298,6 @@ out:
  * For kswapd, balance_pgdat() will work across all this node's zones until
  * they are all at pages_high.
  *
- * Returns the number of pages which were actually freed.
- *
  * There is special handling here for zones which are full of pinned pages.
  * This can happen if the pages are all mlocked, or if they are all used by
  * device drivers (say, ZONE_DMA).  Or if they are all in use by hugetlb.
@@ -1315,7 +1313,7 @@ out:
  * the page allocator fallback scheme to ensure that aging of pages is balanced
  * across the zones.
  */
-static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
+static void balance_pgdat(pg_data_t *pgdat, int order)
 {
 	int all_zones_ok;
 	int priority;
@@ -1475,8 +1473,6 @@ out:
 
 		goto loop_again;
 	}
-
-	return nr_reclaimed;
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
