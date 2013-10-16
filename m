Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 7F3786B0039
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 04:44:20 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id y13so574885pdi.12
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 01:44:20 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 07/15] slab: use well-defined macro, virt_to_slab()
Date: Wed, 16 Oct 2013 17:44:04 +0900
Message-Id: <1381913052-23875-8-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

This is trivial change, just use well-defined macro.

Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index 84c4ed6..f9e676e 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2865,7 +2865,6 @@ static inline void verify_redzone_free(struct kmem_cache *cache, void *obj)
 static void *cache_free_debugcheck(struct kmem_cache *cachep, void *objp,
 				   unsigned long caller)
 {
-	struct page *page;
 	unsigned int objnr;
 	struct slab *slabp;
 
@@ -2873,9 +2872,7 @@ static void *cache_free_debugcheck(struct kmem_cache *cachep, void *objp,
 
 	objp -= obj_offset(cachep);
 	kfree_debugcheck(objp);
-	page = virt_to_head_page(objp);
-
-	slabp = page->slab_page;
+	slabp = virt_to_slab(objp);
 
 	if (cachep->flags & SLAB_RED_ZONE) {
 		verify_redzone_free(cachep, objp);
@@ -3087,7 +3084,7 @@ static void *cache_alloc_debugcheck_after(struct kmem_cache *cachep,
 		struct slab *slabp;
 		unsigned objnr;
 
-		slabp = virt_to_head_page(objp)->slab_page;
+		slabp = virt_to_slab(objp);
 		objnr = (unsigned)(objp - slabp->s_mem) / cachep->size;
 		slab_bufctl(slabp)[objnr] = BUFCTL_ACTIVE;
 	}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
