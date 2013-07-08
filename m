Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 365666B0037
	for <linux-mm@kvack.org>; Mon,  8 Jul 2013 04:08:36 -0400 (EDT)
Message-ID: <51DA734B.4060608@asianux.com>
Date: Mon, 08 Jul 2013 16:07:39 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: [PATCH] mm/slub.c: remove 'per_cpu' which is useless variable
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

Remove 'per_cpu', since it is useless now after the patch: "205ab99
slub: Update statistics handling for variable order slabs".

Also beautify code with tab alignment.

Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 mm/slub.c |   17 ++++++-----------
 1 files changed, 6 insertions(+), 11 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 2caaa67..aa847eb 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4271,12 +4271,10 @@ static ssize_t show_slab_objects(struct kmem_cache *s,
 	int node;
 	int x;
 	unsigned long *nodes;
-	unsigned long *per_cpu;
 
-	nodes = kzalloc(2 * sizeof(unsigned long) * nr_node_ids, GFP_KERNEL);
+	nodes = kzalloc(sizeof(unsigned long) * nr_node_ids, GFP_KERNEL);
 	if (!nodes)
 		return -ENOMEM;
-	per_cpu = nodes + nr_node_ids;
 
 	if (flags & SO_CPU) {
 		int cpu;
@@ -4307,8 +4305,6 @@ static ssize_t show_slab_objects(struct kmem_cache *s,
 				total += x;
 				nodes[node] += x;
 			}
-
-			per_cpu[node]++;
 		}
 	}
 
@@ -4318,12 +4314,11 @@ static ssize_t show_slab_objects(struct kmem_cache *s,
 		for_each_node_state(node, N_NORMAL_MEMORY) {
 			struct kmem_cache_node *n = get_node(s, node);
 
-		if (flags & SO_TOTAL)
-			x = atomic_long_read(&n->total_objects);
-		else if (flags & SO_OBJECTS)
-			x = atomic_long_read(&n->total_objects) -
-				count_partial(n, count_free);
-
+			if (flags & SO_TOTAL)
+				x = atomic_long_read(&n->total_objects);
+			else if (flags & SO_OBJECTS)
+				x = atomic_long_read(&n->total_objects) -
+					count_partial(n, count_free);
 			else
 				x = atomic_long_read(&n->nr_slabs);
 			total += x;
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
