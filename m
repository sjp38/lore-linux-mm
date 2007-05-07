Message-Id: <20070507212407.755258367@sgi.com>
References: <20070507212240.254911542@sgi.com>
Date: Mon, 07 May 2007 14:22:42 -0700
From: clameter@sgi.com
Subject: [patch 02/17] SLUB: Reduce antifrag max order
Content-Disposition: inline; filename=reduce_order
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

My test systems fails to obtain order 4 allocs after prolonged use.
So the Antifragmentation patches are unable to guarantee order 4
blocks after a while (straight compile, edit load).

Reduce the the max order if antifrag measures are detected to 3.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-05-07 14:00:23.000000000 -0700
+++ slub/mm/slub.c	2007-05-07 14:00:27.000000000 -0700
@@ -126,7 +126,7 @@
  * If antifragmentation methods are in effect then increase the
  * slab sizes to increase performance
  */
-#define DEFAULT_ANTIFRAG_MAX_ORDER 4
+#define DEFAULT_ANTIFRAG_MAX_ORDER 3
 #define DEFAULT_ANTIFRAG_MIN_OBJECTS 16
 
 /*

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
