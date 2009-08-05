Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id EAF866B009C
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 06:28:09 -0400 (EDT)
Date: Wed, 5 Aug 2009 11:28:17 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH] page-allocator: Remove dead function free_cold_page()
Message-ID: <20090805102817.GE21950@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The function free_cold_page() has no callers so delete it.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
--- 
 include/linux/gfp.h |    1 -
 mm/page_alloc.c     |    5 -----
 2 files changed, 6 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 7c777a0..c32bfa8 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -326,7 +326,6 @@ void free_pages_exact(void *virt, size_t size);
 extern void __free_pages(struct page *page, unsigned int order);
 extern void free_pages(unsigned long addr, unsigned int order);
 extern void free_hot_page(struct page *page);
-extern void free_cold_page(struct page *page);
 
 #define __free_page(page) __free_pages((page), 0)
 #define free_page(addr) free_pages((addr),0)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d052abb..36758db 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1065,11 +1065,6 @@ void free_hot_page(struct page *page)
 	free_hot_cold_page(page, 0);
 }
 	
-void free_cold_page(struct page *page)
-{
-	free_hot_cold_page(page, 1);
-}
-
 /*
  * split_page takes a non-compound higher-order page, and splits it into
  * n (1<<order) sub-pages: page[0..n]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
