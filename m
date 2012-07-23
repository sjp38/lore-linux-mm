Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 912B36B009A
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 09:39:07 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 29/34] mm: test PageSwapBacked in lumpy reclaim
Date: Mon, 23 Jul 2012 14:38:42 +0100
Message-Id: <1343050727-3045-30-git-send-email-mgorman@suse.de>
In-Reply-To: <1343050727-3045-1-git-send-email-mgorman@suse.de>
References: <1343050727-3045-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable <stable@vger.kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Hugh Dickins <hughd@google.com>

commit 043bcbe5ec51e0478ef2b44acef17193e01d7f70 upstream.

Stable note: Not tracked in Bugzilla. There were reports of shared
	mapped pages being unfairly reclaimed in comparison to older kernels.
	This is being addressed over time. Even though the subject
	refers to lumpy reclaim, it impacts compaction as well.

Lumpy reclaim does well to stop at a PageAnon when there's no swap, but
better is to stop at any PageSwapBacked, which includes shmem/tmpfs too.

Signed-off-by: Hugh Dickins <hughd@google.com>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index da195c2..e5382ad 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1199,7 +1199,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			 * anon page which don't already have a swap slot is
 			 * pointless.
 			 */
-			if (nr_swap_pages <= 0 && PageAnon(cursor_page) &&
+			if (nr_swap_pages <= 0 && PageSwapBacked(cursor_page) &&
 			    !PageSwapCache(cursor_page))
 				break;
 
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
