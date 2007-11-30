Message-Id: <20071130173508.211440205@sgi.com>
References: <20071130173448.951783014@sgi.com>
Date: Fri, 30 Nov 2007 09:34:57 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 09/19] Use page_cache_xxx in fs/sync
Content-Disposition: inline; filename=0010-Use-page_cache_xxx-in-fs-sync.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, David Chinner <dgc@sgi.com>, Jens Axboe <jens.axboe@oracle.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, Fengguang Wu <fengguang.wu@gmail.com>, swin wang <wangswin@gmail.com>, totty.lu@gmail.com, hugh@veritas.com, joern@lazybastard.org
List-ID: <linux-mm.kvack.org>

Use page_cache_xxx in fs/sync.

Reviewed-by: Dave Chinner <dgc@sgi.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 fs/sync.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

Index: mm/fs/sync.c
===================================================================
--- mm.orig/fs/sync.c	2007-11-16 21:16:36.000000000 -0800
+++ mm/fs/sync.c	2007-11-28 14:10:56.269227507 -0800
@@ -260,8 +260,8 @@ int do_sync_mapping_range(struct address
 	ret = 0;
 	if (flags & SYNC_FILE_RANGE_WAIT_BEFORE) {
 		ret = wait_on_page_writeback_range(mapping,
-					offset >> PAGE_CACHE_SHIFT,
-					endbyte >> PAGE_CACHE_SHIFT);
+					page_cache_index(mapping, offset),
+					page_cache_index(mapping, endbyte));
 		if (ret < 0)
 			goto out;
 	}
@@ -275,8 +275,8 @@ int do_sync_mapping_range(struct address
 
 	if (flags & SYNC_FILE_RANGE_WAIT_AFTER) {
 		ret = wait_on_page_writeback_range(mapping,
-					offset >> PAGE_CACHE_SHIFT,
-					endbyte >> PAGE_CACHE_SHIFT);
+					page_cache_index(mapping, offset),
+					page_cache_index(mapping, endbyte));
 	}
 out:
 	return ret;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
