Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 51DFC6B0081
	for <linux-mm@kvack.org>; Thu,  3 May 2012 02:41:08 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 2/4] zsmalloc: add/fix function comment
Date: Thu,  3 May 2012 15:40:40 +0900
Message-Id: <1336027242-372-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1336027242-372-1-git-send-email-minchan@kernel.org>
References: <1336027242-372-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

Add/fix the comment.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/staging/zsmalloc/zsmalloc-main.c |   17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
index 8642800..4496737 100644
--- a/drivers/staging/zsmalloc/zsmalloc-main.c
+++ b/drivers/staging/zsmalloc/zsmalloc-main.c
@@ -566,13 +566,9 @@ EXPORT_SYMBOL_GPL(zs_destroy_pool);
  * zs_malloc - Allocate block of given size from pool.
  * @pool: pool to allocate from
  * @size: size of block to allocate
- * @page: page no. that holds the object
- * @offset: location of object within page
- *
- * On success, <page, offset> identifies block allocated
- * and 0 is returned. On failure, <page, offset> is set to
- * 0 and -ENOMEM is returned.
  *
+ * On success, handle to the allocated object is returned,
+ * otherwise NULL.
  * Allocation requests with size > ZS_MAX_ALLOC_SIZE will fail.
  */
 void *zs_malloc(struct zs_pool *pool, size_t size)
@@ -667,6 +663,15 @@ void zs_free(struct zs_pool *pool, void *obj)
 }
 EXPORT_SYMBOL_GPL(zs_free);
 
+/**
+ * zs_map_object - get address of allocated object from handle.
+ * @pool: pool from which the object was allocated
+ * @handle: handle returned from zs_malloc
+ *
+ * Before using an object allocated from zs_malloc, it must be mapped using
+ * this function. When done with the object, it must be unmapped using
+ * zs_unmap_object
+*/
 void *zs_map_object(struct zs_pool *pool, void *handle)
 {
 	struct page *page;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
