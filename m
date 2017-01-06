Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id E49176B025E
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 23:13:11 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id n204so49604112oif.6
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 20:13:11 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTP id c64si33857147oia.71.2017.01.05.20.13.09
        for <linux-mm@kvack.org>;
        Thu, 05 Jan 2017 20:13:11 -0800 (PST)
Message-ID: <586F1823.4050107@huawei.com>
Date: Fri, 6 Jan 2017 12:08:03 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mm: fix some typos in mm/zsmalloc.c
References: <58646FB7.2040502@huawei.com> <5864C12F.60709@huawei.com>
In-Reply-To: <5864C12F.60709@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Delete extra semicolon, and fix some typos.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 mm/zsmalloc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 9cc3c0b..a1f2498 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -25,7 +25,7 @@
  * Usage of struct page flags:
  *	PG_private: identifies the first component page
  *	PG_private2: identifies the last component page
- *	PG_owner_priv_1: indentifies the huge component page
+ *	PG_owner_priv_1: identifies the huge component page
  *
  */
 
@@ -364,7 +364,7 @@ static struct zspage *cache_alloc_zspage(struct zs_pool *pool, gfp_t flags)
 {
 	return kmem_cache_alloc(pool->zspage_cachep,
 			flags & ~(__GFP_HIGHMEM|__GFP_MOVABLE));
-};
+}
 
 static void cache_free_zspage(struct zs_pool *pool, struct zspage *zspage)
 {
@@ -2383,7 +2383,7 @@ struct zs_pool *zs_create_pool(const char *name)
 		goto err;
 
 	/*
-	 * Iterate reversly, because, size of size_class that we want to use
+	 * Iterate reversely, because, size of size_class that we want to use
 	 * for merging should be larger or equal to current size.
 	 */
 	for (i = zs_size_classes - 1; i >= 0; i--) {
-- 
1.8.3.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
