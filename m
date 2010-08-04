Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D9BCD660025
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 22:45:34 -0400 (EDT)
Message-Id: <20100804024534.202416229@linux.com>
Date: Tue, 03 Aug 2010 21:45:32 -0500
From: Christoph Lameter <cl@linux-foundation.org>
Subject: [S+Q3 18/23] slub: Drop allocator announcement
References: <20100804024514.139976032@linux.com>
Content-Disposition: inline; filename=unified_remove_banner
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

People get confused because the output repeats some basic hardware
configuration values. Some of the items listed no
longer have the same relevance in the queued form of SLUB.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 mm/slub.c |    7 -------
 1 file changed, 7 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-07-30 18:45:28.628439648 -0500
+++ linux-2.6/mm/slub.c	2010-07-30 18:45:32.632522338 -0500
@@ -3229,13 +3229,6 @@
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
 }
 
 void __init kmem_cache_init_late(void)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
