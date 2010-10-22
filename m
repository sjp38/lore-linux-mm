Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 911165F0040
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 00:56:00 -0400 (EDT)
Date: Fri, 22 Oct 2010 12:55:54 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH] vmscan: comment too_many_isolated()
Message-ID: <20101022045554.GA17073@localhost>
References: <20101022045509.GA16804@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101022045509.GA16804@localhost>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Neil Brown <neilb@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

Comment "Why it's doing so" rather than "What it does"
as proposed by Andrew Morton.

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/vmscan.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

--- linux-next.orig/mm/vmscan.c	2010-10-19 09:29:44.000000000 +0800
+++ linux-next/mm/vmscan.c	2010-10-19 10:21:41.000000000 +0800
@@ -1142,7 +1142,11 @@ int isolate_lru_page(struct page *page)
 }
 
 /*
- * Are there way too many processes in the direct reclaim path already?
+ * A direct reclaimer may isolate SWAP_CLUSTER_MAX pages from the LRU list and
+ * then get resheduled. When there are massive number of tasks doing page
+ * allocation, such sleeping direct reclaimers may keep piling up on each CPU,
+ * the LRU list will go small and be scanned faster than necessary, leading to
+ * unnecessary swapping, thrashing and OOM.
  */
 static int too_many_isolated(struct zone *zone, int file,
 		struct scan_control *sc)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
