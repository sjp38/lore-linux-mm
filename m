Date: Tue, 22 Jul 2008 20:21:16 +0300
From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] unexport ksize
Message-ID: <20080722172116.GW14846@cs181140183.pp.htv.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>, cl@linux-foundation.org, mpm@selenic.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch removes the obsolete and no longer used exports of ksize.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 mm/slab.c |    1 -
 mm/slob.c |    1 -
 mm/slub.c |    1 -
 3 files changed, 3 deletions(-)

1e0e054cd28415dd8d1ed5443085469fcc6633ac 
diff --git a/mm/slab.c b/mm/slab.c
index 052e7d6..06bc560 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4473,4 +4473,3 @@ size_t ksize(const void *objp)
 
 	return obj_size(virt_to_cache(objp));
 }
-EXPORT_SYMBOL(ksize);
diff --git a/mm/slob.c b/mm/slob.c
index a3ad667..0e22be9 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -519,7 +519,6 @@ size_t ksize(const void *block)
 	else
 		return sp->page.private;
 }
-EXPORT_SYMBOL(ksize);
 
 struct kmem_cache {
 	unsigned int size, align;
diff --git a/mm/slub.c b/mm/slub.c
index 6d4a49c..8a2cb94 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2746,7 +2746,6 @@ size_t ksize(const void *object)
 	 */
 	return s->size;
 }
-EXPORT_SYMBOL(ksize);
 
 void kfree(const void *x)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
