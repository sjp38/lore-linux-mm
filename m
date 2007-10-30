Date: Tue, 30 Oct 2007 11:54:55 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: SLUB: Comment kmem_cache_cpu structure
Message-ID: <Pine.LNX.4.64.0710301153580.12730@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Add some comments explaining the fields of the kmem_cache_cpu structure.

Signed-off-by: Chrsitoph Lameter <clameter@sgi.com>

Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2007-10-30 11:51:20.000000000 -0700
+++ linux-2.6/include/linux/slub_def.h	2007-10-30 11:53:48.000000000 -0700
@@ -12,12 +12,12 @@
 #include <linux/kobject.h>
 
 struct kmem_cache_cpu {
-	void **freelist;
-	struct page *page;
-	int node;
-	unsigned int offset;
-	unsigned int objsize;
-	unsigned int objects;
+	void **freelist;	/* Pointer to first free per cpu object */
+	struct page *page;	/* The slab from which we are allocating */
+	int node;		/* The node of the page (or -1 for debug) */
+	unsigned int offset;	/* Freepointer offset (in word units) */
+	unsigned int objsize;	/* Size of an object (from kmem_cache) */
+	unsigned int objects;	/* Objects per slab (from kmem_cache) */
 };
 
 struct kmem_cache_node {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
