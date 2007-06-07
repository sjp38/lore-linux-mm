Date: Thu, 7 Jun 2007 13:59:42 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: SLUB: Remove useless EXPORT_SYMBOL
Message-ID: <Pine.LNX.4.64.0706071358410.26516@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

kmem_cache_open is static. EXPORT_SYMBOL was leftover from some earlier 
time period where kmem_cache_open was usable outside of slub.

Signed-off-by: Chrsitoph Lameter <clameter@sgi.com>

---
 mm/slub.c |    1 -
 1 file changed, 1 deletion(-)

Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-06-04 19:41:57.000000000 -0700
+++ slub/mm/slub.c	2007-06-04 19:41:58.000000000 -0700
@@ -2084,7 +2084,6 @@ error:
 			s->offset, flags);
 	return 0;
 }
-EXPORT_SYMBOL(kmem_cache_open);
 
 /*
  * Check if a given pointer is valid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
