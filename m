Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 5A6916B0035
	for <linux-mm@kvack.org>; Thu,  7 Mar 2013 03:21:27 -0500 (EST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH] mm: page_alloc: remove branch operation in free_pages_prepare()
Date: Thu,  7 Mar 2013 17:21:20 +0900
Message-Id: <1362644480-18381-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hugh Dickins <hughd@google.com>

When we found that the flag has a bit of PAGE_FLAGS_CHECK_AT_PREP,
we reset the flag. If we always reset the flag, we can reduce one
branch operation. So remove it.

Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8fcced7..778f2a9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -614,8 +614,7 @@ static inline int free_pages_check(struct page *page)
 		return 1;
 	}
 	page_nid_reset_last(page);
-	if (page->flags & PAGE_FLAGS_CHECK_AT_PREP)
-		page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
+	page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
 	return 0;
 }
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
