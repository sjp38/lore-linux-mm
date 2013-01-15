Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 444AF6B006E
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 02:20:20 -0500 (EST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 3/3] slub: add 'likely' macro to inc_slabs_node()
Date: Tue, 15 Jan 2013 16:20:02 +0900
Message-Id: <1358234402-2615-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1358234402-2615-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1358234402-2615-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, js1304@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

After boot phase, 'n' always exist.
So add 'likely' macro for helping compiler.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slub.c b/mm/slub.c
index 830348b..6f82070 100644
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
