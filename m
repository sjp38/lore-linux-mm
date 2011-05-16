Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 891BA6B0025
	for <linux-mm@kvack.org>; Mon, 16 May 2011 16:26:26 -0400 (EDT)
Message-Id: <20110516202621.693228967@linux.com>
Date: Mon, 16 May 2011 15:26:06 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slubllv5 01/25] slub: Avoid warning for !CONFIG_SLUB_DEBUG
References: <20110516202605.274023469@linux.com>
Content-Disposition: inline; filename=fixup33
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

Move the #ifdef so that get_map is only defined if CONFIG_SLUB_DEBUG is defined.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-05-12 11:38:42.000000000 -0500
+++ linux-2.6/mm/slub.c	2011-05-12 11:39:40.000000000 -0500
@@ -326,6 +326,7 @@ static inline int oo_objects(struct kmem
 	return x.x & OO_MASK;
 }
 
+#ifdef CONFIG_SLUB_DEBUG
 /*
  * Determine a map of object in use on a page.
  *
@@ -341,7 +342,6 @@ static void get_map(struct kmem_cache *s
 		set_bit(slab_index(p, s, addr), map);
 }
 
-#ifdef CONFIG_SLUB_DEBUG
 /*
  * Debug settings:
  */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
