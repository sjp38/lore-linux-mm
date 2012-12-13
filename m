Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id DE3D26B005D
	for <linux-mm@kvack.org>; Thu, 13 Dec 2012 16:15:36 -0500 (EST)
Message-Id: <0000013b961f56fb-ab2d92ba-2ebf-4da1-b688-30144d2d1802-000000@email.amazonses.com>
Date: Thu, 13 Dec 2012 21:15:34 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Ren [02/12] Move kmalloc related function defs
References: <20121213211413.134419945@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

Move these functions higher up in slab.h so that they are grouped with other
generic kmalloc related definitions.

Acked-by: Glauber Costa <glommer@parallels.com>
Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/include/linux/slab.h
===================================================================
--- linux.orig/include/linux/slab.h	2012-11-01 10:09:46.745412498 -0500
+++ linux/include/linux/slab.h	2012-11-01 10:10:24.838044511 -0500
@@ -142,6 +142,15 @@ void kmem_cache_free(struct kmem_cache *
 		(__flags), NULL)
 
 /*
+ * Common kmalloc functions provided by all allocators
+ */
+void * __must_check __krealloc(const void *, size_t, gfp_t);
+void * __must_check krealloc(const void *, size_t, gfp_t);
+void kfree(const void *);
+void kzfree(const void *);
+size_t ksize(const void *);
+
+/*
  * The largest kmalloc size supported by the slab allocators is
  * 32 megabyte (2^25) or the maximum allocatable page order if that is
  * less than 32 MB.
@@ -177,15 +186,6 @@ void kmem_cache_free(struct kmem_cache *
 #endif
 
 /*
- * Common kmalloc functions provided by all allocators
- */
-void * __must_check __krealloc(const void *, size_t, gfp_t);
-void * __must_check krealloc(const void *, size_t, gfp_t);
-void kfree(const void *);
-void kzfree(const void *);
-size_t ksize(const void *);
-
-/*
  * Allocator specific definitions. These are mainly used to establish optimized
  * ways to convert kmalloc() calls to kmem_cache_alloc() invocations by
  * selecting the appropriate general cache at compile time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
