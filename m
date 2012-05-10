Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id E0C9F6B00F3
	for <linux-mm@kvack.org>; Thu, 10 May 2012 11:52:07 -0400 (EDT)
Received: by dakp5 with SMTP id p5so2594312dak.14
        for <linux-mm@kvack.org>; Thu, 10 May 2012 08:52:07 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH] slub: remove unused argument of init_kmem_cache_node()
Date: Fri, 11 May 2012 00:50:47 +0900
Message-Id: <1336665047-22205-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

We don't use the argument since commit 3b89d7d881a1dbb4da158f7eb5d6b3ceefc72810
('slub: move min_partial to struct kmem_cache'), so remove it

Signed-off-by: Joonsoo Kim <js1304@gmail.com>

diff --git a/mm/slub.c b/mm/slub.c
index 9c920a0..323778e 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2766,7 +2766,7 @@ static unsigned long calculate_alignment(unsigned long flags,
 }
 
 static void
-init_kmem_cache_node(struct kmem_cache_node *n, struct kmem_cache *s)
+init_kmem_cache_node(struct kmem_cache_node *n)
 {
 	n->nr_partial = 0;
 	spin_lock_init(&n->list_lock);
@@ -2836,7 +2836,7 @@ static void early_kmem_cache_node_alloc(int node)
 	init_object(kmem_cache_node, n, SLUB_RED_ACTIVE);
 	init_tracking(kmem_cache_node, n);
 #endif
-	init_kmem_cache_node(n, kmem_cache_node);
+	init_kmem_cache_node(n);
 	inc_slabs_node(kmem_cache_node, node, page->objects);
 
 	add_partial(n, page, DEACTIVATE_TO_HEAD);
@@ -2876,7 +2876,7 @@ static int init_kmem_cache_nodes(struct kmem_cache *s)
 		}
 
 		s->node[node] = n;
-		init_kmem_cache_node(n, s);
+		init_kmem_cache_node(n);
 	}
 	return 1;
 }
@@ -3625,7 +3625,7 @@ static int slab_mem_going_online_callback(void *arg)
 			ret = -ENOMEM;
 			goto out;
 		}
-		init_kmem_cache_node(n, s);
+		init_kmem_cache_node(n);
 		s->node[nid] = n;
 	}
 out:
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
