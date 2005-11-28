Date: Mon, 28 Nov 2005 20:36:19 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch] New zone ZONE_EASY_RECLAIM take 2[2/5]
Message-Id: <20051128200153.5D7C.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>
Cc: Joel Schopp <jschopp@austin.ibm.com>, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This defines new zone ZONE_EASY_RECLAIM.
ZONES_SHIFT becomes 3.

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

Index: new_zone_mm/include/linux/mmzone.h
===================================================================
--- new_zone_mm.orig/include/linux/mmzone.h	2005-11-17 16:57:15.000000000 +0900
+++ new_zone_mm/include/linux/mmzone.h	2005-11-17 17:07:30.000000000 +0900
@@ -74,9 +74,10 @@ struct per_cpu_pageset {
 #define ZONE_DMA32		1
 #define ZONE_NORMAL		2
 #define ZONE_HIGHMEM		3
+#define ZONE_EASY_RECLAIM	4
 
-#define MAX_NR_ZONES		4	/* Sync this with ZONES_SHIFT */
-#define ZONES_SHIFT		2	/* ceil(log2(MAX_NR_ZONES)) */
+#define MAX_NR_ZONES		5	/* Sync this with ZONES_SHIFT */
+#define ZONES_SHIFT		3	/* ceil(log2(MAX_NR_ZONES)) */
 
 
 /*
Index: new_zone_mm/mm/page_alloc.c
===================================================================
--- new_zone_mm.orig/mm/page_alloc.c	2005-11-17 17:05:12.000000000 +0900
+++ new_zone_mm/mm/page_alloc.c	2005-11-17 17:08:17.000000000 +0900
@@ -75,7 +75,7 @@ EXPORT_SYMBOL(totalram_pages);
 struct zone *zone_table[1 << ZONETABLE_SHIFT] __read_mostly;
 EXPORT_SYMBOL(zone_table);
 
-static char *zone_names[MAX_NR_ZONES] = { "DMA", "DMA32", "Normal", "HighMem" };
+static char *zone_names[MAX_NR_ZONES] = { "DMA", "DMA32", "Normal", "HighMem", "Easy Reclaim"};
 int min_free_kbytes = 1024;
 
 unsigned long __initdata nr_kernel_pages;

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
