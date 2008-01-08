Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 06 of 13] balance_pgdat doesn't return the number of pages
	freed
Message-Id: <dd5900d0aa4e5f1b8136.1199778637@v2.random>
In-Reply-To: <patchbomb.1199778631@v2.random>
Date: Tue, 08 Jan 2008 08:50:37 +0100
From: Andrea Arcangeli <andrea@cpushare.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1199470022 -3600
# Node ID dd5900d0aa4e5f1b81364346465be53db897246f
# Parent  351a3906181f5c0fe0137b6f066f725bd65673ba
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
