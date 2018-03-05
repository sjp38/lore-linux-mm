Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 204F86B0029
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 15:08:12 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id q15so11755990wra.22
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 12:08:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 13sor6314201wrw.88.2018.03.05.12.08.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 12:08:10 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 19/25] slab: make kmem_cache_flags accept 32-bit object size
Date: Mon,  5 Mar 2018 23:07:24 +0300
Message-Id: <20180305200730.15812-19-adobriyan@gmail.com>
In-Reply-To: <20180305200730.15812-1-adobriyan@gmail.com>
References: <20180305200730.15812-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, adobriyan@gmail.com

Now that all sizes are properly typed, propagate "unsigned int" down
the callgraph.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 mm/slab.c | 2 +-
 mm/slab.h | 4 ++--
 mm/slub.c | 4 ++--
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index cc136fcedfb9..7d17206dd574 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1868,7 +1868,7 @@ static int __ref setup_cpu_cache(struct kmem_cache *cachep, gfp_t gfp)
 	return 0;
 }
 
-slab_flags_t kmem_cache_flags(unsigned long object_size,
+slab_flags_t kmem_cache_flags(unsigned int object_size,
 	slab_flags_t flags, const char *name,
 	void (*ctor)(void *))
 {
diff --git a/mm/slab.h b/mm/slab.h
index 0809580428fe..8f1072f49285 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -108,7 +108,7 @@ struct kmem_cache *
 __kmem_cache_alias(const char *name, unsigned int size, unsigned int align,
 		   slab_flags_t flags, void (*ctor)(void *));
 
-slab_flags_t kmem_cache_flags(unsigned long object_size,
+slab_flags_t kmem_cache_flags(unsigned int object_size,
 	slab_flags_t flags, const char *name,
 	void (*ctor)(void *));
 #else
@@ -117,7 +117,7 @@ __kmem_cache_alias(const char *name, unsigned int size, unsigned int align,
 		   slab_flags_t flags, void (*ctor)(void *))
 { return NULL; }
 
-static inline slab_flags_t kmem_cache_flags(unsigned long object_size,
+static inline slab_flags_t kmem_cache_flags(unsigned int object_size,
 	slab_flags_t flags, const char *name,
 	void (*ctor)(void *))
 {
diff --git a/mm/slub.c b/mm/slub.c
index 424cb7693a5c..e82a6b50b3ef 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1292,7 +1292,7 @@ static int __init setup_slub_debug(char *str)
 
 __setup("slub_debug", setup_slub_debug);
 
-slab_flags_t kmem_cache_flags(unsigned long object_size,
+slab_flags_t kmem_cache_flags(unsigned int object_size,
 	slab_flags_t flags, const char *name,
 	void (*ctor)(void *))
 {
@@ -1325,7 +1325,7 @@ static inline void add_full(struct kmem_cache *s, struct kmem_cache_node *n,
 					struct page *page) {}
 static inline void remove_full(struct kmem_cache *s, struct kmem_cache_node *n,
 					struct page *page) {}
-slab_flags_t kmem_cache_flags(unsigned long object_size,
+slab_flags_t kmem_cache_flags(unsigned int object_size,
 	slab_flags_t flags, const char *name,
 	void (*ctor)(void *))
 {
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
