Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 698CC6B0254
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 03:32:02 -0400 (EDT)
Received: by mail-pf0-f182.google.com with SMTP id n5so92227264pfn.2
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 00:32:02 -0700 (PDT)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id st10si1462604pab.60.2016.03.14.00.32.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Mar 2016 00:32:01 -0700 (PDT)
Received: by mail-pa0-x242.google.com with SMTP id fl4so14020204pad.2
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 00:32:01 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH 3/6] mm/memory_hotplug: add comment to some functions related to memory hotplug
Date: Mon, 14 Mar 2016 16:31:34 +0900
Message-Id: <1457940697-2278-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1457940697-2278-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1457940697-2278-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

__offline_isolated_pages() and test_pages_isolated() are used by memory
hotplug. These functions require that range is in a single zone but
there is no code about it because memory hotplug checks it before calling
these functions. Not to confuse future user of these functions,
this patch adds comment on them.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_alloc.c     | 3 ++-
 mm/page_isolation.c | 1 +
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 93293b4..08d5536 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7260,7 +7260,8 @@ void zone_pcp_reset(struct zone *zone)
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
 /*
- * All pages in the range must be isolated before calling this.
+ * All pages in the range must be in a single zone and isolated
+ * before calling this.
  */
 void
 __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 92c4c36..f4c0a9b 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -246,6 +246,7 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
 	return pfn;
 }
 
+/* Caller should ensure that requested range is in a single zone */
 int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
 			bool skip_hwpoisoned_pages)
 {
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
