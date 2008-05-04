Date: Sun, 04 May 2008 21:55:57 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [-mm][PATCH 1/5] fix overflow problem of do_try_to_free_page()
In-Reply-To: <20080504201343.8F52.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080504201343.8F52.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080504215331.8F55.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nishanth Aravamudan <nacc@us.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

this patch is not part of reclaim throttle series.
it is merely hotfixs.

---------------------------------------
"Smarter retry of costly-order allocations" patch series change 
behaver of do_try_to_free_pages().
but unfortunately ret variable type unchanged.

thus, overflow problem is possible.



Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Nishanth Aravamudan <nacc@us.ibm.com>

---
 mm/vmscan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c	2008-05-03 00:02:52.000000000 +0900
+++ b/mm/vmscan.c	2008-05-03 00:05:08.000000000 +0900
@@ -1317,7 +1317,7 @@ static unsigned long do_try_to_free_page
 					struct scan_control *sc)
 {
 	int priority;
-	int ret = 0;
+	unsigned long ret = 0;
 	unsigned long total_scanned = 0;
 	unsigned long nr_reclaimed = 0;
 	struct reclaim_state *reclaim_state = current->reclaim_state;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
