Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id jBCGToXx007772
	for <linux-mm@kvack.org>; Mon, 12 Dec 2005 11:29:50 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jBCGTovd098358
	for <linux-mm@kvack.org>; Mon, 12 Dec 2005 11:29:50 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id jBCGTn4R009722
	for <linux-mm@kvack.org>; Mon, 12 Dec 2005 11:29:50 -0500
Subject: [PATCH] Compile fix: Remove duplicate struct slb_flush_info fi
From: Adam Litke <agl@us.ibm.com>
Content-Type: text/plain
Date: Mon, 12 Dec 2005 10:29:48 -0600
Message-Id: <1134404989.829.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, David Gibson <david@gibson.dropbear.id.au>
List-ID: <linux-mm.kvack.org>

This appeared in -mm2:
 
hugetlbpage.c |    1 -
 1 files changed, 1 deletion(-)
diff -upN reference/arch/powerpc/mm/hugetlbpage.c current/arch/powerpc/mm/hugetlbpage.c
--- reference/arch/powerpc/mm/hugetlbpage.c
+++ current/arch/powerpc/mm/hugetlbpage.c
@@ -280,7 +280,6 @@ static int open_high_hpage_areas(struct 
 {
 	struct slb_flush_info fi;
 	unsigned long i;
-	struct slb_flush_info fi;
 
 	BUILD_BUG_ON((sizeof(newareas)*8) != NUM_HIGH_AREAS);
 	BUILD_BUG_ON((sizeof(mm->context.high_htlb_areas)*8)

Signed-off-by: Adam Litke <agl@us.ibm.com>
-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
