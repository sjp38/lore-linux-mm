Date: Tue, 4 Mar 2008 11:34:05 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: slub statistics: Check the correct value for DEACTIVATE_REMOTE_FREES
Message-ID: <Pine.LNX.4.64.0803041132210.17619@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
From: Christoph Lameter <clameter@sgi.com>
Subject: slub statistics: Check the correct value for DEACTIVATE_REMOTE_FREES
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Cc: Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The remote frees are in the freelist of the page and not in the
percpu freelist.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2008-03-04 11:07:54.000000000 -0800
+++ linux-2.6/mm/slub.c	2008-03-04 11:08:30.000000000 -0800
@@ -1368,7 +1368,7 @@ static void deactivate_slab(struct kmem_
 	struct page *page = c->page;
 	int tail = 1;
 
-	if (c->freelist)
+	if (page->freelist)
 		stat(c, DEACTIVATE_REMOTE_FREES);
 	/*
 	 * Merge cpu freelist into slab freelist. Typically we get here

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
