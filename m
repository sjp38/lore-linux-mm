Date: Fri, 22 Jun 2007 11:02:17 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: slab allocators: MAX_ORDER one off fix
Message-ID: <Pine.LNX.4.64.0706221100270.17293@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

MAX_ORDER is the first order that is not possible.

Use MAX_ORDER - 1 to calculate the larges possible object size in slab.h

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/slab.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6.22-rc4-mm2/include/linux/slab.h
===================================================================
--- linux-2.6.22-rc4-mm2.orig/include/linux/slab.h	2007-06-22 10:46:12.000000000 -0700
+++ linux-2.6.22-rc4-mm2/include/linux/slab.h	2007-06-22 10:46:53.000000000 -0700
@@ -133,8 +133,8 @@ static inline void *kmem_cache_alloc_nod
  * to do various tricks to work around compiler limitations in order to
  * ensure proper constant folding.
  */
-#define KMALLOC_SHIFT_HIGH	((MAX_ORDER + PAGE_SHIFT) <= 25 ? \
-				(MAX_ORDER + PAGE_SHIFT) : 25)
+#define KMALLOC_SHIFT_HIGH	((MAX_ORDER + PAGE_SHIFT - 1) <= 25 ? \
+				(MAX_ORDER + PAGE_SHIFT - 1) : 25)
 
 #define KMALLOC_MAX_SIZE	(1UL << KMALLOC_SHIFT_HIGH)
 #define KMALLOC_MAX_ORDER	(KMALLOC_SHIFT_HIGH - PAGE_SHIFT)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
