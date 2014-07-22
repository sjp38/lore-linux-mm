Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id EC0D86B003B
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 03:24:59 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id rd3so10971184pab.0
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 00:24:59 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id ox6si16690818pbb.185.2014.07.22.00.24.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Jul 2014 00:24:59 -0700 (PDT)
Received: by mail-pa0-f50.google.com with SMTP id et14so11369050pad.23
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 00:24:58 -0700 (PDT)
Message-ID: <53CE11C1.1030306@gmail.com>
Date: Tue, 22 Jul 2014 15:24:49 +0800
From: Wang Sheng-Hui <shhuiw@gmail.com>
MIME-Version: 1.0
Subject: [PATCH] mm: trivial comment cleanup in slab.c
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org


Current struct kmem_cache has no 'lock' field, and slab page is
managed by struct kmem_cache_node, which has 'list_lock' field.

Clean up the related comment.

Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
---
 mm/slab.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 3070b92..8f7170f 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1724,7 +1724,8 @@ slab_out_of_memory(struct kmem_cache *cachep, gfp_t gfpflags, int nodeid)
 }

 /*
- * Interface to system's page allocator. No need to hold the cache-lock.
+ * Interface to system's page allocator. No need to hold the
+ * kmem_cache_node ->list_lock.
  *
  * If we requested dmaable memory, we will get it. Even if we
  * did not request dmaable memory, we might get it, but that
@@ -2026,9 +2027,9 @@ static void slab_destroy_debugcheck(struct kmem_cache *cachep,
  * @cachep: cache pointer being destroyed
  * @page: page pointer being destroyed
  *
- * Destroy all the objs in a slab, and release the mem back to the system.
- * Before calling the slab must have been unlinked from the cache.  The
- * cache-lock is not held/needed.
+ * Destroy all the objs in a slab page, and release the mem back to the system.
+ * Before calling the slab page must have been unlinked from the cache. The
+ * kmem_cache_node ->list_lock is not held/needed.
  */
 static void slab_destroy(struct kmem_cache *cachep, struct page *page)
 {
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
