Message-Id: <20080216004806.176458814@sgi.com>
References: <20080216004718.047808297@sgi.com>
Date: Fri, 15 Feb 2008 16:47:21 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 03/18] Use page_cache_xxx in mm/page-writeback.c
Content-Disposition: inline; filename=0004-Use-page_cache_xxx-in-mm-page-writeback.c.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, David Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

Use page_cache_xxx in mm/page-writeback.c

Reviewed-by: Dave Chinner <dgc@sgi.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 mm/page-writeback.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

Index: mm/mm/page-writeback.c
===================================================================
--- mm.orig/mm/page-writeback.c	2007-11-28 12:27:32.211962401 -0800
+++ mm/mm/page-writeback.c	2007-11-28 14:10:34.338227137 -0800
@@ -818,8 +818,8 @@ int write_cache_pages(struct address_spa
 		index = mapping->writeback_index; /* Start from prev offset */
 		end = -1;
 	} else {
-		index = wbc->range_start >> PAGE_CACHE_SHIFT;
-		end = wbc->range_end >> PAGE_CACHE_SHIFT;
+		index = page_cache_index(mapping, wbc->range_start);
+		end = page_cache_index(mapping, wbc->range_end);
 		if (wbc->range_start == 0 && wbc->range_end == LLONG_MAX)
 			range_whole = 1;
 		scanned = 1;
@@ -1025,7 +1025,7 @@ int __set_page_dirty_nobuffers(struct pa
 				__inc_zone_page_state(page, NR_FILE_DIRTY);
 				__inc_bdi_stat(mapping->backing_dev_info,
 						BDI_RECLAIMABLE);
-				task_io_account_write(PAGE_CACHE_SIZE);
+				task_io_account_write(page_cache_size(mapping));
 			}
 			radix_tree_tag_set(&mapping->page_tree,
 				page_index(page), PAGECACHE_TAG_DIRTY);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
