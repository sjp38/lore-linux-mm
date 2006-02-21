Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
        by fgwmail5.fujitsu.co.jp (Fujitsu Gateway)
        with ESMTP id k1LC3WWe024293 for <linux-mm@kvack.org>; Tue, 21 Feb 2006 21:03:32 +0900
        (envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s2.gw.fujitsu.co.jp by m5.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id k1LC3T5o019261 for <linux-mm@kvack.org>; Tue, 21 Feb 2006 21:03:29 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s2.gw.fujitsu.co.jp (s2 [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8420E4E00B5
	for <linux-mm@kvack.org>; Tue, 21 Feb 2006 21:03:29 +0900 (JST)
Received: from fjm505.ms.jp.fujitsu.com (fjm505.ms.jp.fujitsu.com [10.56.99.83])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CCCE84E00AA
	for <linux-mm@kvack.org>; Tue, 21 Feb 2006 21:03:28 +0900 (JST)
Received: from [127.0.0.1] (fjmscan503.ms.jp.fujitsu.com [10.56.99.143])by fjm505.ms.jp.fujitsu.com with ESMTP id k1LC36vi007610
	for <linux-mm@kvack.org>; Tue, 21 Feb 2006 21:03:08 +0900
Message-ID: <43FB01E4.5080201@jp.fujitsu.com>
Date: Tue, 21 Feb 2006 21:04:52 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC][PATCH] bdata and pgdat initialization cleanup [3/5] remove
 pgdat->bdata
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Because pgdat is not used in bootmem.c, pgdat->bdata can be removed.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: testtree/include/linux/mmzone.h
===================================================================
--- testtree.orig/include/linux/mmzone.h
+++ testtree/include/linux/mmzone.h
@@ -292,7 +292,6 @@ typedef struct pglist_data {
  #ifdef CONFIG_FLAT_NODE_MEM_MAP
  	struct page *node_mem_map;
  #endif
-	struct bootmem_data *bdata;
  #ifdef CONFIG_MEMORY_HOTPLUG
  	/*
  	 * Must be held any time you expect node_start_pfn, node_present_pages
Index: testtree/mm/page_alloc.c
===================================================================
--- testtree.orig/mm/page_alloc.c
+++ testtree/mm/page_alloc.c
@@ -2224,7 +2224,7 @@ void __init free_area_init_node(int nid,
  }

  #ifndef CONFIG_NEED_MULTIPLE_NODES
-struct pglist_data contig_page_data = { .bdata = BOOTMEM(0)};
+struct pglist_data contig_page_data;

  EXPORT_SYMBOL(contig_page_data);
  #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
