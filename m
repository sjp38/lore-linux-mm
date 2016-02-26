Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id F32596B0254
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 01:01:39 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id fy10so45372985pac.1
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 22:01:39 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id z63si17593086pfi.63.2016.02.25.22.01.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 22:01:38 -0800 (PST)
Received: by mail-pa0-x22e.google.com with SMTP id yy13so45390314pab.3
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 22:01:38 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH v2 02/17] mm/slab: remove useless structure define
Date: Fri, 26 Feb 2016 15:01:09 +0900
Message-Id: <1456466484-3442-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1456466484-3442-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1456466484-3442-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

It is obsolete so remove it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Acked-by: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 mm/slab.c | 11 +----------
 1 file changed, 1 insertion(+), 10 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 23fc4b0..3634dc1 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -225,16 +225,6 @@ static inline void clear_obj_pfmemalloc(void **objp)
 }
 
 /*
- * bootstrap: The caches do not work without cpuarrays anymore, but the
- * cpuarrays are allocated from the generic caches...
- */
-#define BOOT_CPUCACHE_ENTRIES	1
-struct arraycache_init {
-	struct array_cache cache;
-	void *entries[BOOT_CPUCACHE_ENTRIES];
-};
-
-/*
  * Need this for bootstrapping a per node allocator.
  */
 #define NUM_INIT_LISTS (2 * MAX_NUMNODES)
@@ -457,6 +447,7 @@ static inline unsigned int obj_to_index(const struct kmem_cache *cache,
 	return reciprocal_divide(offset, cache->reciprocal_buffer_size);
 }
 
+#define BOOT_CPUCACHE_ENTRIES	1
 /* internal cache of cache description objs */
 static struct kmem_cache kmem_cache_boot = {
 	.batchcount = 1,
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
