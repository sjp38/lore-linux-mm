From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070413013633.17093.93334.sendpatchset@schroedinger.engr.sgi.com>
Subject: [SLUB 1/5] Fix validation
Date: Thu, 12 Apr 2007 18:36:33 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Some parts of object validation will never occur because on_freelist
does return the wrong exit code for a NULL object.

Fix that.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc6/mm/slub.c
===================================================================
--- linux-2.6.21-rc6.orig/mm/slub.c	2007-04-12 15:06:54.000000000 -0700
+++ linux-2.6.21-rc6/mm/slub.c	2007-04-12 15:07:23.000000000 -0700
@@ -588,7 +588,7 @@ static int on_freelist(struct kmem_cache
 			s->objects - nr);
 		page->inuse = s->objects - nr;
 	}
-	return 0;
+	return search == NULL;
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
