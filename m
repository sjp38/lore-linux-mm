Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B9CB090008E
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 16:13:08 -0400 (EDT)
Message-Id: <20110415201306.527760040@linux.com>
Date: Fri, 15 Apr 2011 15:13:06 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slubllv333num@/21] slub: Not necessary to check for empty slab on load_freelist
References: <20110415201246.096634892@linux.com>
Content-Disposition: inline; filename=goto_load_freelist
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, linux-mm@kvack.org

Load freelist is now only branched to if there are objects available.
So no need to check.

---
 mm/slub.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-04-01 10:22:56.000000000 -0500
+++ linux-2.6/mm/slub.c	2011-04-01 10:22:58.000000000 -0500
@@ -1976,14 +1976,13 @@ static void *__slab_alloc(struct kmem_ca
 				"__slab_alloc"));
 	}
 
-load_freelist:
-	VM_BUG_ON(!page->frozen);
-
 	if (unlikely(!object)) {
 		c->page = NULL;
 		goto new_slab;
 	}
 
+load_freelist:
+	VM_BUG_ON(!page->frozen);
 	c->freelist = get_freepointer(s, object);
 
 #ifdef CONFIG_CMPXCHG_LOCAL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
