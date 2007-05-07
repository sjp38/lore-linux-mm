Message-Id: <20070507212407.987572324@sgi.com>
References: <20070507212240.254911542@sgi.com>
Date: Mon, 07 May 2007 14:22:43 -0700
From: clameter@sgi.com
Subject: [patch 03/17] SLUB: After object padding only needed for Redzoning
Content-Disposition: inline; filename=better_padding
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

If no redzoning is selected then we do not need padding before the
next object.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-05-07 13:51:50.000000000 -0700
+++ slub/mm/slub.c	2007-05-07 13:52:44.000000000 -0700
@@ -1668,7 +1668,7 @@ static int calculate_sizes(struct kmem_c
 		 */
 		size += 2 * sizeof(struct track);
 
-	if (flags & DEBUG_DEFAULT_FLAGS)
+	if (flags & SLAB_RED_ZONE)
 		/*
 		 * Add some empty padding so that we can catch
 		 * overwrites from earlier objects rather than let

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
