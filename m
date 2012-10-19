Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 184016B00A4
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 10:51:50 -0400 (EDT)
Message-Id: <0000013a79823806-6205c310-dfdc-40fa-ae3f-d7d1a9bc5e80-000000@email.amazonses.com>
Date: Fri, 19 Oct 2012 14:51:48 +0000
From: Christoph Lameter <cl@linux.com>
Subject: CK2 [06/15] Move kmalloc related function defs
References: <20121019142254.724806786@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com


Move these functions higher up in slab.h so that they are grouped with other
generic kmalloc related definitions.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/include/linux/slab.h
===================================================================
--- linux.orig/include/linux/slab.h	2012-10-15 16:09:59.037866248 -0500
+++ linux/include/linux/slab.h	2012-10-15 16:10:36.726540724 -0500
@@ -143,6 +143,15 @@ unsigned int kmem_cache_size(struct kmem
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
@@ -178,15 +187,6 @@ unsigned int kmem_cache_size(struct kmem
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
