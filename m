Date: Fri, 6 Jul 2007 12:45:55 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: SLUB: Style fix up the loop to disable small slabs
Message-ID: <Pine.LNX.4.64.0707061245120.24255@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Do proper spacing and we only need to do this in steps of 8.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.22-rc6-mm1/mm/slub.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/mm/slub.c	2007-07-03 17:27:22.000000000 -0700
+++ linux-2.6.22-rc6-mm1/mm/slub.c	2007-07-03 17:27:34.000000000 -0700
@@ -2600,7 +2600,7 @@ void __init kmem_cache_init(void)
 	BUILD_BUG_ON(KMALLOC_MIN_SIZE > 256 ||
 		(KMALLOC_MIN_SIZE & (KMALLOC_MIN_SIZE - 1)));
 
-	for (i = 8; i < KMALLOC_MIN_SIZE;i++)
+	for (i = 8; i < KMALLOC_MIN_SIZE; i += 8)
 		size_index[(i - 1) / 8] = KMALLOC_SHIFT_LOW;
 
 	slab_state = UP;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
