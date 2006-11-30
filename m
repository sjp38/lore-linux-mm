Message-Id: <20061130101922.175620000@chello.nl>>
References: <20061130101451.495412000@chello.nl>>
Date: Thu, 30 Nov 2006 11:14:56 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 5/6] slab: kmem_cache_objs_to_pages()
Content-Disposition: inline; filename=kmem_cache_objs_to_pages.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: netdev@vger.kernel.org, linux-mm@kvack.org
Cc: David Miller <davem@davemloft.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Provide a method to calculate the number of pages used by a given number of
slab objects.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/slab.h |    1 +
 mm/slab.c            |    6 ++++++
 2 files changed, 7 insertions(+)

Index: linux-2.6-git/include/linux/slab.h
===================================================================
--- linux-2.6-git.orig/include/linux/slab.h	2006-11-27 10:46:44.000000000 +0100
+++ linux-2.6-git/include/linux/slab.h	2006-11-27 10:47:33.000000000 +0100
@@ -209,6 +209,7 @@ static inline void *kcalloc(size_t n, si
 extern void kfree(const void *);
 extern unsigned int ksize(const void *);
 extern int slab_is_available(void);
+extern unsigned int kmem_cache_objs_to_pages(struct kmem_cache *, int);
 
 #ifdef CONFIG_NUMA
 extern void *kmem_cache_alloc_node(kmem_cache_t *, gfp_t flags, int node);
Index: linux-2.6-git/mm/slab.c
===================================================================
--- linux-2.6-git.orig/mm/slab.c	2006-11-27 10:47:26.000000000 +0100
+++ linux-2.6-git/mm/slab.c	2006-11-27 10:47:54.000000000 +0100
@@ -4279,3 +4279,9 @@ unsigned int ksize(const void *objp)
 
 	return obj_size(virt_to_cache(objp));
 }
+
+unsigned int kmem_cache_objs_to_pages(struct kmem_cache *cachep, int nr)
+{
+	return ((nr + cachep->num - 1) / cachep->num) << cachep->gfporder;
+}
+EXPORT_SYMBOL_GPL(kmem_cache_objs_to_pages);

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
