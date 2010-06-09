Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9F51B6B01D7
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 02:49:13 -0400 (EDT)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id o596nBBv009902
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 23:49:11 -0700
Received: from pvg16 (pvg16.prod.google.com [10.241.210.144])
	by kpbe17.cbf.corp.google.com with ESMTP id o596n9Tq008663
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 23:49:10 -0700
Received: by pvg16 with SMTP id 16so2351174pvg.19
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 23:49:09 -0700 (PDT)
Date: Tue, 8 Jun 2010 23:49:06 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 2/4] slub: rename debug_on to cache_debug_on
In-Reply-To: <alpine.DEB.2.00.1006082347440.30606@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1006082348160.30606@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006082347440.30606@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

debug_on() is too generic of a name for a slub function, so rename it to
the more appropriate cache_debug_on().

Cc: Christoph Lameter <cl@linux.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/slub.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -110,7 +110,7 @@
 #define SLAB_DEBUG_FLAGS (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER | \
 		SLAB_TRACE | SLAB_DEBUG_FREE)
 
-static inline int debug_on(struct kmem_cache *s)
+static inline int cache_debug_on(struct kmem_cache *s)
 {
 #ifdef CONFIG_SLUB_DEBUG
 	return unlikely(s->flags & SLAB_DEBUG_FLAGS);
@@ -1202,7 +1202,7 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
 	int order = compound_order(page);
 	int pages = 1 << order;
 
-	if (debug_on(s)) {
+	if (cache_debug_on(s)) {
 		void *p;
 
 		slab_pad_check(s, page);
@@ -1433,7 +1433,7 @@ static void unfreeze_slab(struct kmem_cache *s, struct page *page, int tail)
 			stat(s, tail ? DEACTIVATE_TO_TAIL : DEACTIVATE_TO_HEAD);
 		} else {
 			stat(s, DEACTIVATE_FULL);
-			if (debug_on(s) && (s->flags & SLAB_STORE_USER))
+			if (cache_debug_on(s) && (s->flags & SLAB_STORE_USER))
 				add_full(n, page);
 		}
 		slab_unlock(page);
@@ -1640,7 +1640,7 @@ load_freelist:
 	object = c->page->freelist;
 	if (unlikely(!object))
 		goto another_slab;
-	if (debug_on(s))
+	if (cache_debug_on(s))
 		goto debug;
 
 	c->freelist = get_freepointer(s, object);
@@ -1799,7 +1799,7 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 	stat(s, FREE_SLOWPATH);
 	slab_lock(page);
 
-	if (debug_on(s))
+	if (cache_debug_on(s))
 		goto debug;
 
 checks_ok:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
