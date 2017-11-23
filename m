Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C49FA6B0284
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 17:17:26 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id u83so4944170wmb.8
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 14:17:26 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v202sor2030305wmv.25.2017.11.23.14.17.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Nov 2017 14:17:25 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 18/23] slab: make kmem_cache_flags accept 32-bit object size
Date: Fri, 24 Nov 2017 01:16:23 +0300
Message-Id: <20171123221628.8313-18-adobriyan@gmail.com>
In-Reply-To: <20171123221628.8313-1-adobriyan@gmail.com>
References: <20171123221628.8313-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, Alexey Dobriyan <adobriyan@gmail.com>

Now that all sizes are properly typed, propagate "unsigned int" down
the callgraph.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 mm/slab.c | 2 +-
 mm/slab.h | 4 ++--
 mm/slub.c | 4 ++--
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 78fd096362da..15da0e177d7b 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1874,7 +1874,7 @@ static int __ref setup_cpu_cache(struct kmem_cache *cachep, gfp_t gfp)
 	return 0;
 }
 
-slab_flags_t kmem_cache_flags(unsigned long object_size,
+slab_flags_t kmem_cache_flags(unsigned int object_size,
 	slab_flags_t flags, const char *name,
 	void (*ctor)(void *))
 {
diff --git a/mm/slab.h b/mm/slab.h
index facaf949f727..2993ba92c89e 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -107,7 +107,7 @@ struct kmem_cache *
 __kmem_cache_alias(const char *name, unsigned int size, unsigned int align,
 		   slab_flags_t flags, void (*ctor)(void *));
 
-slab_flags_t kmem_cache_flags(unsigned long object_size,
+slab_flags_t kmem_cache_flags(unsigned int object_size,
 	slab_flags_t flags, const char *name,
 	void (*ctor)(void *));
 #else
@@ -116,7 +116,7 @@ __kmem_cache_alias(const char *name, unsigned int size, unsigned int align,
 		   slab_flags_t flags, void (*ctor)(void *))
 { return NULL; }
 
-static inline slab_flags_t kmem_cache_flags(unsigned long object_size,
+static inline slab_flags_t kmem_cache_flags(unsigned int object_size,
 	slab_flags_t flags, const char *name,
 	void (*ctor)(void *))
 {
diff --git a/mm/slub.c b/mm/slub.c
index 042421584ef8..cd09ae2c48e8 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1290,7 +1290,7 @@ static int __init setup_slub_debug(char *str)
 
 __setup("slub_debug", setup_slub_debug);
 
-slab_flags_t kmem_cache_flags(unsigned long object_size,
+slab_flags_t kmem_cache_flags(unsigned int object_size,
 	slab_flags_t flags, const char *name,
 	void (*ctor)(void *))
 {
@@ -1323,7 +1323,7 @@ static inline void add_full(struct kmem_cache *s, struct kmem_cache_node *n,
 					struct page *page) {}
 static inline void remove_full(struct kmem_cache *s, struct kmem_cache_node *n,
 					struct page *page) {}
-slab_flags_t kmem_cache_flags(unsigned long object_size,
+slab_flags_t kmem_cache_flags(unsigned int object_size,
 	slab_flags_t flags, const char *name,
 	void (*ctor)(void *))
 {
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
