Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7B96D6B006A
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 15:45:17 -0400 (EDT)
Message-Id: <20101005185815.287555262@linux.com>
Date: Tue, 05 Oct 2010 13:57:31 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [UnifiedV4 06/16] slub: Drop allocator announcement
References: <20101005185725.088808842@linux.com>
Content-Disposition: inline; filename=unified_remove_banner
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

People get confused because the output repeats some basic hardware
configuration values. Some of the items listed no
longer have the same relevance in the queued form of SLUB.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 mm/slub.c |    6 ------
 1 file changed, 6 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-10-02 18:10:45.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-10-02 18:10:50.000000000 -0500
@@ -3249,12 +3249,6 @@ void __init kmem_cache_init(void)
 		}
 	}
 #endif
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
