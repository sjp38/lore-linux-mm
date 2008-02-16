Message-Id: <20080216004807.562690021@sgi.com>
References: <20080216004718.047808297@sgi.com>
Date: Fri, 15 Feb 2008 16:47:27 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 09/18] Use page_cache_xxx in fs/sync
Content-Disposition: inline; filename=0010-Use-page_cache_xxx-in-fs-sync.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, David Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

Use page_cache_xxx in fs/sync.

Reviewed-by: Dave Chinner <dgc@sgi.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 fs/sync.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

Index: linux-2.6/fs/sync.c
===================================================================
--- linux-2.6.orig/fs/sync.c	2008-02-14 15:19:13.645515948 -0800
+++ linux-2.6/fs/sync.c	2008-02-15 16:14:52.000998613 -0800
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
