Message-Id: <20080605021504.134644327@jp.fujitsu.com>
References: <20080605021211.871673550@jp.fujitsu.com>
Date: Thu, 05 Jun 2008 11:12:12 +0900
From: kosaki.motohiro@jp.fujitsu.com
Subject: [PATCH 1/5] fix incorrect variable type of do_try_to_free_pages()
Content-Disposition: inline; filename=01-fix-do_try_to_free_pages-ret.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

"Smarter retry of costly-order allocations" patch series change behaver of do_try_to_free_pages().
but unfortunately ret variable tyep unchanged.

thus, overflow problem is possible.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 mm/vmscan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
