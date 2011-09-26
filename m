Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7B3859000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 04:07:06 -0400 (EDT)
Subject: [patch]mm: initialize zone all_unreclaimable
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 26 Sep 2011 16:11:52 +0800
Message-ID: <1317024712.29510.178.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>

I saw DMA zone is always unreclaimable in my system. zone->all_unreclaimable
isn't initialized till a page from the zone is freed. This isn't a big problem
normally, but a little confused, so fix here.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6e8ecb6..1facc05 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4335,6 +4335,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 		zone_pcp_init(zone);
 		for_each_lru(l)
 			INIT_LIST_HEAD(&zone->lru[l].list);
+		zone->all_unreclaimable = 0;
 		zone->reclaim_stat.recent_rotated[0] = 0;
 		zone->reclaim_stat.recent_rotated[1] = 0;
 		zone->reclaim_stat.recent_scanned[0] = 0;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
