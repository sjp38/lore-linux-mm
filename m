Date: Wed, 13 Feb 2008 23:30:32 +0200
From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] make slub.c:slab_address() static
Message-ID: <20080213213032.GH3383@cs181133002.pp.htv.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com, penberg@cs.helsinki.fi
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

slab_address() can become static.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
fdd710f00d8bed8413c160685bc5229ec15b4d9f diff --git a/mm/slub.c b/mm/slub.c
index e2989ae..af83daf 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -308,7 +308,7 @@ static inline int is_end(void *addr)
 	return (unsigned long)addr & PAGE_MAPPING_ANON;
 }
 
-void *slab_address(struct page *page)
+static void *slab_address(struct page *page)
 {
 	return page->end - PAGE_MAPPING_ANON;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
