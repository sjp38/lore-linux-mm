Date: Tue, 28 Nov 2006 16:44:31 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20061129004431.11682.86014.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20061129004426.11682.36688.sendpatchset@schroedinger.engr.sgi.com>
References: <20061129004426.11682.36688.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 1/8] Get rid of SLAB_NO_GROW
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

Get rid of SLAB_NO_GROW

It is only used internally in the slab.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.19-rc6-mm1/include/linux/slab.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/include/linux/slab.h	2006-11-28 16:04:12.000000000 -0800
+++ linux-2.6.19-rc6-mm1/include/linux/slab.h	2006-11-28 16:05:20.000000000 -0800
@@ -26,8 +26,6 @@
 
 #define SLAB_LEVEL_MASK		GFP_LEVEL_MASK
 
-#define	SLAB_NO_GROW		__GFP_NO_GROW	/* don't grow a cache */
-
 /* flags to pass to kmem_cache_create().
  * The first 3 are only valid when the allocator as been build
  * SLAB_DEBUG_SUPPORT.
Index: linux-2.6.19-rc6-mm1/mm/slab.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/mm/slab.c	2006-11-28 16:04:12.000000000 -0800
+++ linux-2.6.19-rc6-mm1/mm/slab.c	2006-11-28 16:05:04.000000000 -0800
@@ -2725,8 +2725,8 @@
 	 * Be lazy and only check for valid flags here,  keeping it out of the
 	 * critical path in kmem_cache_alloc().
 	 */
-	BUG_ON(flags & ~(SLAB_DMA | SLAB_LEVEL_MASK | SLAB_NO_GROW));
-	if (flags & SLAB_NO_GROW)
+	BUG_ON(flags & ~(SLAB_DMA | SLAB_LEVEL_MASK | __GFP_NO_GROW));
+	if (flags & __GFP_NO_GROW)
 		return 0;
 
 	ctor_flags = SLAB_CTOR_CONSTRUCTOR;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
