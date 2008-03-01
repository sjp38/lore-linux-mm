Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [150.166.1.51])
	by relay1.corp.sgi.com (Postfix) with ESMTP id 797838F80B1
	for <linux-mm@kvack.org>; Fri, 29 Feb 2008 20:08:16 -0800 (PST)
Received: from clameter by schroedinger.engr.sgi.com with local (Exim 3.36 #1 (Debian))
	id 1JVJ1E-0004Yz-00
	for <linux-mm@kvack.org>; Fri, 29 Feb 2008 20:08:16 -0800
Message-Id: <20080301040816.181088085@sgi.com>
References: <20080301040755.268426038@sgi.com>
Date: Fri, 29 Feb 2008 20:08:04 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [rfc 09/10] Get rid of __ZONE_COUNT
Content-Disposition: inline; filename=max_zones_get_rid_of___zone_count
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

It was used to compensate because MAX_NR_ZONES was not available
to the #ifdefs.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/mmzone.h |   19 +++----------------
 1 file changed, 3 insertions(+), 16 deletions(-)

Index: linux-2.6/include/linux/mmzone.h
===================================================================
--- linux-2.6.orig/include/linux/mmzone.h	2008-02-29 19:34:28.000000000 -0800
+++ linux-2.6/include/linux/mmzone.h	2008-02-29 19:35:32.000000000 -0800
@@ -189,28 +189,15 @@ enum zone_type {
  * match the requested limits. See gfp_zone() in include/linux/gfp.h
  */
 
-/*
- * Count the active zones.  Note that the use of defined(X) outside
- * #if and family is not necessarily defined so ensure we cannot use
- * it later.  Use __ZONE_COUNT to work out how many shift bits we need.
- */
-#define __ZONE_COUNT (			\
-	  defined(CONFIG_ZONE_DMA)	\
-	+ defined(CONFIG_ZONE_DMA32)	\
-	+ 1				\
-	+ defined(CONFIG_HIGHMEM)	\
-	+ 1				\
-)
-#if __ZONE_COUNT < 2
+#if MAX_NR_ZONES < 2
 #define ZONES_SHIFT 0
-#elif __ZONE_COUNT <= 2
+#elif MAX_NR_ZONES <= 2
 #define ZONES_SHIFT 1
-#elif __ZONE_COUNT <= 4
+#elif MAX_NR_ZONES <= 4
 #define ZONES_SHIFT 2
 #else
 #error ZONES_SHIFT -- too many zones configured adjust calculation
 #endif
-#undef __ZONE_COUNT
 
 struct zone {
 	/* Fields commonly accessed by the page allocator */

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
