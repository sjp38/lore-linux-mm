Message-Id: <20070925233008.256376051@sgi.com>
References: <20070925232543.036615409@sgi.com>
Date: Tue, 25 Sep 2007 16:25:55 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 12/14] VM: Allow get_page_unless_zero on compound pages
Content-Disposition: inline; filename=0011-slab_defrag_get_page_unless.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Both slab defrag and the large blocksize patches need to ability to take
refcounts on compound pages. May be useful in other places as well.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 include/linux/mm.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

Index: linux-2.6.23-rc8-mm1/include/linux/mm.h
===================================================================
--- linux-2.6.23-rc8-mm1.orig/include/linux/mm.h	2007-09-25 14:53:58.000000000 -0700
+++ linux-2.6.23-rc8-mm1/include/linux/mm.h	2007-09-25 14:56:30.000000000 -0700
@@ -227,7 +227,7 @@ static inline int put_page_testzero(stru
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
