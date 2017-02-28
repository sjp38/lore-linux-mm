Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 14D4C6B038B
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 16:46:22 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id r18so9391643wmd.1
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 13:46:22 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id c17si4344796wme.128.2017.02.28.13.46.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 13:46:21 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 4/9] mm: remove unnecessary reclaimability check from NUMA balancing target
Date: Tue, 28 Feb 2017 16:40:02 -0500
Message-Id: <20170228214007.5621-5-hannes@cmpxchg.org>
In-Reply-To: <20170228214007.5621-1-hannes@cmpxchg.org>
References: <20170228214007.5621-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jia He <hejianet@gmail.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

NUMA balancing already checks the watermarks of the target node to
decide whether it's a suitable balancing target. Whether the node is
reclaimable or not is irrelevant when we don't intend to reclaim.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/migrate.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 2c63ac06791b..45a18be27b1a 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1718,9 +1718,6 @@ static bool migrate_balanced_pgdat(struct pglist_data *pgdat,
 {
 	int z;
 
-	if (!pgdat_reclaimable(pgdat))
-		return false;
-
 	for (z = pgdat->nr_zones - 1; z >= 0; z--) {
 		struct zone *zone = pgdat->node_zones + z;
 
-- 
2.11.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
