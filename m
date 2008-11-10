Message-Id: <20081110133840.557025000@suse.de>
References: <20081110133515.011510000@suse.de>
Date: Tue, 11 Nov 2008 00:35:16 +1100
From: npiggin@suse.de
Subject: [patch 1/7] mm: vmalloc allocator off by one
Content-Disposition: inline; filename=mm-vmalloc-gap-fix.patch
Sender: owner-linux-mm@kvack.org
From: Nick Piggin <npiggin@suse.de>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, glommer@redhat.com
List-ID: <linux-mm.kvack.org>

Fix off by one bug in the KVA allocator that can leave gaps in the
address space.
 
Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/mm/vmalloc.c
===================================================================
--- linux-2.6.orig/mm/vmalloc.c
+++ linux-2.6/mm/vmalloc.c
@@ -362,7 +362,7 @@ retry:
 				goto found;
 		}
 
-		while (addr + size >= first->va_start && addr + size <= vend) {
+		while (addr + size > first->va_start && addr + size <= vend) {
 			addr = ALIGN(first->va_end + PAGE_SIZE, align);
 
 			n = rb_next(&first->rb_node);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
