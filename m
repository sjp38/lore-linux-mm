Message-Id: <20070525051947.063860535@sgi.com>
References: <20070525051716.030494061@sgi.com>
Date: Thu, 24 May 2007 22:17:18 -0700
From: clameter@sgi.com
Subject: [patch 2/6] compound pages: Add new support functions
Content-Disposition: inline; filename=compound_functions
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

compound_pages(page)	-> Determines base pages of a compound page

compound_shift(page)	-> Determine the page shift of a compound page

compound_size(page)	-> Determine the size of a compound page

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/mm.h |   15 +++++++++++++++
 1 file changed, 15 insertions(+)

Index: slub/include/linux/mm.h
===================================================================
--- slub.orig/include/linux/mm.h	2007-05-24 20:43:46.000000000 -0700
+++ slub/include/linux/mm.h	2007-05-24 20:50:51.000000000 -0700
@@ -366,6 +366,21 @@ static inline void set_compound_order(st
 	page[1].lru.prev = (void *)order;
 }
 
+static inline int compound_pages(struct page *page)
+{
+ 	return 1 << compound_order(page);
+}
+
+static inline int compound_shift(struct page *page)
+{
+ 	return PAGE_SHIFT + compound_order(page);
+}
+
+static inline int compound_size(struct page *page)
+{
+	return PAGE_SIZE << compound_order(page);
+}
+
 /*
  * Multiple processes may "see" the same page. E.g. for untouched
  * mappings of /dev/null, all processes see the same page full of

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
