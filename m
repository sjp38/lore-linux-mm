Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 96C7A6B025E
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 02:30:42 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id o124so7837555pfg.1
        for <linux-mm@kvack.org>; Mon, 08 Aug 2016 23:30:42 -0700 (PDT)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id xy10si41067604pac.60.2016.08.08.23.30.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Aug 2016 23:30:41 -0700 (PDT)
Received: by mail-pa0-x242.google.com with SMTP id cf3so409719pad.2
        for <linux-mm@kvack.org>; Mon, 08 Aug 2016 23:30:41 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH 1/2] mm/page_alloc: fix wrong initialization when sysctl_min_unmapped_ratio changes
Date: Tue,  9 Aug 2016 15:30:47 +0900
Message-Id: <1470724248-26780-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Before resetting min_unmapped_pages, we need to initialize
min_unmapped_pages rather than min_slab_pages.

Fixes: a5f5f91da6 (mm: convert zone_reclaim to node_reclaim)
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index afdb7f8..555b609 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6894,7 +6894,7 @@ int sysctl_min_unmapped_ratio_sysctl_handler(struct ctl_table *table, int write,
 		return rc;
 
 	for_each_online_pgdat(pgdat)
-		pgdat->min_slab_pages = 0;
+		pgdat->min_unmapped_pages = 0;
 
 	for_each_zone(zone)
 		zone->zone_pgdat->min_unmapped_pages += (zone->managed_pages *
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
