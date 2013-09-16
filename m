Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 245909C0008
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 08:36:58 -0400 (EDT)
Date: Mon, 16 Sep 2013 14:36:45 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 07/50] mm: Account for a THP NUMA hinting update as one
 PTE update
Message-ID: <20130916123645.GD9326@twins.programming.kicks-ass.net>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
 <1378805550-29949-8-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1378805550-29949-8-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Sep 10, 2013 at 10:31:47AM +0100, Mel Gorman wrote:
> A THP PMD update is accounted for as 512 pages updated in vmstat.  This is
> large difference when estimating the cost of automatic NUMA balancing and
> can be misleading when comparing results that had collapsed versus split
> THP. This patch addresses the accounting issue.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  mm/mprotect.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index 94722a4..2bbb648 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -145,7 +145,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
>  				split_huge_page_pmd(vma, addr, pmd);
>  			else if (change_huge_pmd(vma, pmd, addr, newprot,
>  						 prot_numa)) {
> -				pages += HPAGE_PMD_NR;
> +				pages++;

But now you're not counting pages anymore..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
