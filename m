Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id BD7FA6B0031
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 19:32:57 -0400 (EDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 25 Jul 2013 04:54:57 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 70754E004F
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 05:02:53 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6ONXmsk37683358
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 05:03:48 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6ONWn5b018268
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 23:32:50 GMT
Date: Thu, 25 Jul 2013 07:32:49 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: Fix potential NULL pointer dereference
Message-ID: <20130724233249.GA28598@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1374637699-25704-1-git-send-email-huawei.libin@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1374637699-25704-1-git-send-email-huawei.libin@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Libin <huawei.libin@huawei.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mgorman@suse.de, xiaoguangrong@linux.vnet.ibm.com, wujianguo@huawei.com

On Wed, Jul 24, 2013 at 11:48:19AM +0800, Libin wrote:
>find_vma may return NULL, thus check the return
>value to avoid NULL pointer dereference.
>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>Signed-off-by: Libin <huawei.libin@huawei.com>
>---
> mm/huge_memory.c | 2 ++
> 1 file changed, 2 insertions(+)
>
>diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>index 243e710..d4423f4 100644
>--- a/mm/huge_memory.c
>+++ b/mm/huge_memory.c
>@@ -2294,6 +2294,8 @@ static void collapse_huge_page(struct mm_struct *mm,
> 		goto out;
>
> 	vma = find_vma(mm, address);
>+	if (!vma)
>+		goto out;
> 	hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
> 	hend = vma->vm_end & HPAGE_PMD_MASK;
> 	if (address < hstart || address + HPAGE_PMD_SIZE > hend)
>-- 
>1.8.2.1
>
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
