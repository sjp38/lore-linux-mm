From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070410191931.8011.67905.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070410191910.8011.76133.sendpatchset@schroedinger.engr.sgi.com>
References: <20070410191910.8011.76133.sendpatchset@schroedinger.engr.sgi.com>
Subject: [SLUB 5/5] Drop version number
Date: Tue, 10 Apr 2007 12:19:31 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Drop the version number since we do not have to manage patchsets anymore.

I hope that the set of features for SLUB is complete now.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc6-mm1/mm/slub.c
===================================================================
--- linux-2.6.21-rc6-mm1.orig/mm/slub.c	2007-04-09 22:32:21.000000000 -0700
+++ linux-2.6.21-rc6-mm1/mm/slub.c	2007-04-09 22:32:37.000000000 -0700
@@ -2042,7 +2042,7 @@ void __init kmem_cache_init(void)
 		kmem_size = offsetof(struct kmem_cache, cpu_slab)
 			 + nr_cpu_ids * sizeof(struct page *);
 
-	printk(KERN_INFO "SLUB V6: General Slabs=%d, HW alignment=%d, "
+	printk(KERN_INFO "SLUB: General Slabs=%d, HW alignment=%d, "
 		"Processors=%d, Nodes=%d\n",
 		KMALLOC_SHIFT_HIGH, L1_CACHE_BYTES,
 		nr_cpu_ids, nr_node_ids);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
