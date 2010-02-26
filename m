Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id BC0316B0093
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:09:25 -0500 (EST)
Message-Id: <20100226200859.758176740@redhat.com>
Date: Fri, 26 Feb 2010 21:04:39 +0100
From: aarcange@redhat.com
Subject: [patch 06/35] clear compound mapping
References: <20100226200433.516502198@redhat.com>
Content-Disposition: inline; filename=compound_mapping
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Clear compound mapping for anonymous compound pages like it already happens for
regular anonymous pages.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/page_alloc.c |    2 ++
 1 file changed, 2 insertions(+)

--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -630,6 +630,8 @@ static void __free_pages_ok(struct page 
 	trace_mm_page_free_direct(page, order);
 	kmemcheck_free_shadow(page, order);
 
+	if (PageAnon(page))
+		page->mapping = NULL;
 	for (i = 0 ; i < (1 << order) ; ++i)
 		bad += free_pages_check(page + i);
 	if (bad)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
