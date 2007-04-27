Message-Id: <20070427042907.523406996@sgi.com>
References: <20070427042655.019305162@sgi.com>
Date: Thu, 26 Apr 2007 21:26:56 -0700
From: clameter@sgi.com
Subject: [patch 01/10] SLUB: Remove duplicate VM_BUG_ON
Content-Disposition: inline; filename=slub_duplicate
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Somehow this artifact got in during merge with mm.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc7-mm1/mm/slub.c
===================================================================
--- linux-2.6.21-rc7-mm1.orig/mm/slub.c	2007-04-25 09:48:40.000000000 -0700
+++ linux-2.6.21-rc7-mm1/mm/slub.c	2007-04-25 09:48:47.000000000 -0700
@@ -633,8 +633,6 @@ static void add_full(struct kmem_cache *
 
 	VM_BUG_ON(!irqs_disabled());
 
-	VM_BUG_ON(!irqs_disabled());
-
 	if (!(s->flags & SLAB_STORE_USER))
 		return;
 

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
