From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: remove obsolete comments about page table lock
Date: Thu, 5 Sep 2013 10:27:34 +0800
Message-ID: <48696.7813260437$1378348075@news.gmane.org>
References: <1378313423-9sbygyow-mutt-n-horiguchi@ah.jp.nec.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1VHPIS-00059g-4j
	for glkm-linux-mm-2@m.gmane.org; Thu, 05 Sep 2013 04:27:48 +0200
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 7CB626B0033
	for <linux-mm@kvack.org>; Wed,  4 Sep 2013 22:27:45 -0400 (EDT)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 5 Sep 2013 12:20:15 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 5B9742BB0051
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 12:27:37 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r852RQWD7012742
	for <linux-mm@kvack.org>; Thu, 5 Sep 2013 12:27:26 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r852Ra60023735
	for <linux-mm@kvack.org>; Thu, 5 Sep 2013 12:27:36 +1000
Content-Disposition: inline
In-Reply-To: <1378313423-9sbygyow-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: David Gibson <david@gibson.dropbear.id.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org

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
