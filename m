Message-Id: <20070427202900.377339277@sgi.com>
References: <20070427202137.613097336@sgi.com>
Date: Fri, 27 Apr 2007 13:21:41 -0700
From: clameter@sgi.com
Subject: [patch 4/8] SLUB printk cleanup: object_err()
Content-Disposition: inline; filename=slub_printk_object_err
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

---
 mm/slub.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-04-27 10:31:55.000000000 -0700
+++ slub/mm/slub.c	2007-04-27 12:46:48.000000000 -0700
@@ -356,8 +356,8 @@ static void object_err(struct kmem_cache
 {
 	u8 *addr = page_address(page);
 
-	printk(KERN_ERR "*** SLUB: %s in %s@0x%p slab 0x%p\n",
-			reason, s->name, object, page);
+	printk(KERN_ERR "*** SLUB %s: %s@0x%p slab 0x%p\n",
+			s->name, reason, object, page);
 	printk(KERN_ERR "    offset=%tu flags=0x%04lx inuse=%u freelist=0x%p\n",
 		object - addr, page->flags, page->inuse, page->freelist);
 	if (object > addr + 16)

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
