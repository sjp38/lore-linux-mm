Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 07 of 24] balance_pgdat doesn't return the number of pages
	freed
Message-Id: <b66d8470c04ed836787f.1187786934@v2.random>
In-Reply-To: <patchbomb.1187786927@v2.random>
Date: Wed, 22 Aug 2007 14:48:54 +0200
From: Andrea Arcangeli <andrea@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1187778125 -7200
# Node ID b66d8470c04ed836787f69c7578d5fea4f18c322
# Parent  49e2d90eb0d7b1021b1e1e841bef22fdc647766e
balance_pgdat doesn't return the number of pages freed

nr_reclaimed would be the number of pages freed in the last pass.

Signed-off-by: Andrea Arcangeli <andrea@suse.de>

diff --git a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1198,8 +1198,6 @@ out:
  * For kswapd, balance_pgdat() will work across all this node's zones until
  * they are all at pages_high.
  *
- * Returns the number of pages which were actually freed.
- *
  * There is special handling here for zones which are full of pinned pages.
  * This can happen if the pages are all mlocked, or if they are all used by
  * device drivers (say, ZONE_DMA).  Or if they are all in use by hugetlb.
@@ -1215,7 +1213,7 @@ out:
  * the page allocator fallback scheme to ensure that aging of pages is balanced
  * across the zones.
  */
-static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
+static void balance_pgdat(pg_data_t *pgdat, int order)
 {
 	int all_zones_ok;
 	int priority;
@@ -1366,8 +1364,6 @@ out:
 
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
