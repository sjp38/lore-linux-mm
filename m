Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 0B0CD6B005C
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 05:06:43 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so6124408pbb.14
        for <linux-mm@kvack.org>; Fri, 15 Jun 2012 02:06:43 -0700 (PDT)
From: Wanpeng Li <liwp.linux@gmail.com>
Subject: [PATCH][TRIVIAL][resend] mm: fix page reclaim comment error
Date: Fri, 15 Jun 2012 17:06:29 +0800
Message-Id: <1339751189-6055-1-git-send-email-liwp.linux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <trivial@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, Gavin Shan <shangw@linux.vnet.ibm.com>, Wanpeng Li <liwp.linux@gmail.com>

From: Wanpeng Li <liwp@linux.vnet.ibm.com>

Since there are five lists in LRU cache, the array nr in get_scan_count
should be:

nr[0] = anon inactive pages to scan; nr[1] = anon active pages to scan
nr[2] = file inactive pages to scan; nr[3] = file active pages to scan

Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>
Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Acked-by: Minchan Kim <minchan@kernel.org>
Reviewed-by: Rik van Riel <riel@redhat.com>

---
 mm/vmscan.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index eeb3bc9..ed823df 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1567,7 +1567,8 @@ static int vmscan_swappiness(struct scan_control *sc)
  * by looking at the fraction of the pages scanned we did rotate back
  * onto the active list instead of evict.
  *
- * nr[0] = anon pages to scan; nr[1] = file pages to scan
+ * nr[0] = anon inactive pages to scan; nr[1] = anon active pages to scan
+ * nr[2] = file inactive pages to scan; nr[3] = file active pages to scan
  */
 static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
 			   unsigned long *nr)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
