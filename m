Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 69E696B0253
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 17:17:12 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id v8so12664272wrd.21
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 14:17:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e10sor1712859wmd.88.2017.11.23.14.17.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Nov 2017 14:17:11 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 03/23] slab: create_kmalloc_cache() works with 32-bit sizes
Date: Fri, 24 Nov 2017 01:16:08 +0300
Message-Id: <20171123221628.8313-3-adobriyan@gmail.com>
In-Reply-To: <20171123221628.8313-1-adobriyan@gmail.com>
References: <20171123221628.8313-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, Alexey Dobriyan <adobriyan@gmail.com>

KMALLOC_MAX_CACHE_SIZE is 32-bit so is the largest kmalloc cache size.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 mm/slab.h        | 4 ++--
 mm/slab_common.c | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/slab.h b/mm/slab.h
index ad657ffa44e5..08f43ed41b75 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -75,7 +75,7 @@ extern struct kmem_cache *kmem_cache;
 /* A table of kmalloc cache names and sizes */
 extern const struct kmalloc_info_struct {
 	const char *name;
-	unsigned long size;
+	unsigned int size;
 } kmalloc_info[];
 
 unsigned long calculate_alignment(slab_flags_t flags,
@@ -94,7 +94,7 @@ struct kmem_cache *kmalloc_slab(size_t, gfp_t);
 /* Functions provided by the slab allocators */
 int __kmem_cache_create(struct kmem_cache *, slab_flags_t flags);
 
-extern struct kmem_cache *create_kmalloc_cache(const char *name, size_t size,
+struct kmem_cache *create_kmalloc_cache(const char *name, unsigned int size,
 			slab_flags_t flags);
 extern void create_boot_cache(struct kmem_cache *, const char *name,
 			size_t size, slab_flags_t flags);
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 8ba0ffb31279..fa27e0492f89 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -898,7 +898,7 @@ void __init create_boot_cache(struct kmem_cache *s, const char *name, size_t siz
 	s->refcount = -1;	/* Exempt from merging for now */
 }
 
-struct kmem_cache *__init create_kmalloc_cache(const char *name, size_t size,
+struct kmem_cache *__init create_kmalloc_cache(const char *name, unsigned int size,
 				slab_flags_t flags)
 {
 	struct kmem_cache *s = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
