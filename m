Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 880CC600921
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 15:12:24 -0400 (EDT)
Message-Id: <20100709190901.044653725@quilx.com>
Date: Fri, 09 Jul 2010 14:07:25 -0500
From: Christoph Lameter <cl@linux-foundation.org>
Subject: [S+Q2 19/19] slub: Drop allocator announcement
References: <20100709190706.938177313@quilx.com>
Content-Disposition: inline; filename=mininum_objects
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

People get confused because of the output and some of the items listed no
longer have the same relevance in the queued form of SLUB.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 mm/slub.c |    8 --------
 1 file changed, 8 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-07-07 10:54:36.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-07-07 10:54:41.000000000 -0500
@@ -3153,14 +3153,6 @@ void __init kmem_cache_init(void)
 #ifdef CONFIG_SMP
 	register_cpu_notifier(&slab_notifier);
 #endif
-
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
