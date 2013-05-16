Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 4D8426B0033
	for <linux-mm@kvack.org>; Wed, 15 May 2013 23:36:37 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id kp6so2093654pab.35
        for <linux-mm@kvack.org>; Wed, 15 May 2013 20:36:36 -0700 (PDT)
From: sanweidaying@gmail.com
Subject: [PATCH v2] mm, slab: moved kmem_cache_alloc_node comment to correct place
Date: Thu, 16 May 2013 11:36:23 +0800
Message-Id: <1368675383-3976-1-git-send-email-sanweidaying@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Zhouping Liu <zliu@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org

From: Zhouping Liu <zliu@redhat.com>

After several fixing about kmem_cache_alloc_node(), its comment
was splitted. This patch moved it on top of kmem_cache_alloc_node()
definition.

Signed-off-by: Zhouping Liu <zliu@redhat.com>
---
 mm/slab.c | 23 +++++++++++------------
 1 file changed, 11 insertions(+), 12 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 8ccd296..be12f68 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3338,18 +3338,6 @@ done:
 	return obj;
 }
 
-/**
- * kmem_cache_alloc_node - Allocate an object on the specified node
- * @cachep: The cache to allocate from.
- * @flags: See kmalloc().
- * @nodeid: node number of the target node.
- * @caller: return address of caller, used for debug information
- *
- * Identical to kmem_cache_alloc but it will allocate memory on the given
- * node, which can improve the performance for cpu bound structures.
- *
- * Fallback to other node is possible if __GFP_THISNODE is not set.
- */
 static __always_inline void *
 slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
 		   unsigned long caller)
@@ -3643,6 +3631,17 @@ EXPORT_SYMBOL(kmem_cache_alloc_trace);
 #endif
 
 #ifdef CONFIG_NUMA
+/**
+ * kmem_cache_alloc_node - Allocate an object on the specified node
+ * @cachep: The cache to allocate from.
+ * @flags: See kmalloc().
+ * @nodeid: node number of the target node.
+ *
+ * Identical to kmem_cache_alloc but it will allocate memory on the given
+ * node, which can improve the performance for cpu bound structures.
+ *
+ * Fallback to other node is possible if __GFP_THISNODE is not set.
+ */
 void *kmem_cache_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 {
 	void *ret = slab_alloc_node(cachep, flags, nodeid, _RET_IP_);
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
