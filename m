Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id C926C900019
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 11:17:17 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id et14so1243423pad.17
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 08:17:17 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id kk1si1879443pbc.81.2014.10.23.08.17.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Oct 2014 08:17:16 -0700 (PDT)
Received: by mail-pa0-f48.google.com with SMTP id ey11so1241610pad.21
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 08:17:16 -0700 (PDT)
From: Quanyang Liu <lqymgt@gmail.com>
Subject: [PATCH] mm: slab/slub: coding style: whitespaces and tabs mixture
Date: Thu, 23 Oct 2014 23:17:07 +0800
Message-Id: <1414077427-9616-1-git-send-email-lqymgt@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, LQYMGT <lqymgt@gmail.com>

From: LQYMGT <lqymgt@gmail.com>

Some code in mm/slab.c and mm/slub.c use whitespaces in indent.
Clean them up.

Signed-off-by: LQYMGT <lqymgt@gmail.com>
---
 mm/slab.c | 10 +++++-----
 mm/slub.c | 10 +++++-----
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index eb2b2ea..1830c2d 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3580,11 +3580,11 @@ static int alloc_kmem_cache_node(struct kmem_cache *cachep, gfp_t gfp)
 
 	for_each_online_node(node) {
 
-                if (use_alien_caches) {
-                        new_alien = alloc_alien_cache(node, cachep->limit, gfp);
-                        if (!new_alien)
-                                goto fail;
-                }
+		if (use_alien_caches) {
+			new_alien = alloc_alien_cache(node, cachep->limit, gfp);
+			if (!new_alien)
+				goto fail;
+		}
 
 		new_shared = NULL;
 		if (cachep->shared) {
diff --git a/mm/slub.c b/mm/slub.c
index ae7b9f1..761789e 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2554,7 +2554,7 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 
 			} else { /* Needs to be taken off a list */
 
-	                        n = get_node(s, page_to_nid(page));
+				n = get_node(s, page_to_nid(page));
 				/*
 				 * Speculatively acquire the list_lock.
 				 * If the cmpxchg does not succeed then we may
@@ -2587,10 +2587,10 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 		 * The list lock was not taken therefore no list
 		 * activity can be necessary.
 		 */
-                if (was_frozen)
-                        stat(s, FREE_FROZEN);
-                return;
-        }
+		if (was_frozen)
+			stat(s, FREE_FROZEN);
+		return;
+	}
 
 	if (unlikely(!new.inuse && n->nr_partial >= s->min_partial))
 		goto slab_empty;
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
