Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 46CDD6B0037
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 04:44:20 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 03/16] slab: remove colouroff in struct slab
Date: Thu, 22 Aug 2013 17:44:12 +0900
Message-Id: <1377161065-30552-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Now there is no user colouroff, so remove it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index 180f532..d9f81a0 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -219,7 +219,6 @@ struct slab {
 	union {
 		struct {
 			struct list_head list;
-			unsigned long colouroff;
 			void *s_mem;		/* including colour offset */
 			unsigned int inuse;	/* num of objs active in slab */
 			kmem_bufctl_t free;
@@ -2624,7 +2623,6 @@ static struct slab *alloc_slabmgmt(struct kmem_cache *cachep,
 		colour_off += cachep->slab_size;
 	}
 	slabp->inuse = 0;
-	slabp->colouroff = colour_off;
 	slabp->s_mem = addr + colour_off;
 	slabp->nodeid = nodeid;
 	slabp->free = 0;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
