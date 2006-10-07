Date: Fri, 6 Oct 2006 20:43:38 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Remove wrongly places BUG_ON
Message-ID: <Pine.LNX.4.64.0610062040050.17822@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Init list is called with a list parameter that is not equal to the
cachep->nodelists entry under NUMA if more than one node exists. This is 
fully legitimatei. One may want to populate the list fields before
switching nodelist pointers.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-mm3/mm/slab.c
===================================================================
--- linux-2.6.18-mm3.orig/mm/slab.c	2006-10-06 18:21:27.611390215 -0700
+++ linux-2.6.18-mm3/mm/slab.c	2006-10-06 19:53:55.604410465 -0700
@@ -1331,7 +1331,6 @@ static void init_list(struct kmem_cache 
 {
 	struct kmem_list3 *ptr;
 
-	BUG_ON(cachep->nodelists[nodeid] != list);
 	ptr = kmalloc_node(sizeof(struct kmem_list3), GFP_KERNEL, nodeid);
 	BUG_ON(!ptr);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
