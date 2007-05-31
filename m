Message-Id: <20070531003012.765913558@sgi.com>
References: <20070531002047.702473071@sgi.com>
Date: Wed, 30 May 2007 17:20:50 -0700
From: clameter@sgi.com
Subject: [RFC 3/4] CONFIG_STABLE: Switch off SLUB banner
Content-Disposition: inline; filename=stable_no_slub_banner
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

The one line that SLUB prints on bootup is useful for debugging but I do not
think that we would like to have it on in stable kernels.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-05-30 16:40:04.000000000 -0700
+++ slub/mm/slub.c	2007-05-30 16:40:40.000000000 -0700
@@ -2518,12 +2518,13 @@ void __init kmem_cache_init(void)
 
 	kmem_size = offsetof(struct kmem_cache, cpu_slab) +
 				nr_cpu_ids * sizeof(struct page *);
-
+#ifndef CONFIG_STABLE
 	printk(KERN_INFO "SLUB: Genslabs=%d, HWalign=%d, Order=%d-%d, MinObjects=%d,"
 		" Processors=%d, Nodes=%d\n",
 		KMALLOC_SHIFT_HIGH, cache_line_size(),
 		slub_min_order, slub_max_order, slub_min_objects,
 		nr_cpu_ids, nr_node_ids);
+#endif
 }
 
 /*

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
