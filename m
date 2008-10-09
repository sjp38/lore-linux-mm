Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m996hCR7020933
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 9 Oct 2008 15:43:13 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C7832AC02B
	for <linux-mm@kvack.org>; Thu,  9 Oct 2008 15:43:12 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 61B5812C049
	for <linux-mm@kvack.org>; Thu,  9 Oct 2008 15:43:12 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B0001DB8044
	for <linux-mm@kvack.org>; Thu,  9 Oct 2008 15:43:12 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id ECF161DB803F
	for <linux-mm@kvack.org>; Thu,  9 Oct 2008 15:43:11 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [mmotm 02/Oct PATCH 3/3] fix style issue of get_scan_ratio()
In-Reply-To: <20081009153432.DEC7.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081009153432.DEC7.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20081009154146.DED0.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  9 Oct 2008 15:43:11 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

vmscan-split-lru-lists-into-anon-file-sets.patch introduce two style issue.
this patch fix it.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |   22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1420,7 +1420,7 @@ static unsigned long shrink_list(enum lr
  * percent[0] specifies how much pressure to put on ram/swap backed
  * memory, while percent[1] determines pressure on the file LRUs.
  */
-static void get_scan_ratio(struct zone *zone, struct scan_control * sc,
+static void get_scan_ratio(struct zone *zone, struct scan_control *sc,
 					unsigned long *percent)
 {
 	unsigned long anon, file, free;
@@ -1448,16 +1448,16 @@ static void get_scan_ratio(struct zone *
 	}
 
 	/*
-         * OK, so we have swap space and a fair amount of page cache
-         * pages.  We use the recently rotated / recently scanned
-         * ratios to determine how valuable each cache is.
-         *
-         * Because workloads change over time (and to avoid overflow)
-         * we keep these statistics as a floating average, which ends
-         * up weighing recent references more than old ones.
-         *
-         * anon in [0], file in [1]
-         */
+	 * OK, so we have swap space and a fair amount of page cache
+	 * pages.  We use the recently rotated / recently scanned
+	 * ratios to determine how valuable each cache is.
+	 *
+	 * Because workloads change over time (and to avoid overflow)
+	 * we keep these statistics as a floating average, which ends
+	 * up weighing recent references more than old ones.
+	 *
+	 * anon in [0], file in [1]
+	 */
 	if (unlikely(zone->recent_scanned[0] > anon / 4)) {
 		spin_lock_irq(&zone->lru_lock);
 		zone->recent_scanned[0] /= 2;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
