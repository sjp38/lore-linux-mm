Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 6C4B46B006C
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 21:27:29 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so8324089pbb.14
        for <linux-mm@kvack.org>; Sat, 16 Jun 2012 18:27:28 -0700 (PDT)
From: Wanpeng Li <liwp.linux@gmail.com>
Subject: [PATCH] mm/vmscan: cleanup comment error in balance_pgdat
Date: Sun, 17 Jun 2012 09:27:18 +0800
Message-Id: <1339896438-5412-1-git-send-email-liwp.linux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Jiri Kosina <trivial@kernel.org>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Wanpeng Li <liwp.linux@gmail.com>

From: Wanpeng Li <liwp@linux.vnet.ibm.com>

Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>
---
 mm/vmscan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2fc16cf..375d073 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2539,7 +2539,7 @@ loop_again:
 				 * consider it to be no longer congested. It's
 				 * possible there are dirty pages backed by
 				 * congested BDIs but as pressure is relieved,
-				 * spectulatively avoid congestion waits
+				 * speculatively avoid congestion waits
 				 */
 				zone_clear_flag(zone, ZONE_CONGESTED);
 				if (i <= *classzone_idx)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
