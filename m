Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail2.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAUBEZK9006408
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 30 Nov 2008 20:14:35 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 54DEA45DD71
	for <linux-mm@kvack.org>; Sun, 30 Nov 2008 20:14:35 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A78945DD70
	for <linux-mm@kvack.org>; Sun, 30 Nov 2008 20:14:35 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0EC241DB803E
	for <linux-mm@kvack.org>; Sun, 30 Nov 2008 20:14:35 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BCF211DB803A
	for <linux-mm@kvack.org>; Sun, 30 Nov 2008 20:14:34 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] mm: kill zone_is_near_oom()
Message-Id: <20081130201255.8162.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sun, 30 Nov 2008 20:14:34 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Now, zone_is_ner_oom() is unused.
it can be removed.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |    5 -----
 1 file changed, 5 deletions(-)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1220,11 +1220,6 @@ static inline void note_zone_scanning_pr
 		zone->prev_priority = priority;
 }
 
-static inline int zone_is_near_oom(struct zone *zone)
-{
-	return zone->pages_scanned >= (zone_lru_pages(zone) * 3);
-}
-
 /*
  * This moves pages from the active list to the inactive list.
  *



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
