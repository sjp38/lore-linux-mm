Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 7E1C96B0005
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 00:43:53 -0400 (EDT)
Received: by mail-pf0-f171.google.com with SMTP id 4so32085918pfd.0
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 21:43:53 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id t13si3486525pas.225.2016.03.29.21.43.51
        for <linux-mm@kvack.org>;
        Tue, 29 Mar 2016 21:43:52 -0700 (PDT)
From: Chanho Min <chanho.min@lge.com>
Subject: [PATCH] mm/highmem: simplify is_highmem()
Date: Wed, 30 Mar 2016 13:43:42 +0900
Message-ID: <1459313022-11750-1-git-send-email-chanho.min@lge.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Gunho Lee <gunho.lee@lge.com>, Chanho Min <chanho.min@lge.com>

The is_highmem() is can be simplified by use of is_highmem_idx().
This patch removes redundant code and will make it easier to maintain
if the zone policy is changed or a new zone is added.

Signed-off-by: Chanho Min <chanho.min@lge.com>
---
 include/linux/mmzone.h |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index e23a9e7..9ac90c3 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -817,10 +817,7 @@ static inline int is_highmem_idx(enum zone_type idx)
 static inline int is_highmem(struct zone *zone)
 {
 #ifdef CONFIG_HIGHMEM
-	int zone_off = (char *)zone - (char *)zone->zone_pgdat->node_zones;
-	return zone_off == ZONE_HIGHMEM * sizeof(*zone) ||
-	       (zone_off == ZONE_MOVABLE * sizeof(*zone) &&
-		zone_movable_is_highmem());
+	return is_highmem_idx(zone_idx(zone));
 #else
 	return 0;
 #endif
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
