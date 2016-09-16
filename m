Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id C254C6B0069
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 23:21:42 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 184so28436890ity.1
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 20:21:42 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id f124si1703590iof.153.2016.09.15.20.21.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Sep 2016 20:21:42 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id n24so3005710pfb.3
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 20:21:42 -0700 (PDT)
From: Wanlong Gao <wanlong.gao@gmail.com>
Subject: [PATCH] mm: nobootmem: move the comment of free_all_bootmem
Date: Fri, 16 Sep 2016 11:21:22 +0800
Message-Id: <1473996082-14603-1-git-send-email-wanlong.gao@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, Wanlong Gao <wanlong.gao@gmail.com>

The commit b4def3509d18c1db9198f92d4c35065e029a09a1 removed
the unnecessary nodeid argument, after that, this comment
becomes more confused. We should move it to the right place.

Signed-off-by: Wanlong Gao <wanlong.gao@gmail.com>
---
 mm/nobootmem.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index bd05a70..8bfa986 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -134,6 +134,11 @@ static unsigned long __init free_low_memory_core_early(void)
 	for_each_reserved_mem_region(i, &start, &end)
 		reserve_bootmem_region(start, end);
 
+	/*
+	 * We need to use NUMA_NO_NODE instead of NODE_DATA(0)->node_id
+	 *  because in some case like Node0 doesn't have RAM installed
+	 *  low ram will be on Node1
+	 */
 	for_each_free_mem_range(i, NUMA_NO_NODE, MEMBLOCK_NONE, &start, &end,
 				NULL)
 		count += __free_memory_core(start, end);
@@ -191,11 +196,6 @@ unsigned long __init free_all_bootmem(void)
 
 	reset_all_zones_managed_pages();
 
-	/*
-	 * We need to use NUMA_NO_NODE instead of NODE_DATA(0)->node_id
-	 *  because in some case like Node0 doesn't have RAM installed
-	 *  low ram will be on Node1
-	 */
 	pages = free_low_memory_core_early();
 	totalram_pages += pages;
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
