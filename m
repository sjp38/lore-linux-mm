Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 36DB26B01B6
	for <linux-mm@kvack.org>; Fri, 25 Jun 2010 17:24:30 -0400 (EDT)
Message-Id: <20100625212110.655465529@quilx.com>
Date: Fri, 25 Jun 2010 16:20:42 -0500
From: Christoph Lameter <cl@linux-foundation.org>
Subject: [S+Q 16/16] slub: Drop allocator announcement
References: <20100625212026.810557229@quilx.com>
Content-Disposition: inline; filename=mininum_objects
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

People get confused and some of the items listed no longer have the same
relevance in the queued form of SLUB.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 mm/slub.c |    7 -------
 1 file changed, 7 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-06-25 16:08:05.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-06-25 16:08:28.000000000 -0500
@@ -3124,13 +3124,6 @@ void __init kmem_cache_init(void)
 #ifdef CONFIG_SMP
 	register_cpu_notifier(&slab_notifier);
 #endif
-	printk(KERN_INFO
-		"SLUB: Genslabs=%d, HWalign=%d, Order=%d-%d, MinObjects=%d,"
-		" CPUs=%d, Nodes=%d\n",
-		caches, cache_line_size(),
-		slub_min_order, slub_max_order, slub_min_objects,
-		nr_cpu_ids, nr_node_ids);
-
 }
 
 void __init kmem_cache_init_late(void)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
