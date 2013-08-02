Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 43F3B6B0031
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 22:02:46 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH] mm, slab_common: add 'unlikely' to size check of kmalloc_slab()
Date: Fri,  2 Aug 2013 11:02:42 +0900
Message-Id: <1375408962-16743-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Size is usually below than KMALLOC_MAX_SIZE.
If we add a 'unlikely' macro, compiler can make better code.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 538bade..f0410eb 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -373,7 +373,7 @@ struct kmem_cache *kmalloc_slab(size_t size, gfp_t flags)
 {
 	int index;
 
-	if (size > KMALLOC_MAX_SIZE) {
+	if (unlikely(size > KMALLOC_MAX_SIZE)) {
 		WARN_ON_ONCE(!(flags & __GFP_NOWARN));
 		return NULL;
 	}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
