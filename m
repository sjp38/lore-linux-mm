Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B6B9E6B0096
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 15:48:41 -0400 (EDT)
From: Vincent Li <macli@brc.ubc.ca>
Subject: [PATCH] mm/vmscan: remove page_queue_congested() comment
Date: Tue, 25 Aug 2009 11:53:42 -0700
Message-Id: <1251226422-17878-1-git-send-email-macli@brc.ubc.ca>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Vincent Li <macli@brc.ubc.ca>
List-ID: <linux-mm.kvack.org>

Commit 084f71ae5c(kill page_queue_congested()) removed page_queue_congested().
Remove the page_queue_congested() comment in vmscan pageout() too.

Signed-off-by: Vincent Li <macli@brc.ubc.ca>
---
 mm/vmscan.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 848689a..1219ceb 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -366,7 +366,6 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
 	 * block, for some throttling. This happens by accident, because
 	 * swap_backing_dev_info is bust: it doesn't reflect the
 	 * congestion state of the swapdevs.  Easy to fix, if needed.
-	 * See swapfile.c:page_queue_congested().
 	 */
 	if (!is_page_cache_freeable(page))
 		return PAGE_KEEP;
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
