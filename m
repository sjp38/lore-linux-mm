Date: Thu, 10 Nov 2005 19:40:48 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch:RFC] New zone ZONE_EASY_RECLAIM[1/5]
Message-Id: <20051110185836.0234.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

This defines __GFP flag for new zone.

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

---

Index: new_zone/include/linux/gfp.h
===================================================================
--- new_zone.orig/include/linux/gfp.h	2005-11-08 14:17:57.000000000 +0900
+++ new_zone/include/linux/gfp.h	2005-11-08 17:24:20.000000000 +0900
@@ -14,6 +14,7 @@ struct vm_area_struct;
 /* Zone modifiers in GFP_ZONEMASK (see linux/mmzone.h - low two bits) */
 #define __GFP_DMA	0x01u
 #define __GFP_HIGHMEM	0x02u
+#define __GFP_EASY_RECLAIM 0x04u
 
 /*
  * Action modifiers - doesn't change the zoning
@@ -57,7 +58,7 @@ struct vm_area_struct;
 #define GFP_KERNEL	(__GFP_WAIT | __GFP_IO | __GFP_FS)
 #define GFP_USER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL)
 #define GFP_HIGHUSER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL | \
-			 __GFP_HIGHMEM)
+			 __GFP_HIGHMEM | __GFP_EASY_RECLAIM)
 
 /* Flag - indicates that the buffer will be suitable for DMA.  Ignored on some
    platforms, used as appropriate on others */
Index: new_zone/include/linux/mmzone.h
===================================================================
--- new_zone.orig/include/linux/mmzone.h	2005-11-08 14:17:57.000000000 +0900
+++ new_zone/include/linux/mmzone.h	2005-11-08 17:23:23.000000000 +0900
@@ -90,7 +90,7 @@ struct per_cpu_pageset {
  * be 8 (2 ** 3) zonelists.  GFP_ZONETYPES defines the number of possible
  * combinations of zone modifiers in "zone modifier space".
  */
-#define GFP_ZONEMASK	0x03
+#define GFP_ZONEMASK	0x07
 /*
  * As an optimisation any zone modifier bits which are only valid when
  * no other zone modifier bits are set (loners) should be placed in

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
