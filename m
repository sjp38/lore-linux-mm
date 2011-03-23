Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2C22A8D0040
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 16:46:25 -0400 (EDT)
Date: Wed, 23 Mar 2011 15:46:20 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: vmstat: Update comment in stat_threshold
Message-ID: <alpine.DEB.2.00.1103231542200.14654@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org

This has been in my tree for awhile. I thought it would be merged
at some point into another patch but that did not happen.

It was first posted in a discussion of the vmstat changes for per cpu
atomics: http://www.gossamer-threads.com/lists/linux/kernel/1317000#1317000

Signed-off-by: Christoph Lameter <cl@linux.com>


---
 mm/vmstat.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

Index: linux-2.6/mm/vmstat.c
===================================================================
--- linux-2.6.orig/mm/vmstat.c	2011-03-15 11:16:48.000000000 -0500
+++ linux-2.6/mm/vmstat.c	2011-03-17 09:25:26.000000000 -0500
@@ -321,9 +321,12 @@ static inline void mod_state(struct zone
 		/*
 		 * The fetching of the stat_threshold is racy. We may apply
 		 * a counter threshold to the wrong the cpu if we get
-		 * rescheduled while executing here. However, the following
-		 * will apply the threshold again and therefore bring the
-		 * counter under the threshold.
+		 * rescheduled while executing here. However, the next
+		 * counter update will apply the threshold again and
+		 * therefore bring the counter under the threshold again.
+		 *
+		 * Most of the time the thresholds are the same anyways
+		 * for all cpus in a zone.
 		 */
 		t = this_cpu_read(pcp->stat_threshold);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
