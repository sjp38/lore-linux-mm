Message-Id: <20071129011147.052277113@sgi.com>
References: <20071129011052.866354847@sgi.com>
Date: Wed, 28 Nov 2007 17:11:04 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 12/19] Use page_cache_xxx in mm/fadvise.c
Content-Disposition: inline; filename=0013-Use-page_cache_xxx-in-mm-fadvise.c.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, David Chinner <dgc@sgi.com>, Jens Axboe <jens.axboe@oracle.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, Fengguang Wu <fengguang.wu@gmail.com>, swin wang <wangswin@gmail.com>, totty.lu@gmail.com, hugh@veritas.com, joern@lazybastard.org
List-ID: <linux-mm.kvack.org>

Use page_cache_xxx in mm/fadvise.c

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 mm/fadvise.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

Index: mm/mm/fadvise.c
===================================================================
--- mm.orig/mm/fadvise.c	2007-11-16 21:16:36.000000000 -0800
+++ mm/mm/fadvise.c	2007-11-28 14:11:06.164977155 -0800
@@ -79,8 +79,8 @@ asmlinkage long sys_fadvise64_64(int fd,
 		}
 
 		/* First and last PARTIAL page! */
-		start_index = offset >> PAGE_CACHE_SHIFT;
-		end_index = endbyte >> PAGE_CACHE_SHIFT;
+		start_index = page_cache_index(mapping, offset);
+		end_index = page_cache_index(mapping, endbyte);
 
 		/* Careful about overflow on the "+1" */
 		nrpages = end_index - start_index + 1;
@@ -100,8 +100,8 @@ asmlinkage long sys_fadvise64_64(int fd,
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
