Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B80A65F0040
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 09:33:55 -0400 (EDT)
Received: by pxi6 with SMTP id 6so1359427pxi.14
        for <linux-mm@kvack.org>; Thu, 21 Oct 2010 06:33:55 -0700 (PDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH 1/3] page_isolation: codeclean fix comment and rm unneeded val init
Date: Thu, 21 Oct 2010 21:28:19 +0800
Message-Id: <1287667701-8081-1-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, fengguang.wu@intel.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, kosaki.motohiro@jp.fujitsu.com, Bob Liu <lliubbo@gmail.com>
List-ID: <linux-mm.kvack.org>

function __test_page_isolated_in_pageblock() return 1 if all pages
in the range is isolated, so fix the comment.
value pfn will be init in the following loop so rm it.

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/page_isolation.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 5e0ffd9..4ae42bb 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -86,7 +86,7 @@ undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn)
  * all pages in [start_pfn...end_pfn) must be in the same zone.
  * zone->lock must be held before call this.
  *
- * Returns 0 if all pages in the range is isolated.
+ * Returns 1 if all pages in the range is isolated.
  */
 static int
 __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn)
@@ -119,7 +119,6 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn)
 	struct zone *zone;
 	int ret;
 
-	pfn = start_pfn;
 	/*
 	 * Note: pageblock_nr_page != MAX_ORDER. Then, chunks of free page
 	 * is not aligned to pageblock_nr_pages.
-- 
1.5.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
