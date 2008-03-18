Date: Tue, 18 Mar 2008 15:33:06 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] mm/readhead: fix kernel-doc notation
Message-Id: <20080318153306.966f9ea5.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Randy Dunlap <randy.dunlap@oracle.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Fix kernel-doc notation in mm/readahead.c.

Change ":" to ";" so that it doesn't get treated as a doc section heading.
Move the comment block ending "*/" to a line by itself so that the
text on that last line is not lost (dropped).

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 mm/readahead.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

--- mmotm-2008-0314-1449.orig/mm/readahead.c
+++ mmotm-2008-0314-1449/mm/readahead.c
@@ -449,9 +449,10 @@ EXPORT_SYMBOL_GPL(page_cache_sync_readah
  *            pagecache pages
  *
  * page_cache_async_ondemand() should be called when a page is used which
- * has the PG_readahead flag: this is a marker to suggest that the application
+ * has the PG_readahead flag; this is a marker to suggest that the application
  * has used up enough of the readahead window that we should start pulling in
- * more pages. */
+ * more pages.
+ */
 void
 page_cache_async_readahead(struct address_space *mapping,
 			   struct file_ra_state *ra, struct file *filp,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
