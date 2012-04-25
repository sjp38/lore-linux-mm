Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 344AE6B0092
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 02:22:46 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 4/6] zsmalloc: add/fix function comment
Date: Wed, 25 Apr 2012 15:23:12 +0900
Message-Id: <1335334994-22138-5-git-send-email-minchan@kernel.org>
In-Reply-To: <1335334994-22138-1-git-send-email-minchan@kernel.org>
References: <1335334994-22138-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

Add/fix the comment.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/staging/zsmalloc/zsmalloc-main.c |   15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
index 0fe4cbb..b7d31cc 100644
--- a/drivers/staging/zsmalloc/zsmalloc-main.c
+++ b/drivers/staging/zsmalloc/zsmalloc-main.c
@@ -565,12 +565,9 @@ EXPORT_SYMBOL_GPL(zs_destroy_pool);
  * zs_malloc - Allocate block of given size from pool.
  * @pool: pool to allocate from
  * @size: size of block to allocate
- * @page: page no. that holds the object
- * @offset: location of object within page
  *
  * On success, <page, offset> identifies block allocated
- * and 0 is returned. On failure, <page, offset> is set to
- * 0 and -ENOMEM is returned.
+ * and <page, offset> is returned. On failure, NULL is returned.
  *
  * Allocation requests with size > ZS_MAX_ALLOC_SIZE will fail.
  */
@@ -666,6 +663,16 @@ void zs_free(struct zs_pool *pool, void *obj)
 }
 EXPORT_SYMBOL_GPL(zs_free);
 
+/**
+ * zs_map_object - get address of allocated object from handle.
+ * @pool: object allocated pool
+ * @handle: handle returned from zs_malloc
+ *
+ * Before using object allocated from zs_malloc, object
+ * should be mapped to page table by this function.
+ * After using object,  call zs_unmap_object to unmap page
+ * table.
+ */
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
