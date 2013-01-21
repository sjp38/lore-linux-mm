Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 8FFA06B0009
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 03:01:35 -0500 (EST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 3/3] slub: add 'likely' macro to inc_slabs_node()
Date: Mon, 21 Jan 2013 17:01:27 +0900
Message-Id: <1358755287-3899-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1358755287-3899-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1358755287-3899-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, js1304@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

After boot phase, 'n' always exist.
So add 'likely' macro for helping compiler.

Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slub.c b/mm/slub.c
index 8b95364..ddbd401 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1005,7 +1005,7 @@ static inline void inc_slabs_node(struct kmem_cache *s, int node, int objects)
 	 * dilemma by deferring the increment of the count during
 	 * bootstrap (see early_kmem_cache_node_alloc).
 	 */
-	if (n) {
+	if (likely(n)) {
 		atomic_long_inc(&n->nr_slabs);
 		atomic_long_add(objects, &n->total_objects);
 	}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
