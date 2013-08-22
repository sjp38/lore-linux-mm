Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id F282E6B0034
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 03:23:29 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so1425331pbb.33
        for <linux-mm@kvack.org>; Thu, 22 Aug 2013 00:23:29 -0700 (PDT)
Message-ID: <5215BC63.6060004@gmail.com>
Date: Thu, 22 Aug 2013 15:23:15 +0800
From: Wang Sheng-Hui <shhuiw@gmail.com>
MIME-Version: 1.0
Subject: [PATCH] mm: correct the comment about the value for buddy _mapcount
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org


Set _mapcount PAGE_BUDDY_MAPCOUNT_VALUE to make the page buddy.
Not the magic number -2.

Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
---
 mm/page_alloc.c |   11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b100255..345f57b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -488,8 +488,10 @@ __find_buddy_index(unsigned long page_idx, unsigned int order)
  * (c) a page and its buddy have the same order &&
  * (d) a page and its buddy are in the same zone.
  *
- * For recording whether a page is in the buddy system, we set ->_mapcount -2.
- * Setting, clearing, and testing _mapcount -2 is serialized by zone->lock.
+ * For recording whether a page is in the buddy system, we set ->_mapcount
+ * PAGE_BUDDY_MAPCOUNT_VALUE.
+ * Setting, clearing, and testing _mapcount PAGE_BUDDY_MAPCOUNT_VALUE is
+ * serialized by zone->lock.
  *
  * For recording page's order, we use page_private(page).
  */
@@ -527,8 +529,9 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
  * as necessary, plus some accounting needed to play nicely with other
  * parts of the VM system.
  * At each level, we keep a list of pages, which are heads of continuous
- * free pages of length of (1 << order) and marked with _mapcount -2. Page's
- * order is recorded in page_private(page) field.
+ * free pages of length of (1 << order) and marked with _mapcount
+ * PAGE_BUDDY_MAPCOUNT_VALUE. Page's order is recorded in page_private(page)
+ * field.
  * So when we are allocating or freeing one, we can derive the state of the
  * other.  That is, if we allocate a small block, and both were
  * free, the remainder of the region must be split into blocks.
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
