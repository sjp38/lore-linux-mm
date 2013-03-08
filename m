Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 7DE486B0006
	for <linux-mm@kvack.org>; Fri,  8 Mar 2013 10:52:54 -0500 (EST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH 1/2] mm: walk_memory_range: Fix typo in comment
Date: Fri,  8 Mar 2013 08:41:40 -0700
Message-Id: <1362757301-18550-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, Toshi Kani <toshi.kani@hp.com>

Fix a typo "end_pft" in the comment of walk_memory_range().

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 mm/memory_hotplug.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b81a367b..ae7bcba 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1613,7 +1613,7 @@ int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
 /**
  * walk_memory_range - walks through all mem sections in [start_pfn, end_pfn)
  * @start_pfn: start pfn of the memory range
- * @end_pfn: end pft of the memory range
+ * @end_pfn: end pfn of the memory range
  * @arg: argument passed to func
  * @func: callback for each memory section walked
  *

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
