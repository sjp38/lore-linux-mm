Message-Id: <20070525051947.764986146@sgi.com>
References: <20070525051716.030494061@sgi.com>
Date: Thu, 24 May 2007 22:17:21 -0700
From: clameter@sgi.com
Subject: [patch 5/6] compound pages: Allow use of get_page_unless_zero with compound pages
Content-Disposition: inline; filename=compound_get_one_unless
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

This will be needed by targeted slab reclaim in order to ensure that a
compound page allocated by SLUB will not go away under us.

It also may be needed if Mel starts to implement defragmentation. The
moving of compound pages may require the establishment of a reference
before the use of page migration functions.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/mm.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: slub/include/linux/mm.h
===================================================================
--- slub.orig/include/linux/mm.h	2007-05-24 21:16:14.000000000 -0700
+++ slub/include/linux/mm.h	2007-05-24 21:16:45.000000000 -0700
@@ -293,7 +293,7 @@ static inline int put_page_testzero(stru
  */
 static inline int get_page_unless_zero(struct page *page)
 {
-	VM_BUG_ON(PageCompound(page));
+	VM_BUG_ON(PageTail(page));
 	return atomic_inc_not_zero(&page->_count);
 }
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
