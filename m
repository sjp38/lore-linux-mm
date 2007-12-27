Message-Id: <20071227053401.652878351@sgi.com>
References: <20071227053246.902699851@sgi.com>
Date: Wed, 26 Dec 2007 21:32:55 -0800
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

Index: linux-2.6.24-rc6-mm1/fs/sync.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/fs/sync.c	2007-12-20 17:25:48.000000000 -0800
+++ linux-2.6.24-rc6-mm1/fs/sync.c	2007-12-26 19:51:07.850144128 -0800
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
