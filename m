Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB48G2wv027222
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 4 Dec 2008 17:16:02 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 76D3245DE50
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 17:16:02 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 484B245DE52
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 17:16:02 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 14A561DB803B
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 17:15:59 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B67151DB8040
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 17:15:58 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [mmotm][PATCH] vmscan: style cleanup
Message-Id: <20081204170937.1D7A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  4 Dec 2008 17:15:58 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

applied after: memcg-add-inactive_anon_is_low.patch

Balbir-san pointed out memcg-add-inactive_anon_is_low.patch has one
strange indent.

fix here.

Andrew, if you like folded patch instead incremental patch, 
please let me know it.


==

trivial style cleanup.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Balbir Singh <balbir@linux.vnet.ibm.com>
---
 mm/vmscan.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1411,8 +1411,7 @@ static unsigned long shrink_list(enum lr
 		return 0;
 	}
 
-	if (lru == LRU_ACTIVE_ANON &&
-	    inactive_anon_is_low(zone, sc)) {
+	if (lru == LRU_ACTIVE_ANON && inactive_anon_is_low(zone, sc)) {
 		shrink_active_list(nr_to_scan, zone, sc, priority, file);
 		return 0;
 	}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
