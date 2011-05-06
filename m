Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2B6466B0022
	for <linux-mm@kvack.org>; Fri,  6 May 2011 11:02:11 -0400 (EDT)
Received: by pvc12 with SMTP id 12so2007467pvc.14
        for <linux-mm@kvack.org>; Fri, 06 May 2011 08:02:01 -0700 (PDT)
Subject: [PATCH]mm/page_alloc.c: no need del from lru
From: "Figo.zhang" <figo1802@gmail.com>
Date: Fri, 06 May 2011 23:01:21 +0800
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Message-ID: <1304694099.2450.3.camel@figo-desktop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, mel@csn.ul.ie
Cc: kamezawa.hiroyu@jp.fujisu.com, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@osdl.org>, aarcange@redhat.com


split_free_page() the page is still free page, it is no need del from lru.

Signed-off-by: Figo.zhang <figo1802@gmail.com>
---
mm/page_alloc.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9f8a97b..55d8810 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1261,7 +1261,6 @@ int split_free_page(struct page *page)
 		return 0;
 
 	/* Remove page from free list */
-	list_del(&page->lru);
 	zone->free_area[order].nr_free--;
 	rmv_page_order(page);
 	__mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order));


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
