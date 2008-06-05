Date: Thu, 05 Jun 2008 10:26:44 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/5] fix incorrect variable type of do_try_to_free_pages()
In-Reply-To: <20080605021504.134644327@jp.fujitsu.com>
References: <20080605021211.871673550@jp.fujitsu.com> <20080605021504.134644327@jp.fujitsu.com>
Message-Id: <20080605102500.9C23.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kosaki.motohiro@jp.fujitsu.com
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nishanth Aravamudan <nacc@us.ibm.com>
List-ID: <linux-mm.kvack.org>

> "Smarter retry of costly-order allocations" patch series change behaver of do_try_to_free_pages().
> but unfortunately ret variable tyep unchanged.
> 
> thus, overflow problem is possible.
> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

sorry, this patch already get Nishanth-san's ACK.
I'll append it and resend by this mail.


----------------------------
fix incorrect variable type of do_try_to_free_pages() 

"Smarter retry of costly-order allocations" patch series change behaver of do_try_to_free_pages().
but unfortunately ret variable tyep unchanged.

thus, overflow problem is possible.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Acked-by: Nishanth Aravamudan <nacc@us.ibm.com>

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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
