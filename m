Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 72A926004CE
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 15:02:39 -0400 (EDT)
Message-Id: <20100820190236.725984912@linux.com>
Date: Fri, 20 Aug 2010 14:01:56 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [S+Q Core 5/6] slub: Drop allocator announcement
References: <20100820190151.493325014@linux.com>
Content-Disposition: inline; filename=unified_remove_banner
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>
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
--- linux-2.6.orig/mm/slub.c	2010-08-19 16:34:26.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-08-19 16:34:28.000000000 -0500
@@ -3232,12 +3232,6 @@ void __init kmem_cache_init(void)
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
