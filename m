Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9V7qrPU013856
	for <linux-mm@kvack.org>; Wed, 31 Oct 2007 03:52:53 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9V7qrSX482068
	for <linux-mm@kvack.org>; Wed, 31 Oct 2007 03:52:53 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9V7qrkR021159
	for <linux-mm@kvack.org>; Wed, 31 Oct 2007 03:52:53 -0400
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Wed, 31 Oct 2007 13:22:43 +0530
Message-Id: <20071031075243.22225.53636.sendpatchset@balbir-laptop>
Subject: [PATCH] Swap delay accounting, include lock_page() delays
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux MM Mailing List <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


Reported-by: Nick Piggin <nickpiggin@yahoo.com.au>

The delay incurred in lock_page() should also be accounted in swap delay
accounting

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 mm/memory.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN mm/swapfile.c~fix-delay-accounting-swap-accounting mm/swapfile.c
diff -puN mm/memory.c~fix-delay-accounting-swap-accounting mm/memory.c
--- linux-2.6-latest/mm/memory.c~fix-delay-accounting-swap-accounting	2007-10-31 12:58:05.000000000 +0530
+++ linux-2.6-latest-balbir/mm/memory.c	2007-10-31 13:02:50.000000000 +0530
@@ -2084,9 +2084,9 @@ static int do_swap_page(struct mm_struct
 		count_vm_event(PGMAJFAULT);
 	}
 
-	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
 	mark_page_accessed(page);
 	lock_page(page);
+	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
 
 	/*
 	 * Back out if somebody else already faulted in this pte.
_

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
