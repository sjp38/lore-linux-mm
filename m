From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH] synchronous lumpy: improve commentary on writeback wait
References: <20070806122204.924fa0e9.akpm@linux-foundation.org>
Message-ID: <5de3a4f206c81c41e8b1ce5eeb245851@pinky>
Date: Tue, 07 Aug 2007 16:31:40 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Improve code commentary on the initial writeback wait in synchronous
reclaim mode.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 mm/vmscan.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index b1e9291..a6e65d0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -479,6 +479,14 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			(PageSwapCache(page) && (sc->gfp_mask & __GFP_IO));
 
 		if (PageWriteback(page)) {
+			/*
+			 * Synchronous reclaim is performed in two passes,
+			 * first an asynchronous pass over the list to
+			 * start parallel writeback, and a second synchronous
+			 * pass to wait for the IO to complete.  Wait here
+			 * for any page for which writeback has already
+			 * started.
+			 */
 			if (sync_writeback == PAGEOUT_IO_SYNC && may_enter_fs)
 				wait_on_page_writeback(page);
 			else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
