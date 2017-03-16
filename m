Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 419586B03B0
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 22:02:23 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id 76so36902769itj.0
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 19:02:23 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0086.hostedemail.com. [216.40.44.86])
        by mx.google.com with ESMTPS id d189si4690828iod.60.2017.03.15.19.02.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 19:02:22 -0700 (PDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 15/15] mm: page_alloc: Move logical continuations to EOL
Date: Wed, 15 Mar 2017 19:00:12 -0700
Message-Id: <e52a03ab25e1ad4cabdbfea09947a0f7ba5e4c48.1489628477.git.joe@perches.com>
In-Reply-To: <cover.1489628477.git.joe@perches.com>
References: <cover.1489628477.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

Just more code style conformance/neatening.

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/page_alloc.c | 20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 930773b03b26..011a8e057639 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -859,9 +859,9 @@ static inline void __free_one_page(struct page *page,
 			buddy = page + (buddy_pfn - pfn);
 			buddy_mt = get_pageblock_migratetype(buddy);
 
-			if (migratetype != buddy_mt
-			    && (is_migrate_isolate(migratetype) ||
-				is_migrate_isolate(buddy_mt)))
+			if (migratetype != buddy_mt &&
+			    (is_migrate_isolate(migratetype) ||
+			     is_migrate_isolate(buddy_mt)))
 				goto done_merging;
 		}
 		max_order++;
@@ -2115,8 +2115,9 @@ static void reserve_highatomic_pageblock(struct page *page, struct zone *zone,
 
 	/* Yoink! */
 	mt = get_pageblock_migratetype(page);
-	if (!is_migrate_highatomic(mt) && !is_migrate_isolate(mt)
-	    && !is_migrate_cma(mt)) {
+	if (!is_migrate_highatomic(mt) &&
+	    !is_migrate_isolate(mt) &&
+	    !is_migrate_cma(mt)) {
 		zone->nr_reserved_highatomic += pageblock_nr_pages;
 		set_pageblock_migratetype(page, MIGRATE_HIGHATOMIC);
 		move_freepages_block(zone, page, MIGRATE_HIGHATOMIC, NULL);
@@ -2682,8 +2683,9 @@ int __isolate_free_page(struct page *page, unsigned int order)
 		for (; page < endpage; page += pageblock_nr_pages) {
 			int mt = get_pageblock_migratetype(page);
 
-			if (!is_migrate_isolate(mt) && !is_migrate_cma(mt)
-			    && !is_migrate_highatomic(mt))
+			if (!is_migrate_isolate(mt) &&
+			    !is_migrate_cma(mt) &&
+			    !is_migrate_highatomic(mt))
 				set_pageblock_migratetype(page,
 							  MIGRATE_MOVABLE);
 		}
@@ -3791,8 +3793,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	 */
 	if (can_direct_reclaim &&
 	    (costly_order ||
-	     (order > 0 && ac->migratetype != MIGRATE_MOVABLE))
-	    && !gfp_pfmemalloc_allowed(gfp_mask)) {
+	     (order > 0 && ac->migratetype != MIGRATE_MOVABLE)) &&
+	    !gfp_pfmemalloc_allowed(gfp_mask)) {
 		page = __alloc_pages_direct_compact(gfp_mask, order,
 						    alloc_flags, ac,
 						    INIT_COMPACT_PRIORITY,
-- 
2.10.0.rc2.1.g053435c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
