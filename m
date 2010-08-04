Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 02DFD660021
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 22:45:27 -0400 (EDT)
Message-Id: <20100804024526.723788302@linux.com>
Date: Tue, 03 Aug 2010 21:45:19 -0500
From: Christoph Lameter <cl@linux-foundation.org>
Subject: [S+Q3 05/23] Subjec Slub: Force no inlining of debug functions
References: <20100804024514.139976032@linux.com>
Content-Disposition: inline; filename=slub_nolinline
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

Compiler folds the debgging functions into the critical paths.
Avoid that by adding noinline to the functions that check for
problems.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-07-29 18:32:26.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-07-29 18:32:33.000000000 -0500
@@ -857,7 +857,7 @@ static void setup_object_debug(struct km
 	init_tracking(s, object);
 }
 
-static int alloc_debug_processing(struct kmem_cache *s, struct page *page,
+static noinline int alloc_debug_processing(struct kmem_cache *s, struct page *page,
 					void *object, unsigned long addr)
 {
 	if (!check_slab(s, page))
@@ -897,8 +897,8 @@ bad:
 	return 0;
 }
 
-static int free_debug_processing(struct kmem_cache *s, struct page *page,
-					void *object, unsigned long addr)
+static noinline int free_debug_processing(struct kmem_cache *s,
+		 struct page *page, void *object, unsigned long addr)
 {
 	if (!check_slab(s, page))
 		goto fail;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
