Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8E8416B03A1
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 22:00:54 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id r141so36079479ita.6
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 19:00:54 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0091.hostedemail.com. [216.40.44.91])
        by mx.google.com with ESMTPS id a203si2040622itg.7.2017.03.15.19.00.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 19:00:53 -0700 (PDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 03/15] mm: page_alloc: fix brace positions
Date: Wed, 15 Mar 2017 19:00:00 -0700
Message-Id: <0e794a8437089639f698639e5ef7da6f3552e6c3.1489628477.git.joe@perches.com>
In-Reply-To: <cover.1489628477.git.joe@perches.com>
References: <cover.1489628477.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

Remove a few blank lines.

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/page_alloc.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 79fc996892c6..1029a1dd59d9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1375,7 +1375,6 @@ void set_zone_contiguous(struct zone *zone)
 	for (; block_start_pfn < zone_end_pfn(zone);
 	     block_start_pfn = block_end_pfn,
 		     block_end_pfn += pageblock_nr_pages) {
-
 		block_end_pfn = min(block_end_pfn, zone_end_pfn(zone));
 
 		if (!__pageblock_pfn_to_page(block_start_pfn,
@@ -4864,7 +4863,6 @@ static int find_next_best_node(int node, nodemask_t *used_node_mask)
 	}
 
 	for_each_node_state(n, N_MEMORY) {
-
 		/* Don't want a node to appear more than once */
 		if (node_isset(n, *used_node_mask))
 			continue;
@@ -6437,7 +6435,6 @@ static void __init find_zone_movable_pfns_for_nodes(void)
 
 				/* Continue if range is now fully accounted */
 				if (end_pfn <= usable_startpfn) {
-
 					/*
 					 * Push zone_movable_pfn to the end so
 					 * that if we have to rebalance
@@ -6767,7 +6764,6 @@ void __init free_area_init(unsigned long *zones_size)
 
 static int page_alloc_cpu_dead(unsigned int cpu)
 {
-
 	lru_add_drain_cpu(cpu);
 	drain_pages(cpu);
 
@@ -6811,7 +6807,6 @@ static void calculate_totalreserve_pages(void)
 	enum zone_type i, j;
 
 	for_each_online_pgdat(pgdat) {
-
 		pgdat->totalreserve_pages = 0;
 
 		for (i = 0; i < MAX_NR_ZONES; i++) {
-- 
2.10.0.rc2.1.g053435c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
