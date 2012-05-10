Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id EFC176B004D
	for <linux-mm@kvack.org>; Thu, 10 May 2012 11:25:19 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so2783287pbb.14
        for <linux-mm@kvack.org>; Thu, 10 May 2012 08:25:19 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH] slub: fix incorrect return type of get_any_partial()
Date: Fri, 11 May 2012 00:23:56 +0900
Message-Id: <1336663436-2169-1-git-send-email-js1304@gmail.com>
In-Reply-To: <alpine.DEB.2.00.1205080912590.25669@router.home>
References: <alpine.DEB.2.00.1205080912590.25669@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

Commit 497b66f2ecc97844493e6a147fd5a7e73f73f408 ('slub: return object pointer
from get_partial() / new_slab().') changed return type of some functions.
This updates missing part.

In addition, fix some comments

Signed-off-by: Joonsoo Kim <js1304@gmail.com>

diff --git a/mm/slub.c b/mm/slub.c
index ffe13fd..23d66aa 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1577,9 +1577,9 @@ static void *get_partial_node(struct kmem_cache *s,
 }
 
 /*
- * Get a page from somewhere. Search in increasing NUMA distances.
+ * Get a partial slab from somewhere. Search in increasing NUMA distances.
  */
-static struct page *get_any_partial(struct kmem_cache *s, gfp_t flags,
+static void *get_any_partial(struct kmem_cache *s, gfp_t flags,
 		struct kmem_cache_cpu *c)
 {
 #ifdef CONFIG_NUMA
@@ -1643,7 +1643,7 @@ static struct page *get_any_partial(struct kmem_cache *s, gfp_t flags,
 }
 
 /*
- * Get a partial page, lock it and return it.
+ * Get a partial slab, lock it and return it.
  */
 static void *get_partial(struct kmem_cache *s, gfp_t flags, int node,
 		struct kmem_cache_cpu *c)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
