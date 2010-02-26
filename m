Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id BBF566B007E
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:09:25 -0500 (EST)
Message-Id: <20100226200859.556477382@redhat.com>
Date: Fri, 26 Feb 2010 21:04:38 +0100
From: aarcange@redhat.com
Subject: [patch 05/35] fix bad_page to show the real reason the page is bad
References: <20100226200433.516502198@redhat.com>
Content-Disposition: inline; filename=compound_bad_page
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

page_count shows the count of the head page, but the actual check is done on
the tail page, so show what is really being checked.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/page_alloc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5218,7 +5218,7 @@ void dump_page(struct page *page)
 {
 	printk(KERN_ALERT
 	       "page:%p count:%d mapcount:%d mapping:%p index:%#lx\n",
-		page, page_count(page), page_mapcount(page),
+		page, atomic_read(&page->_count), page_mapcount(page),
 		page->mapping, page->index);
 	dump_page_flags(page->flags);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
