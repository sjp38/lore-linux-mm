Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id D19C66B03A2
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 22:02:10 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 14so35971365itw.3
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 19:02:10 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0165.hostedemail.com. [216.40.44.165])
        by mx.google.com with ESMTPS id 135si2032845itg.64.2017.03.15.19.02.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 19:02:10 -0700 (PDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 13/15] mm: page_alloc: Remove unnecessary parentheses
Date: Wed, 15 Mar 2017 19:00:10 -0700
Message-Id: <d56c5e74dd354d5e0dd24b0fa668cff1fb2ed804.1489628477.git.joe@perches.com>
In-Reply-To: <cover.1489628477.git.joe@perches.com>
References: <cover.1489628477.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

Just removing what isn't necessary for human comprehension.

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/page_alloc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b6605b077053..efc3184aa6bc 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1806,7 +1806,7 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 
 	/* Find a page of the appropriate size in the preferred list */
 	for (current_order = order; current_order < MAX_ORDER; ++current_order) {
-		area = &(zone->free_area[current_order]);
+		area = &zone->free_area[current_order];
 		page = list_first_entry_or_null(&area->free_list[migratetype],
 						struct page, lru);
 		if (!page)
@@ -2158,7 +2158,7 @@ static bool unreserve_highatomic_pageblock(const struct alloc_context *ac,
 
 		spin_lock_irqsave(&zone->lock, flags);
 		for (order = 0; order < MAX_ORDER; order++) {
-			struct free_area *area = &(zone->free_area[order]);
+			struct free_area *area = &zone->free_area[order];
 
 			page = list_first_entry_or_null(
 				&area->free_list[MIGRATE_HIGHATOMIC],
@@ -2228,7 +2228,7 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
 	for (current_order = MAX_ORDER - 1;
 	     current_order >= order && current_order <= MAX_ORDER - 1;
 	     --current_order) {
-		area = &(zone->free_area[current_order]);
+		area = &zone->free_area[current_order];
 		fallback_mt = find_suitable_fallback(area, current_order,
 						     start_migratetype, false,
 						     &can_steal);
-- 
2.10.0.rc2.1.g053435c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
