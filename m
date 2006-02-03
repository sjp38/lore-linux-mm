Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
        by fgwmail6.fujitsu.co.jp (Fujitsu Gateway)
        with ESMTP id k137pCXL019164 for <linux-mm@kvack.org>; Fri, 3 Feb 2006 16:51:12 +0900
        (envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s4.gw.fujitsu.co.jp by m4.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id k137pBHC006565 for <linux-mm@kvack.org>; Fri, 3 Feb 2006 16:51:11 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s4.gw.fujitsu.co.jp (s4 [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 09C751CC144
	for <linux-mm@kvack.org>; Fri,  3 Feb 2006 16:51:11 +0900 (JST)
Received: from fjm504.ms.jp.fujitsu.com (fjm504.ms.jp.fujitsu.com [10.56.99.80])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AC2851CC14C
	for <linux-mm@kvack.org>; Fri,  3 Feb 2006 16:51:10 +0900 (JST)
Received: from [127.0.0.1] (fjmscan503.ms.jp.fujitsu.com [10.56.99.143])by fjm504.ms.jp.fujitsu.com with ESMTP id k137p0RF011842
	for <linux-mm@kvack.org>; Fri, 3 Feb 2006 16:51:01 +0900
Message-ID: <43E30B9F.1030506@jp.fujitsu.com>
Date: Fri, 03 Feb 2006 16:51:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC] peeling off zone from physical memory layout [8/10] power pc
 remove memory fix
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a patch against remove_memory().
I think this patch is not very good, but remove_memory() will fail
in current kernel anyway.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


Index: hogehoge/arch/powerpc/mm/mem.c
===================================================================
--- hogehoge.orig/arch/powerpc/mm/mem.c
+++ hogehoge/arch/powerpc/mm/mem.c
@@ -32,6 +32,7 @@
  #include <linux/highmem.h>
  #include <linux/initrd.h>
  #include <linux/pagemap.h>
+#include <linux/memorymap.h>

  #include <asm/pgalloc.h>
  #include <asm/prom.h>
@@ -163,7 +164,7 @@ int __devinit remove_memory(u64 start, u
  	 * not handling removing memory ranges that
  	 * overlap multiple zones yet
  	 */
-	if (end_pfn > (zone->zone_start_pfn + zone->spanned_pages))
+	if (page_zone(pfn_to_page(start_pfn)) != page_zone(pfn_to_page(end_pfn - 1))
  		goto overlap;

  	/* make sure it is NOT in RMO */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
