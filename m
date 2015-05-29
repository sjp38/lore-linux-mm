Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id F33166B009A
	for <linux-mm@kvack.org>; Fri, 29 May 2015 11:09:58 -0400 (EDT)
Received: by igbjd9 with SMTP id jd9so16549165igb.1
        for <linux-mm@kvack.org>; Fri, 29 May 2015 08:09:58 -0700 (PDT)
Received: from mail-ie0-x233.google.com (mail-ie0-x233.google.com. [2607:f8b0:4001:c03::233])
        by mx.google.com with ESMTPS id mp20si4408288icb.12.2015.05.29.08.09.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 May 2015 08:09:58 -0700 (PDT)
Received: by iesa3 with SMTP id a3so65105794ies.2
        for <linux-mm@kvack.org>; Fri, 29 May 2015 08:09:58 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH] zpool: add EXPORT_SYMBOL for functions
Date: Fri, 29 May 2015 11:09:32 -0400
Message-Id: <1432912172-16591-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Ganesh Mahendran <opensource.ganesh@gmail.com>, Kees Cook <keescook@chromium.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Streetman <ddstreet@ieee.org>

Export the zpool functions that should be exported.

Signed-off-by: Dan Streetman <ddstreet@ieee.org>
---
 mm/zpool.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/mm/zpool.c b/mm/zpool.c
index 6b1f103..884659d 100644
--- a/mm/zpool.c
+++ b/mm/zpool.c
@@ -188,6 +188,7 @@ struct zpool *zpool_create_pool(char *type, char *name, gfp_t gfp,
 
 	return zpool;
 }
+EXPORT_SYMBOL(zpool_create_pool);
 
 /**
  * zpool_destroy_pool() - Destroy a zpool
@@ -211,6 +212,7 @@ void zpool_destroy_pool(struct zpool *zpool)
 	zpool_put_driver(zpool->driver);
 	kfree(zpool);
 }
+EXPORT_SYMBOL(zpool_destroy_pool);
 
 /**
  * zpool_get_type() - Get the type of the zpool
@@ -226,6 +228,7 @@ char *zpool_get_type(struct zpool *zpool)
 {
 	return zpool->type;
 }
+EXPORT_SYMBOL(zpool_get_type);
 
 /**
  * zpool_malloc() - Allocate memory
@@ -248,6 +251,7 @@ int zpool_malloc(struct zpool *zpool, size_t size, gfp_t gfp,
 {
 	return zpool->driver->malloc(zpool->pool, size, gfp, handle);
 }
+EXPORT_SYMBOL(zpool_malloc);
 
 /**
  * zpool_free() - Free previously allocated memory
@@ -267,6 +271,7 @@ void zpool_free(struct zpool *zpool, unsigned long handle)
 {
 	zpool->driver->free(zpool->pool, handle);
 }
+EXPORT_SYMBOL(zpool_free);
 
 /**
  * zpool_shrink() - Shrink the pool size
@@ -290,6 +295,7 @@ int zpool_shrink(struct zpool *zpool, unsigned int pages,
 {
 	return zpool->driver->shrink(zpool->pool, pages, reclaimed);
 }
+EXPORT_SYMBOL(zpool_shrink);
 
 /**
  * zpool_map_handle() - Map a previously allocated handle into memory
@@ -318,6 +324,7 @@ void *zpool_map_handle(struct zpool *zpool, unsigned long handle,
 {
 	return zpool->driver->map(zpool->pool, handle, mapmode);
 }
+EXPORT_SYMBOL(zpool_map_handle);
 
 /**
  * zpool_unmap_handle() - Unmap a previously mapped handle
@@ -333,6 +340,7 @@ void zpool_unmap_handle(struct zpool *zpool, unsigned long handle)
 {
 	zpool->driver->unmap(zpool->pool, handle);
 }
+EXPORT_SYMBOL(zpool_unmap_handle);
 
 /**
  * zpool_get_total_size() - The total size of the pool
@@ -346,6 +354,7 @@ u64 zpool_get_total_size(struct zpool *zpool)
 {
 	return zpool->driver->total_size(zpool->pool);
 }
+EXPORT_SYMBOL(zpool_get_total_size);
 
 static int __init init_zpool(void)
 {
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
