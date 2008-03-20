Message-Id: <20080320202120.871053000@chello.nl>
References: <20080320201042.675090000@chello.nl>
Date: Thu, 20 Mar 2008 21:10:46 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 04/30] mm: slub: trivial cleanups
Content-Disposition: inline; filename=cleanup-slub.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, neilb@suse.de, miklos@szeredi.hu, penberg@cs.helsinki.fi, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

some cleanups..

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 mm/slub.c |   14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c
+++ linux-2.6/mm/slub.c
@@ -25,7 +25,7 @@
 /*
  * Lock order:
  *   1. slab_lock(page)
- *   2. slab->list_lock
+ *   2. node->list_lock
  *
  *   The slab_lock protects operations on the object of a particular
  *   slab and its metadata in the page struct. If the slab lock
@@ -1058,8 +1058,7 @@ static struct page *allocate_slab(struct
 	return page;
 }
 
-static void setup_object(struct kmem_cache *s, struct page *page,
-				void *object)
+static void setup_object(struct kmem_cache *s, struct page *page, void *object)
 {
 	setup_object_debug(s, page, object);
 	if (unlikely(s->ctor))
@@ -1205,8 +1204,7 @@ static __always_inline int slab_trylock(
 /*
  * Management of partially allocated slabs
  */
-static void add_partial(struct kmem_cache_node *n,
-				struct page *page, int tail)
+static void add_partial(struct kmem_cache_node *n, struct page *page, int tail)
 {
 	spin_lock(&n->list_lock);
 	n->nr_partial++;
@@ -1217,8 +1215,7 @@ static void add_partial(struct kmem_cach
 	spin_unlock(&n->list_lock);
 }
 
-static void remove_partial(struct kmem_cache *s,
-						struct page *page)
+static void remove_partial(struct kmem_cache *s, struct page *page)
 {
 	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
 
@@ -1233,7 +1230,8 @@ static void remove_partial(struct kmem_c
  *
  * Must hold list_lock.
  */
-static inline int lock_and_freeze_slab(struct kmem_cache_node *n, struct page *page)
+static inline
+int lock_and_freeze_slab(struct kmem_cache_node *n, struct page *page)
 {
 	if (slab_trylock(page)) {
 		list_del(&page->lru);

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
