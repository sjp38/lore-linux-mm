Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1CB416B01F6
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 16:34:34 -0400 (EDT)
Message-Id: <20100819203437.031478257@linux.com>
Date: Thu, 19 Aug 2010 15:33:25 -0500
From: Christoph Lameter <cl@linux-foundation.org>
Subject: [S+Q Cleanup3 1/6] Slub: Force no inlining of debug functions
References: <20100819203324.549566024@linux.com>
Content-Disposition: inline; filename=slub_nolinline
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

Compiler folds the debgging functions into the critical paths.
Avoid that by adding noinline to the functions that check for
problems.

Acked-by: David Rientjes <rientjes@google.com>
Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-08-19 14:13:02.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-08-19 14:13:05.000000000 -0500
@@ -862,7 +862,7 @@ static void setup_object_debug(struct km
 	init_tracking(s, object);
 }
 
-static int alloc_debug_processing(struct kmem_cache *s, struct page *page,
+static noinline int alloc_debug_processing(struct kmem_cache *s, struct page *page,
 					void *object, unsigned long addr)
 {
 	if (!check_slab(s, page))
@@ -902,8 +902,8 @@ bad:
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
