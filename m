Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id B2550828E2
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 00:24:33 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id q63so96342333pfb.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 21:24:33 -0800 (PST)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id 7si6888337pfq.145.2016.01.13.21.24.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 21:24:33 -0800 (PST)
Received: by mail-pa0-x243.google.com with SMTP id a20so22798180pag.3
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 21:24:33 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 02/16] mm/slab: remove useless structure define
Date: Thu, 14 Jan 2016 14:24:15 +0900
Message-Id: <1452749069-15334-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

It is obsolete so remove it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c | 11 +----------
 1 file changed, 1 insertion(+), 10 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index c8f9c3a..1bc6294 100644
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
