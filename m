Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 3A6516B0253
	for <linux-mm@kvack.org>; Sun,  3 Apr 2016 19:46:28 -0400 (EDT)
Received: by mail-pf0-f181.google.com with SMTP id n1so26370917pfn.2
        for <linux-mm@kvack.org>; Sun, 03 Apr 2016 16:46:28 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 79si37354135pfo.227.2016.04.03.16.46.26
        for <linux-mm@kvack.org>;
        Sun, 03 Apr 2016 16:46:27 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] mm:vmscan: clean up classzone_idx
Date: Mon,  4 Apr 2016 08:46:25 +0900
Message-Id: <1459727185-5753-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>

[1] removed classzone_idx so we don't need code related to it.
This patch cleans it up.

[1] mm, oom: rework oom detection

Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/vmscan.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index d84efa03c8a8..6e67de2a61ed 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2551,16 +2551,8 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 					gfp_zone(sc->gfp_mask), sc->nodemask) {
-		enum zone_type classzone_idx;
-
 		if (!populated_zone(zone))
 			continue;
-
-		classzone_idx = requested_highidx;
-		while (!populated_zone(zone->zone_pgdat->node_zones +
-							classzone_idx))
-			classzone_idx--;
-
 		/*
 		 * Take care memory controller reclaiming has small influence
 		 * to global LRU.
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
