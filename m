Received: by rv-out-0910.google.com with SMTP id l15so1349005rvb
        for <linux-mm@kvack.org>; Mon, 12 Nov 2007 08:56:19 -0800 (PST)
From: Denis Cheng <crquan@gmail.com>
Subject: [PATCH] SLUB: killed the unused "end" variable
Date: Tue, 13 Nov 2007 00:49:42 +0800
Message-Id: <1194886182-2330-1-git-send-email-crquan@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Denis Cheng <crquan@gmail.com>
List-ID: <linux-mm.kvack.org>

Since the macro "for_each_object" introduced, the "end" variable becomes unused anymore.

Signed-off-by: Denis Cheng <crquan@gmail.com>
---
 mm/slub.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 84f59fd..9acb413 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1080,7 +1080,6 @@ static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
 	struct page *page;
 	struct kmem_cache_node *n;
 	void *start;
-	void *end;
 	void *last;
 	void *p;
 
@@ -1101,7 +1100,6 @@ static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
 		SetSlabDebug(page);
 
 	start = page_address(page);
-	end = start + s->objects * s->size;
 
 	if (unlikely(s->flags & SLAB_POISON))
 		memset(start, POISON_INUSE, PAGE_SIZE << s->order);
-- 
1.5.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
