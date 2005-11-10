Date: Thu, 10 Nov 2005 19:41:01 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch:RFC] New zone ZONE_EASY_RECLAIM[2/5]
Message-Id: <20051110185812.0232.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

This defines new zone ZONE_EASY_RECLAIM.

Note:
  I found DMA32_ZONE is included in -mm tree.
  If one more new zone is created before/after my patch, 
  the zone number field in page->flags is not enough.
  My patch doesn't care about it yet.


Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

---

Index: new_zone/include/linux/mmzone.h
===================================================================
--- new_zone.orig/include/linux/mmzone.h	2005-11-07 19:28:25.000000000 +0900
+++ new_zone/include/linux/mmzone.h	2005-11-07 19:30:07.000000000 +0900
@@ -72,8 +72,9 @@ struct per_cpu_pageset {
 #define ZONE_DMA		0
 #define ZONE_NORMAL		1
 #define ZONE_HIGHMEM		2
+#define ZONE_EASY_RECLAIM	3
 
-#define MAX_NR_ZONES		3	/* Sync this with ZONES_SHIFT */
+#define MAX_NR_ZONES		4	/* Sync this with ZONES_SHIFT */
 #define ZONES_SHIFT		2	/* ceil(log2(MAX_NR_ZONES)) */
 
 
Index: new_zone/mm/page_alloc.c
===================================================================
--- new_zone.orig/mm/page_alloc.c	2005-11-07 19:28:31.000000000 +0900
+++ new_zone/mm/page_alloc.c	2005-11-07 19:29:17.000000000 +0900
@@ -72,7 +72,7 @@ EXPORT_SYMBOL(nr_swap_pages);
 struct zone *zone_table[1 << ZONETABLE_SHIFT] __read_mostly;
 EXPORT_SYMBOL(zone_table);
 
-static char *zone_names[MAX_NR_ZONES] = { "DMA", "Normal", "HighMem" };
+static char *zone_names[MAX_NR_ZONES] = { "DMA", "Normal", "HighMem", "Easy Reclaim" };
 int min_free_kbytes = 1024;
 
 unsigned long __initdata nr_kernel_pages;

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
