Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 3CB396B0038
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 04:44:18 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id bj1so747711pad.28
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 01:44:17 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 03/15] slab: remove colouroff in struct slab
Date: Wed, 16 Oct 2013 17:44:00 +0900
Message-Id: <1381913052-23875-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Now there is no user colouroff, so remove it.

Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index 7d79bd7..34eb115 100644
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
@@ -2630,7 +2629,6 @@ static struct slab *alloc_slabmgmt(struct kmem_cache *cachep,
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
