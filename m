Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E58516B0005
	for <linux-mm@kvack.org>; Sun, 28 Jan 2018 23:01:14 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id q8so5299883pfh.12
        for <linux-mm@kvack.org>; Sun, 28 Jan 2018 20:01:14 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id i1si185061pgf.539.2018.01.28.20.01.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 28 Jan 2018 20:01:13 -0800 (PST)
From: Randy Dunlap <rdunlap@infradead.org>
Subject: [PATCH] mm/swap.c: fix kernel-doc functions and parameters
Message-ID: <bac38b63-5b67-b2b7-8fe9-ff9c36f59ded@infradead.org>
Date: Sun, 28 Jan 2018 20:01:08 -0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>

From: Randy Dunlap <rdunlap@infradead.org>

Fix some basic kernel-doc notation in mm/swap.c:
- make function names in kernel-doc notation match the functions
- make function parameter names in kernel-doc match the actual parameters

Fix function kernel-doc to match the change in commit 67fd707f4681:
- drop the kernel-doc notation for @nr_pages from pagevec_lookup_range()
  and correct the function description for that change

Fixes 67fd707f4681:
    ("mm: remove nr_pages argument from pagevec_lookup_{,range}_tag()")

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
Cc: Jan Kara <jack@suse.cz>
---
 mm/swap.c |   17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

--- lnx-415.orig/mm/swap.c
+++ lnx-415/mm/swap.c
@@ -400,6 +400,10 @@ void mark_page_accessed(struct page *pag
 }
 EXPORT_SYMBOL(mark_page_accessed);
 
+/**
+ * __lru_cache_add: add a page to the page lists
+ * @page: the page to add
+ */
 static void __lru_cache_add(struct page *page)
 {
 	struct pagevec *pvec = &get_cpu_var(lru_add_pvec);
@@ -410,10 +414,6 @@ static void __lru_cache_add(struct page
 	put_cpu_var(lru_add_pvec);
 }
 
-/**
- * lru_cache_add: add a page to the page lists
- * @page: the page to add
- */
 void lru_cache_add_anon(struct page *page)
 {
 	if (PageActive(page))
@@ -913,11 +913,11 @@ EXPORT_SYMBOL(__pagevec_lru_add);
  * @pvec:	Where the resulting entries are placed
  * @mapping:	The address_space to search
  * @start:	The starting entry index
- * @nr_entries:	The maximum number of entries
+ * @nr_pages:	The maximum number of entries
  * @indices:	The cache indices corresponding to the entries in @pvec
  *
  * pagevec_lookup_entries() will search for and return a group of up
- * to @nr_entries pages and shadow entries in the mapping.  All
+ * to @nr_pages pages and shadow entries in the mapping.  All
  * entries are placed in @pvec.  pagevec_lookup_entries() takes a
  * reference against actual pages in @pvec.
  *
@@ -965,9 +965,8 @@ void pagevec_remove_exceptionals(struct
  * @mapping:	The address_space to search
  * @start:	The starting page index
  * @end:	The final page index
- * @nr_pages:	The maximum number of pages
  *
- * pagevec_lookup_range() will search for and return a group of up to @nr_pages
+ * pagevec_lookup_range() will search for & return a group of up to PAGEVEC_SIZE
  * pages in the mapping starting from index @start and upto index @end
  * (inclusive).  The pages are placed in @pvec.  pagevec_lookup() takes a
  * reference against the pages in @pvec.
@@ -977,7 +976,7 @@ void pagevec_remove_exceptionals(struct
  * also update @start to index the next page for the traversal.
  *
  * pagevec_lookup_range() returns the number of pages which were found. If this
- * number is smaller than @nr_pages, the end of specified range has been
+ * number is smaller than PAGEVEC_SIZE, the end of specified range has been
  * reached.
  */
 unsigned pagevec_lookup_range(struct pagevec *pvec,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
