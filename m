Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id C154C6B0081
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 18:50:55 -0400 (EDT)
Received: by yenl1 with SMTP id l1so244376yen.14
        for <linux-mm@kvack.org>; Wed, 05 Sep 2012 15:50:54 -0700 (PDT)
From: Ezequiel Garcia <elezegarcia@gmail.com>
Subject: [PATCH 1/5] mm, slab: Remove silly function slab_buffer_size()
Date: Wed,  5 Sep 2012 19:48:39 -0300
Message-Id: <1346885323-15689-1-git-send-email-elezegarcia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Ezequiel Garcia <elezegarcia@gmail.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

This function is seldom used, and can be simply replaced with cachep->size.

Cc: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>
Signed-off-by: Ezequiel Garcia <elezegarcia@gmail.com>
---
 mm/slab.c |   12 ++----------
 1 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 3b4587b..53e41de 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -498,14 +498,6 @@ static void **dbg_userword(struct kmem_cache *cachep, void *objp)
 
 #endif
 
-#ifdef CONFIG_TRACING
-size_t slab_buffer_size(struct kmem_cache *cachep)
-{
-	return cachep->size;
-}
-EXPORT_SYMBOL(slab_buffer_size);
-#endif
-
 /*
  * Do not go above this order unless 0 objects fit into the slab or
  * overridden on the command line.
@@ -3849,7 +3841,7 @@ kmem_cache_alloc_trace(size_t size, struct kmem_cache *cachep, gfp_t flags)
 	ret = __cache_alloc(cachep, flags, __builtin_return_address(0));
 
 	trace_kmalloc(_RET_IP_, ret,
-		      size, slab_buffer_size(cachep), flags);
+		      size, cachep->size, flags);
 	return ret;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_trace);
@@ -3880,7 +3872,7 @@ void *kmem_cache_alloc_node_trace(size_t size,
 	ret = __cache_alloc_node(cachep, flags, nodeid,
 				  __builtin_return_address(0));
 	trace_kmalloc_node(_RET_IP_, ret,
-			   size, slab_buffer_size(cachep),
+			   size, cachep->size,
 			   flags, nodeid);
 	return ret;
 }
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
