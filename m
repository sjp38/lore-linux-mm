From: Magnus Damm <magnus@valinux.co.jp>
Message-Id: <20051005082911.4287.58960.sendpatchset@cherry.local>
Subject: [PATCH] remove MAX_NODES_SHIFT
Date: Wed,  5 Oct 2005 17:29:42 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Magnus Damm <magnus@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

Remove old unused MAX_NODES_SHIFT definition.

Signed-off-by: Magnus Damm <magnus@valinux.co.jp>
---

Applies on top of linux-2.6.14-rc2-git8-mhp1

--- from-0054/include/linux/mmzone.h
+++ to-work/include/linux/mmzone.h	2005-10-04 15:59:37.000000000 +0900
@@ -384,7 +384,6 @@ int lowmem_reserve_ratio_sysctl_handler(
 extern struct pglist_data contig_page_data;
 #define NODE_DATA(nid)		(&contig_page_data)
 #define NODE_MEM_MAP(nid)	mem_map
-#define MAX_NODES_SHIFT		1
 #define pfn_to_nid(pfn)		(0)
 
 #else /* CONFIG_NEED_MULTIPLE_NODES */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
