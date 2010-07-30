Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 036446B02A9
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 09:37:04 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 4/6] vmscan: tracing: Correct units in post-processing script
Date: Fri, 30 Jul 2010 14:36:58 +0100
Message-Id: <1280497020-22816-5-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1280497020-22816-1-git-send-email-mel@csn.ul.ie>
References: <1280497020-22816-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

The post-processing script is reporting the wrong units. Correct it.  This
patch updates vmscan-tracing-add-trace-event-when-a-page-is-written.patch
to include that information. The patches can be merged together.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 .../trace/postprocess/trace-vmscan-postprocess.pl  |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/trace/postprocess/trace-vmscan-postprocess.pl b/Documentation/trace/postprocess/trace-vmscan-postprocess.pl
index f87f56e..f1b70a8 100644
--- a/Documentation/trace/postprocess/trace-vmscan-postprocess.pl
+++ b/Documentation/trace/postprocess/trace-vmscan-postprocess.pl
@@ -584,7 +584,7 @@ sub dump_stats {
 	print "Direct reclaim write file async I/O:	$total_direct_writepage_file_async\n";
 	print "Direct reclaim write anon async I/O:	$total_direct_writepage_anon_async\n";
 	print "Wake kswapd requests:			$total_wakeup_kswapd\n";
-	printf "Time stalled direct reclaim: 		%-1.2f ms\n", $total_direct_latency;
+	printf "Time stalled direct reclaim: 		%-1.2f seconds\n", $total_direct_latency;
 	print "\n";
 	print "Kswapd wakeups:				$total_kswapd_wake\n";
 	print "Kswapd pages scanned:			$total_kswapd_nr_scanned\n";
@@ -592,7 +592,7 @@ sub dump_stats {
 	print "Kswapd reclaim write anon sync I/O:	$total_kswapd_writepage_anon_sync\n";
 	print "Kswapd reclaim write file async I/O:	$total_kswapd_writepage_file_async\n";
 	print "Kswapd reclaim write anon async I/O:	$total_kswapd_writepage_anon_async\n";
-	printf "Time kswapd awake:			%-1.2f ms\n", $total_kswapd_latency;
+	printf "Time kswapd awake:			%-1.2f seconds\n", $total_kswapd_latency;
 }
 
 sub aggregate_perprocesspid() {
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
