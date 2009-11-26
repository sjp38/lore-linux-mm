Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2554F6B009E
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 21:13:56 -0500 (EST)
Received: by pxi5 with SMTP id 5so214808pxi.12
        for <linux-mm@kvack.org>; Wed, 25 Nov 2009 18:13:53 -0800 (PST)
From: Huang Shijie <shijie8@gmail.com>
Subject: [PATCH] vmscan : simplify code
Date: Thu, 26 Nov 2009 10:13:48 +0800
Message-Id: <1259201628-26935-1-git-send-email-shijie8@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Huang Shijie <shijie8@gmail.com>
List-ID: <linux-mm.kvack.org>

simplify the code for shrink_inactive_list.

Signed-off-by: Huang Shijie <shijie8@gmail.com>
---
 mm/vmscan.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 777af57..0a3cf75 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1166,10 +1166,8 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
 		__mod_zone_page_state(zone, NR_ISOLATED_ANON, nr_anon);
 		__mod_zone_page_state(zone, NR_ISOLATED_FILE, nr_file);
 
-		reclaim_stat->recent_scanned[0] += count[LRU_INACTIVE_ANON];
-		reclaim_stat->recent_scanned[0] += count[LRU_ACTIVE_ANON];
-		reclaim_stat->recent_scanned[1] += count[LRU_INACTIVE_FILE];
-		reclaim_stat->recent_scanned[1] += count[LRU_ACTIVE_FILE];
+		reclaim_stat->recent_scanned[0] += nr_anon;
+		reclaim_stat->recent_scanned[1] += nr_file;
 
 		spin_unlock_irq(&zone->lru_lock);
 
-- 
1.6.0.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
