Message-Id: <20081108022013.885317000@nick.local0.net>
References: <20081108021512.686515000@suse.de>
Date: Sat, 08 Nov 2008 13:15:16 +1100
From: npiggin@suse.de
Subject: [patch 4/9] mm: vmalloc tweak failure printk
Content-Disposition: inline; filename=mm-vmalloc-tweak-output.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, torvalds@linux-foundation.org
Cc: linux-mm@kvack.org, glommer@redhat.com, rjw@sisk.pl
List-ID: <linux-mm.kvack.org>

If we can't service a vmalloc allocation, show size of the allocation that
actually failed. Useful for debugging.

Signed-off-by: Glauber Costa <glommer@redhat.com>
Signed-off-by: Nick Piggin <npiggin@suse.de>
---
 mm/vmalloc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6/mm/vmalloc.c
===================================================================
--- linux-2.6.orig/mm/vmalloc.c
+++ linux-2.6/mm/vmalloc.c
@@ -381,8 +381,9 @@ found:
 			goto retry;
 		}
 		if (printk_ratelimit())
-			printk(KERN_WARNING "vmap allocation failed: "
-				 "use vmalloc=<size> to increase size.\n");
+			printk(KERN_WARNING
+				"vmap allocation for size %lu failed: "
+				"use vmalloc=<size> to increase size.\n", size);
 		return ERR_PTR(-EBUSY);
 	}
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
