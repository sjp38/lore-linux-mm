From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH] buddy: clarify comments describing buddy merge
Date: Thu, 15 May 2008 17:32:01 +0100
Message-Id: <1210869121.0@pinky>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

In __free_one_page(), the comment "Move the buddy up one level" appears
attached to the break and by implication when the break is taken we are
moving it up one level:

	if (!page_is_buddy(page, buddy, order))
		break;          /* Move the buddy up one level. */

In reality the inverse is true, we break out when we can no longer merge
this page with its buddy.  Looking back into pre-history (into the full
git history) it appears that these two lines accidentally got joined as
part of another change.

Move the comment down where it belongs below the if and clarify its
language.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 mm/page_alloc.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1575691..20e4c71 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -459,8 +459,9 @@ static inline void __free_one_page(struct page *page,
 
 		buddy = __page_find_buddy(page, page_idx, order);
 		if (!page_is_buddy(page, buddy, order))
-			break;		/* Move the buddy up one level. */
+			break;
 
+		/* Our buddy is free, merge with it and move up one order. */
 		list_del(&buddy->lru);
 		zone->free_area[order].nr_free--;
 		rmv_page_order(buddy);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
