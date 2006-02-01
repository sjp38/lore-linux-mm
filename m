Message-ID: <43E02B29.70304@jp.fujitsu.com>
Date: Wed, 01 Feb 2006 12:29:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC][PATCH] remove zone_mem_map [4/4] compile fix
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: "Martin J. Bligh" <mbligh@mbligh.org>
List-ID: <linux-mm.kvack.org>

Becuse zone doesn't contain struct page* mamber.
This patch is needed to compile memory_hotplug.h which is inculded
by mmzone.h. Modifying including order is better ?

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: hogehoge/include/linux/mmzone.h
===================================================================
--- hogehoge.orig/include/linux/mmzone.h
+++ hogehoge/include/linux/mmzone.h
@@ -105,7 +105,7 @@ struct per_cpu_pageset {
   * ZONE_NORMAL	16-896 MB	direct mapped by the kernel
   * ZONE_HIGHMEM	 > 896 MB	only page cache and user processes
   */
-
+struct page;
  struct zone {
  	/* Fields commonly accessed by the page allocator */
  	unsigned long		free_pages;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
