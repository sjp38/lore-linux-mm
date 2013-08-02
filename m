Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 630A06B0031
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 21:57:05 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 1/2] mm, vmalloc: remove useless variable in vmap_block
Date: Fri,  2 Aug 2013 10:57:00 +0900
Message-Id: <1375408621-16563-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Joonsoo Kim <js1304@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

vbq in vmap_block isn't used. So remove it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 13a5495..d23c432 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -752,7 +752,6 @@ struct vmap_block_queue {
 struct vmap_block {
 	spinlock_t lock;
 	struct vmap_area *va;
-	struct vmap_block_queue *vbq;
 	unsigned long free, dirty;
 	DECLARE_BITMAP(dirty_map, VMAP_BBMAP_BITS);
 	struct list_head free_list;
@@ -830,7 +829,6 @@ static struct vmap_block *new_vmap_block(gfp_t gfp_mask)
 	radix_tree_preload_end();
 
 	vbq = &get_cpu_var(vmap_block_queue);
-	vb->vbq = vbq;
 	spin_lock(&vbq->lock);
 	list_add_rcu(&vb->free_list, &vbq->free);
 	spin_unlock(&vbq->lock);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
