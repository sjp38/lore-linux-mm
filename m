Date: Sat, 10 Dec 2005 20:02:47 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch] New zone ZONE_EASY_RECLAIM take 3. (define ZONE_EASY_RECLAIM)[2/5]
Message-Id: <20051210193849.4828.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>
Cc: Joel Schopp <jschopp@austin.ibm.com>
List-ID: <linux-mm.kvack.org>

This defines new zone ZONE_EASY_RECLAIM.
ZONES_SHIFT becomes 3.
And this patch add member of sysctl_lowmem_reserve_ratio[].

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

Index: zone_reclaim/include/linux/mmzone.h
===================================================================
--- zone_reclaim.orig/include/linux/mmzone.h	2005-12-10 17:12:58.000000000 +0900
+++ zone_reclaim/include/linux/mmzone.h	2005-12-10 17:13:16.000000000 +0900
@@ -73,9 +73,10 @@ struct per_cpu_pageset {
 #define ZONE_DMA32		1
 #define ZONE_NORMAL		2
 #define ZONE_HIGHMEM		3
+#define ZONE_EASY_RECLAIM	4
 
-#define MAX_NR_ZONES		4	/* Sync this with ZONES_SHIFT */
-#define ZONES_SHIFT		2	/* ceil(log2(MAX_NR_ZONES)) */
+#define MAX_NR_ZONES		5	/* Sync this with ZONES_SHIFT */
+#define ZONES_SHIFT		3	/* ceil(log2(MAX_NR_ZONES)) */
 
 
 /*
Index: zone_reclaim/mm/page_alloc.c
===================================================================
--- zone_reclaim.orig/mm/page_alloc.c	2005-12-10 17:13:15.000000000 +0900
+++ zone_reclaim/mm/page_alloc.c	2005-12-10 17:15:10.000000000 +0900
@@ -66,7 +66,7 @@ static void fastcall free_hot_cold_page(
  * TBD: should special case ZONE_DMA32 machines here - in those we normally
  * don't need any ZONE_NORMAL reservation
  */
-int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1] = { 256, 256, 32 };
+int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1] = { 256, 256, 256, 32 ,32};
 
 EXPORT_SYMBOL(totalram_pages);
 
@@ -77,7 +77,7 @@ EXPORT_SYMBOL(totalram_pages);
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
