Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id A9B196B003C
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 05:10:16 -0400 (EDT)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 4 Apr 2013 19:05:32 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id C6E3E357804E
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 20:10:10 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3499Qld64356372
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 20:09:26 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3499VOL010726
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 20:09:31 +1100
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH 6/6] mm/hugetlb: use already exist interface huge_page_shift 
Date: Thu,  4 Apr 2013 17:09:14 +0800
Message-Id: <1365066554-29195-7-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1365066554-29195-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1365066554-29195-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

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
