Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 5C1536B0033
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 00:22:16 -0400 (EDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 24 Jul 2013 14:11:49 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 7097D3578050
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 14:22:10 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6O46kac43778184
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 14:06:46 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6O4M9tU023648
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 14:22:10 +1000
Date: Wed, 24 Jul 2013 12:22:08 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: Fix potential NULL pointer dereference
Message-ID: <20130724042208.GJ22680@hacker.(null)>
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

When can this happen since down_read(&mm->mmap_sem) is held?

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
