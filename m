Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id C91416B005A
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 20:36:58 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 17 Apr 2013 06:02:12 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id B207F1258023
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 06:08:23 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3H0anvL14811616
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 06:06:49 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3H0aqlM023624
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 00:36:53 GMT
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v2 6/6] mm/hugetlb: use already exist interface huge_page_shift 
Date: Wed, 17 Apr 2013 08:36:34 +0800
Message-Id: <1366158995-3116-7-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1366158995-3116-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1366158995-3116-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Use already exist interface huge_page_shift instead of h->order + PAGE_SHIFT.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/hugetlb.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 0cae950..750ed8a 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -320,7 +320,7 @@ unsigned long vma_kernel_pagesize(struct vm_area_struct *vma)
 
 	hstate = hstate_vma(vma);
 
-	return 1UL << (hstate->order + PAGE_SHIFT);
+	return 1UL << huge_page_shift(hstate);
 }
 EXPORT_SYMBOL_GPL(vma_kernel_pagesize);
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
