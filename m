Message-Id: <20070427202901.324657488@sgi.com>
References: <20070427202137.613097336@sgi.com>
Date: Fri, 27 Apr 2007 13:21:45 -0700
From: clameter@sgi.com
Subject: [patch 8/8] SLUB printk cleanup: Slab validation printks
Content-Disposition: inline; filename=slub_printk_validate_slab
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

---
 mm/slub.c |   19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-04-27 10:37:42.000000000 -0700
+++ slub/mm/slub.c	2007-04-27 10:38:47.000000000 -0700
@@ -2729,17 +2729,17 @@ static void validate_slab_slab(struct km
 		validate_slab(s, page);
 		slab_unlock(page);
 	} else
-		printk(KERN_INFO "SLUB: %s Skipped busy slab %p\n",
+		printk(KERN_INFO "SLUB %s: Skipped busy slab 0x%p\n",
 			s->name, page);
 
 	if (s->flags & DEBUG_DEFAULT_FLAGS) {
 		if (!PageError(page))
-			printk(KERN_ERR "SLUB: %s PageError not set "
-				"on slab %p\n", s->name, page);
+			printk(KERN_ERR "SLUB %s: PageError not set "
+				"on slab 0x%p\n", s->name, page);
 	} else {
 		if (PageError(page))
-			printk(KERN_ERR "SLUB: %s PageError set on "
-				"slab %p\n", s->name, page);
+			printk(KERN_ERR "SLUB %s: PageError set on "
+				"slab 0x%p\n", s->name, page);
 	}
 }
 
@@ -2756,8 +2756,8 @@ static int validate_slab_node(struct kme
 		count++;
 	}
 	if (count != n->nr_partial)
-		printk("SLUB: %s %ld partial slabs counted but counter=%ld\n",
-			s->name, count, n->nr_partial);
+		printk(KERN_ERR "SLUB %s: %ld partial slabs counted but "
+			"counter=%ld\n", s->name, count, n->nr_partial);
 
 	if (!(s->flags & SLAB_STORE_USER))
 		goto out;
@@ -2767,8 +2767,9 @@ static int validate_slab_node(struct kme
 		count++;
 	}
 	if (count != atomic_long_read(&n->nr_slabs))
-		printk("SLUB: %s %ld slabs counted but counter=%ld\n",
-		s->name, count, atomic_long_read(&n->nr_slabs));
+		printk(KERN_ERR "SLUB: %s %ld slabs counted but "
+			"counter=%ld\n", s->name, count,
+			atomic_long_read(&n->nr_slabs));
 
 out:
 	spin_unlock_irqrestore(&n->list_lock, flags);

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
