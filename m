Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 4C8BB6B004A
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 10:53:02 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so1930404pbc.14
        for <linux-mm@kvack.org>; Wed, 25 Apr 2012 07:53:01 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH] slub: fix incorrect return type of get_any_partial()
Date: Fri, 27 Jan 2012 00:12:23 -0800
Message-Id: <1327651943-28225-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

Commit 497b66f2ecc97844493e6a147fd5a7e73f73f408 ('slub: return object pointer
from get_partial() / new_slab().') changed return type of some functions.
This updates missing part.

Signed-off-by: Joonsoo Kim <js1304@gmail.com>

diff --git a/mm/slub.c b/mm/slub.c
index ffe13fd..18bf13e 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1579,7 +1579,7 @@ static void *get_partial_node(struct kmem_cache *s,
 /*
  * Get a page from somewhere. Search in increasing NUMA distances.
  */
-static struct page *get_any_partial(struct kmem_cache *s, gfp_t flags,
+static void *get_any_partial(struct kmem_cache *s, gfp_t flags,
 		struct kmem_cache_cpu *c)
 {
 #ifdef CONFIG_NUMA
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
