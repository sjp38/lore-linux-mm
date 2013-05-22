Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 816156B0072
	for <linux-mm@kvack.org>; Wed, 22 May 2013 05:29:49 -0400 (EDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 22 May 2013 14:55:51 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id A69CD1258052
	for <linux-mm@kvack.org>; Wed, 22 May 2013 15:01:41 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4M9TZbV11796866
	for <linux-mm@kvack.org>; Wed, 22 May 2013 14:59:35 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4M9TgXP016075
	for <linux-mm@kvack.org>; Wed, 22 May 2013 19:29:43 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH 4/4] mm/hugetlb: use already exist interface huge_page_shift
Date: Wed, 22 May 2013 17:29:30 +0800
Message-Id: <1369214970-1526-4-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1369214970-1526-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1369214970-1526-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Use already exist interface huge_page_shift instead of h->order + PAGE_SHIFT.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/hugetlb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index f8feeec..b6ff0ee 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -319,7 +319,7 @@ unsigned long vma_kernel_pagesize(struct vm_area_struct *vma)
 
 	hstate = hstate_vma(vma);
 
-	return 1UL << (hstate->order + PAGE_SHIFT);
+	return 1UL << huge_page_shift(hstate);
 }
 EXPORT_SYMBOL_GPL(vma_kernel_pagesize);
 
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
