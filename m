Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id F1320900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 10:39:23 -0400 (EDT)
Date: Fri, 15 Apr 2011 16:39:16 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: Check if PTE is already allocated during page fault
Message-ID: <20110415143916.GN15707@random.random>
References: <20110415101248.GB22688@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110415101248.GB22688@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: akpm@linux-foundation.org, raz ben yehuda <raziebe@gmail.com>, riel@redhat.com, kosaki.motohiro@jp.fujitsu.com, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, stable@kernel.org

On Fri, Apr 15, 2011 at 11:12:48AM +0100, Mel Gorman wrote:
> diff --git a/mm/memory.c b/mm/memory.c
> index 5823698..1659574 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3322,7 +3322,7 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  	 * run pte_offset_map on the pmd, if an huge pmd could
>  	 * materialize from under us from a different thread.
>  	 */
> -	if (unlikely(__pte_alloc(mm, vma, pmd, address)))
> +	if (unlikely(pmd_none(*pmd)) && __pte_alloc(mm, vma, pmd, address))
>  		return VM_FAULT_OOM;
>  	/* if an huge pmd materialized from under us just retry later */
>  	if (unlikely(pmd_trans_huge(*pmd)))

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
