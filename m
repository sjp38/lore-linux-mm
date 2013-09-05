From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: remove obsolete comments about page table lock
Date: Thu, 5 Sep 2013 10:23:25 +0800
Message-ID: <48622.3313179382$1378347830@news.gmane.org>
References: <1378313423-9sbygyow-mutt-n-horiguchi@ah.jp.nec.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1VHPEU-0003Th-Iu
	for glkm-linux-mm-2@m.gmane.org; Thu, 05 Sep 2013 04:23:42 +0200
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id A0B9E6B0031
	for <linux-mm@kvack.org>; Wed,  4 Sep 2013 22:23:38 -0400 (EDT)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 5 Sep 2013 12:16:05 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 633532BB0053
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 12:23:28 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r85273gd9961954
	for <linux-mm@kvack.org>; Thu, 5 Sep 2013 12:07:04 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r852NQ8Y018041
	for <linux-mm@kvack.org>; Thu, 5 Sep 2013 12:23:27 +1000
Content-Disposition: inline
In-Reply-To: <1378313423-9sbygyow-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org

Cced David Gibson who add this comment on powerpc part.
On Wed, Sep 04, 2013 at 12:50:23PM -0400, Naoya Horiguchi wrote:
>The callers of free_pgd_range() and hugetlb_free_pgd_range() don't hold
>page table locks. The comments seems to be obsolete, so let's remove them.
>
>Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>---
> arch/powerpc/mm/hugetlbpage.c | 2 --
> mm/memory.c                   | 2 --
> 2 files changed, 4 deletions(-)
>
>diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
>index 7e56cb7..31c20e2 100644
>--- a/arch/powerpc/mm/hugetlbpage.c
>+++ b/arch/powerpc/mm/hugetlbpage.c
>@@ -635,8 +635,6 @@ static void hugetlb_free_pud_range(struct mmu_gather *tlb, pgd_t *pgd,
>
> /*
>  * This function frees user-level page tables of a process.
>- *
>- * Must be called with pagetable lock held.
>  */
> void hugetlb_free_pgd_range(struct mmu_gather *tlb,
> 			    unsigned long addr, unsigned long end,
>diff --git a/mm/memory.c b/mm/memory.c
>index 6827a35..8c97ef0 100644
>--- a/mm/memory.c
>+++ b/mm/memory.c
>@@ -478,8 +478,6 @@ static inline void free_pud_range(struct mmu_gather *tlb, pgd_t *pgd,
>
> /*
>  * This function frees user-level page tables of a process.
>- *
>- * Must be called with pagetable lock held.
>  */
> void free_pgd_range(struct mmu_gather *tlb,
> 			unsigned long addr, unsigned long end,
>-- 
>1.8.3.1
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
