Date: Sat, 5 May 2007 09:26:38 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: SLUB: Reduce antifrag max order
Message-ID: <Pine.LNX.4.64.0705050925350.27136@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
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
--- slub.orig/mm/slub.c	2007-05-05 09:19:32.000000000 -0700
+++ slub/mm/slub.c	2007-05-05 09:22:00.000000000 -0700
@@ -129,7 +129,7 @@
  * If antifragmentation methods are in effect then increase the
  * slab sizes to increase performance
  */
-#define DEFAULT_ANTIFRAG_MAX_ORDER 4
+#define DEFAULT_ANTIFRAG_MAX_ORDER 3
 #define DEFAULT_ANTIFRAG_MIN_OBJECTS 16
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
