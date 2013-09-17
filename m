Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 4F9986B0033
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 14:35:52 -0400 (EDT)
Message-ID: <5238A0FF.1040506@infradead.org>
Date: Tue, 17 Sep 2013 11:35:43 -0700
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: [PATCH 2/2] mm: fix slab.h endif comments
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

From: Randy Dunlap <rdunlap@infradead.org>

Add comments to several #endif lines to match most of the rest
of the file (except for short, easily visible blocks).

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
---
 include/linux/slab.h |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

--- lnx-312-rc1.orig/include/linux/slab.h
+++ lnx-312-rc1/include/linux/slab.h
@@ -194,7 +194,7 @@ struct kmem_cache {
 #ifndef KMALLOC_SHIFT_LOW
 #define KMALLOC_SHIFT_LOW	5
 #endif
-#endif
+#endif /* CONFIG_SLAB */
 
 #ifdef CONFIG_SLUB
 /*
@@ -206,7 +206,7 @@ struct kmem_cache {
 #ifndef KMALLOC_SHIFT_LOW
 #define KMALLOC_SHIFT_LOW	3
 #endif
-#endif
+#endif /* CONFIG_SLUB */
 
 #ifdef CONFIG_SLOB
 /*
@@ -219,7 +219,7 @@ struct kmem_cache {
 #ifndef KMALLOC_SHIFT_LOW
 #define KMALLOC_SHIFT_LOW	3
 #endif
-#endif
+#endif /* CONFIG_SLOB */
 
 /* Maximum allocatable size */
 #define KMALLOC_MAX_SIZE	(1UL << KMALLOC_SHIFT_MAX)
@@ -308,7 +308,7 @@ static __always_inline void *kmem_cache_
 {
 	return kmem_cache_alloc(s, flags);
 }
-#endif
+#endif /* CONFIG_NUMA */
 
 #ifdef CONFIG_TRACING
 extern void *kmem_cache_alloc_trace(struct kmem_cache *, gfp_t, size_t);
@@ -580,7 +580,7 @@ extern void *__kmalloc_track_caller(size
 #else
 #define kmalloc_track_caller(size, flags) \
 	__kmalloc(size, flags)
-#endif /* DEBUG_SLAB */
+#endif /* DEBUG_SLAB etc. */
 
 #ifdef CONFIG_NUMA
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
