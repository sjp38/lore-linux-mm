Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B41C26B02F3
	for <linux-mm@kvack.org>; Tue, 30 May 2017 14:17:42 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w79so20641533wme.7
        for <linux-mm@kvack.org>; Tue, 30 May 2017 11:17:42 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id q7si14289157eda.82.2017.05.30.11.17.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 30 May 2017 11:17:41 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 1/6] mm: vmscan: delete unused pgdat_reclaimable_pages()
Date: Tue, 30 May 2017 14:17:19 -0400
Message-Id: <20170530181724.27197-2-hannes@cmpxchg.org>
In-Reply-To: <20170530181724.27197-1-hannes@cmpxchg.org>
References: <20170530181724.27197-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/swap.h |  1 -
 mm/vmscan.c          | 16 ----------------
 2 files changed, 17 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index ba5882419a7d..6e3d1d0a7f48 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -289,7 +289,6 @@ extern void lru_cache_add_active_or_unevictable(struct page *page,
 
 /* linux/mm/vmscan.c */
 extern unsigned long zone_reclaimable_pages(struct zone *zone);
-extern unsigned long pgdat_reclaimable_pages(struct pglist_data *pgdat);
 extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 					gfp_t gfp_mask, nodemask_t *mask);
 extern int __isolate_lru_page(struct page *page, isolate_mode_t mode);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8ad39bbc79e6..c5f9d1673392 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -219,22 +219,6 @@ unsigned long zone_reclaimable_pages(struct zone *zone)
 	return nr;
 }
 
-unsigned long pgdat_reclaimable_pages(struct pglist_data *pgdat)
-{
-	unsigned long nr;
-
-	nr = node_page_state_snapshot(pgdat, NR_ACTIVE_FILE) +
-	     node_page_state_snapshot(pgdat, NR_INACTIVE_FILE) +
-	     node_page_state_snapshot(pgdat, NR_ISOLATED_FILE);
-
-	if (get_nr_swap_pages() > 0)
-		nr += node_page_state_snapshot(pgdat, NR_ACTIVE_ANON) +
-		      node_page_state_snapshot(pgdat, NR_INACTIVE_ANON) +
-		      node_page_state_snapshot(pgdat, NR_ISOLATED_ANON);
-
-	return nr;
-}
-
 /**
  * lruvec_lru_size -  Returns the number of pages on the given LRU list.
  * @lruvec: lru vector
-- 
2.12.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
