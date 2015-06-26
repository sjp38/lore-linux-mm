Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id B41C66B0038
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 21:44:40 -0400 (EDT)
Received: by padev16 with SMTP id ev16so59553496pad.0
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 18:44:40 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id ml1si47805721pab.24.2015.06.25.18.44.38
        for <linux-mm@kvack.org>;
        Thu, 25 Jun 2015 18:44:39 -0700 (PDT)
From: minkyung88.kim@lge.com
Subject: [PATCH] mm: remove struct node_active_region
Date: Fri, 26 Jun 2015 10:44:01 +0900
Message-Id: <1435283041-17401-1-git-send-email-minkyung88.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org
Cc: Seungho Park <seungho1.park@lge.com>, kmk3210@gmail.com, "minkyung88.kim" <minkyung88.kim@lge.com>

From: "minkyung88.kim" <minkyung88.kim@lge.com>

struct node_active_region is not used anymore.
Remove it.

Signed-off-by: minkyung88.kim <minkyung88.kim@lge.com>
---
 include/linux/mmzone.h |    8 --------
 1 file changed, 8 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 54d74f6..6f53d1d 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -690,14 +690,6 @@ struct zonelist {
 #endif
 };
 
-#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
-struct node_active_region {
-	unsigned long start_pfn;
-	unsigned long end_pfn;
-	int nid;
-};
-#endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
-
 #ifndef CONFIG_DISCONTIGMEM
 /* The array of struct pages - for discontigmem use pgdat->lmem_map */
 extern struct page *mem_map;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
