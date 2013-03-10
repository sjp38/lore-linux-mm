Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 970FC6B0005
	for <linux-mm@kvack.org>; Sun, 10 Mar 2013 00:05:24 -0500 (EST)
Received: by mail-oa0-f41.google.com with SMTP id i10so3543895oag.0
        for <linux-mm@kvack.org>; Sat, 09 Mar 2013 21:05:23 -0800 (PST)
MIME-Version: 1.0
Date: Sun, 10 Mar 2013 13:05:23 +0800
Message-ID: <CAJd=RBDPPpqhHh3CJAwkC4J=tukDLErwf6juS+x3irvu3PHdbA@mail.gmail.com>
Subject: [PATCH] vmscan: minor cleanup for kswapd
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Hillf Danton <dhillf@gmail.com>

The local variable, total_scanned, is no longer used, so clean up now.

Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/vmscan.c	Thu Feb 21 20:01:02 2013
+++ b/mm/vmscan.c	Sun Mar 10 12:52:10 2013
@@ -2619,7 +2619,6 @@ static unsigned long balance_pgdat(pg_da
 	bool pgdat_is_balanced = false;
 	int i;
 	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
-	unsigned long total_scanned;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long nr_soft_reclaimed;
 	unsigned long nr_soft_scanned;
@@ -2639,7 +2638,6 @@ static unsigned long balance_pgdat(pg_da
 		.gfp_mask = sc.gfp_mask,
 	};
 loop_again:
-	total_scanned = 0;
 	sc.priority = DEF_PRIORITY;
 	sc.nr_reclaimed = 0;
 	sc.may_writepage = !laptop_mode;
@@ -2730,7 +2728,6 @@ loop_again:
 							order, sc.gfp_mask,
 							&nr_soft_scanned);
 			sc.nr_reclaimed += nr_soft_reclaimed;
-			total_scanned += nr_soft_scanned;

 			/*
 			 * We put equal pressure on every zone, unless
@@ -2765,7 +2762,6 @@ loop_again:
 				reclaim_state->reclaimed_slab = 0;
 				nr_slab = shrink_slab(&shrink, sc.nr_scanned, lru_pages);
 				sc.nr_reclaimed += reclaim_state->reclaimed_slab;
-				total_scanned += sc.nr_scanned;

 				if (nr_slab == 0 && !zone_reclaimable(zone))
 					zone->all_unreclaimable = 1;
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
