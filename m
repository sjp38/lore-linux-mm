Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 0F8CB6B025E
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 22:07:07 -0400 (EDT)
Received: by mail-pf0-f176.google.com with SMTP id x3so82753504pfb.1
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 19:07:07 -0700 (PDT)
Received: from mail-pf0-x22a.google.com (mail-pf0-x22a.google.com. [2607:f8b0:400e:c00::22a])
        by mx.google.com with ESMTPS id ao8si84760pad.241.2016.03.31.19.07.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Mar 2016 19:07:06 -0700 (PDT)
Received: by mail-pf0-x22a.google.com with SMTP id n5so82740453pfn.2
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 19:07:06 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v2 2/5] mm/memory_hotplug: add comment to some functions related to memory hotplug
Date: Fri,  1 Apr 2016 11:06:43 +0900
Message-Id: <1459476406-28418-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1459476406-28418-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1459476406-28418-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

__offline_isolated_pages() and test_pages_isolated() are used by memory
hotplug. These functions require that range is in a single zone but
there is no code about it because memory hotplug checks it before calling
these functions. Not to confuse future user of these functions,
this patch adds comment on them.

Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_alloc.c     | 3 ++-
 mm/page_isolation.c | 1 +
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b563403..0cfee62 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7280,7 +7280,8 @@ void zone_pcp_reset(struct zone *zone)
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
 /*
- * All pages in the range must be isolated before calling this.
+ * All pages in the range must be in a single zone and isolated
+ * before calling this.
  */
 void
 __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 67bedd1..612122b 100644
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
