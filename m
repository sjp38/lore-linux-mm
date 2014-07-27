Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
	by kanga.kvack.org (Postfix) with ESMTP id B33136B0035
	for <linux-mm@kvack.org>; Sun, 27 Jul 2014 16:45:46 -0400 (EDT)
Received: by mail-we0-f172.google.com with SMTP id x48so6588286wes.31
        for <linux-mm@kvack.org>; Sun, 27 Jul 2014 13:45:45 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id gk9si18124343wjd.35.2014.07.27.13.45.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Jul 2014 13:45:39 -0700 (PDT)
Message-ID: <53D564ED.1030906@infradead.org>
Date: Sun, 27 Jul 2014 13:45:33 -0700
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: [PATCH] mm: fix filemap.c pagecache_get_page() kernel-doc warnings
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>

From: Randy Dunlap <rdunlap@infradead.org>

Fix kernel-doc warnings in mm/filemap.c: pagecache_get_page():

Warning(..//mm/filemap.c:1054): No description found for parameter 'cache_gfp_mask'
Warning(..//mm/filemap.c:1054): No description found for parameter 'radix_gfp_mask'
Warning(..//mm/filemap.c:1054): Excess function parameter 'gfp_mask' description in 'pagecache_get_page'

Fixes: 2457aec63745 "mm: non-atomically mark page accessed during
	page cache allocation where possible"

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>
---
 mm/filemap.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

Index: lnx-316-rc7/mm/filemap.c
===================================================================
--- lnx-316-rc7.orig/mm/filemap.c
+++ lnx-316-rc7/mm/filemap.c
@@ -1031,16 +1031,17 @@ EXPORT_SYMBOL(find_lock_entry);
  * @mapping: the address_space to search
  * @offset: the page index
  * @fgp_flags: PCG flags
- * @gfp_mask: gfp mask to use if a page is to be allocated
+ * @cache_gfp_mask: gfp mask to use if a page is to be allocated
+ * @radix_gfp_mask: gfp mask to use for page cache LRU allocation
  *
  * Looks up the page cache slot at @mapping & @offset.
  *
- * PCG flags modify how the page is returned
+ * PCG flags modify how the page is returned.
  *
  * FGP_ACCESSED: the page will be marked accessed
  * FGP_LOCK: Page is return locked
  * FGP_CREAT: If page is not present then a new page is allocated using
- *		@gfp_mask and added to the page cache and the VM's LRU
+ *		@cache_gfp_mask and added to the page cache and the VM's LRU
  *		list. The page is returned locked and with an increased
  *		refcount. Otherwise, %NULL is returned.
  *

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
