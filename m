Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 8065C6B0033
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 18:31:31 -0400 (EDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/2] mempool: Convert kmalloc_node(...GFP_ZERO...) to kzalloc_node(...)
Date: Thu, 29 Aug 2013 15:31:19 -0700
Message-Id: <f172c1f3d71f879d8864ce0374988624c35691ca.1377815411.git.joe@perches.com>
In-Reply-To: <19f4bf138da20276466d4ae66f8704e762d3e0f0.1377815411.git.joe@perches.com>
References: <19f4bf138da20276466d4ae66f8704e762d3e0f0.1377815411.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

Use the helper function instead of __GFP_ZERO.

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/mempool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mempool.c b/mm/mempool.c
index 5499047..659aa42 100644
--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -73,7 +73,7 @@ mempool_t *mempool_create_node(int min_nr, mempool_alloc_t *alloc_fn,
 			       gfp_t gfp_mask, int node_id)
 {
 	mempool_t *pool;
-	pool = kmalloc_node(sizeof(*pool), gfp_mask | __GFP_ZERO, node_id);
+	pool = kzalloc_node(sizeof(*pool), gfp_mask, node_id);
 	if (!pool)
 		return NULL;
 	pool->elements = kmalloc_node(min_nr * sizeof(void *),
-- 
1.8.1.2.459.gbcd45b4.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
