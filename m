Message-Id: <20080216004808.233942984@sgi.com>
References: <20080216004718.047808297@sgi.com>
Date: Fri, 15 Feb 2008 16:47:30 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 12/18] Use page_cache_xxx in mm/fadvise.c
Content-Disposition: inline; filename=0013-Use-page_cache_xxx-in-mm-fadvise.c.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, David Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

Use page_cache_xxx in mm/fadvise.c

Reviewed-by: Dave Chinner <dgc@sgi.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 mm/fadvise.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

Index: linux-2.6/mm/fadvise.c
===================================================================
--- linux-2.6.orig/mm/fadvise.c	2008-02-14 15:20:25.566017193 -0800
+++ linux-2.6/mm/fadvise.c	2008-02-15 16:15:04.157100371 -0800
@@ -91,8 +91,8 @@ asmlinkage long sys_fadvise64_64(int fd,
 		}
 
 		/* First and last PARTIAL page! */
-		start_index = offset >> PAGE_CACHE_SHIFT;
-		end_index = endbyte >> PAGE_CACHE_SHIFT;
+		start_index = page_cache_index(mapping, offset);
+		end_index = page_cache_index(mapping, endbyte);
 
 		/* Careful about overflow on the "+1" */
 		nrpages = end_index - start_index + 1;
@@ -112,8 +112,8 @@ asmlinkage long sys_fadvise64_64(int fd,
 			filemap_flush(mapping);
 
 		/* First and last FULL page! */
-		start_index = (offset+(PAGE_CACHE_SIZE-1)) >> PAGE_CACHE_SHIFT;
-		end_index = (endbyte >> PAGE_CACHE_SHIFT);
+		start_index = page_cache_next(mapping, offset);
+		end_index = page_cache_index(mapping, endbyte);
 
 		if (end_index >= start_index)
 			invalidate_mapping_pages(mapping, start_index,

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
