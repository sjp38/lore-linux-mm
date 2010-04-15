Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DB8DC6B01F1
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 13:21:44 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 04/10] vmscan: Remove useless loop at end of do_try_to_free_pages
Date: Thu, 15 Apr 2010 18:21:37 +0100
Message-Id: <1271352103-2280-5-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1271352103-2280-1-git-send-email-mel@csn.ul.ie>
References: <1271352103-2280-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

With the patch "vmscan: kill prev_priority completely", the loop at the
end of do_try_to_free_pages() is now doing nothing. Delete it.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 76c2b03..838ac8b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1806,11 +1806,6 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		ret = sc->nr_reclaimed;
 
 out:
-	if (scanning_global_lru(sc))
-		for_each_zone_zonelist(zone, z, zonelist, high_zoneidx)
-			if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
-				continue;
-
 	delayacct_freepages_end();
 
 	return ret;
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
