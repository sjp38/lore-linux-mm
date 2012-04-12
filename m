Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id B73FF6B0044
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 13:51:31 -0400 (EDT)
Received: by ggeq1 with SMTP id q1so1668228gge.14
        for <linux-mm@kvack.org>; Thu, 12 Apr 2012 10:51:30 -0700 (PDT)
Date: Thu, 12 Apr 2012 10:51:10 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] Revert "proc: clear_refs: do not clear reserved pages"
In-Reply-To: <1334250034-29866-1-git-send-email-will.deacon@arm.com>
Message-ID: <alpine.LSU.2.00.1204121049120.2288@eggly.anvils>
References: <1334250034-29866-1-git-send-email-will.deacon@arm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nicolas Pitre <nico@linaro.org>

On Thu, 12 Apr 2012, Will Deacon wrote:

> This reverts commit 85e72aa5384b1a614563ad63257ded0e91d1a620, which was
> a quick fix suitable for -stable until ARM had been moved over to the
> gate_vma mechanism:
> 
> https://lkml.org/lkml/2012/1/14/55
> 
> With commit f9d4861f ("ARM: 7294/1: vectors: use gate_vma for vectors user
> mapping"), ARM does now use the gate_vma, so the PageReserved check can
> be removed from the proc code.
> 
> Cc: Nicolas Pitre <nico@linaro.org>
> Signed-off-by: Will Deacon <will.deacon@arm.com>

Oh, great, I'm glad that worked out: thanks a lot for looking after it,
Will, and now cleaning up afterwards.

Acked-by: Hugh Dickins <hughd@google.com>

> ---
>  fs/proc/task_mmu.c |    3 ---
>  1 files changed, 0 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 2b9a760..2d60492 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -597,9 +597,6 @@ static int clear_refs_pte_range(pmd_t *pmd, unsigned long addr,
>  		if (!page)
>  			continue;
>  
> -		if (PageReserved(page))
> -			continue;
> -
>  		/* Clear accessed and referenced bits. */
>  		ptep_test_and_clear_young(vma, addr, pte);
>  		ClearPageReferenced(page);
> -- 
> 1.7.4.1
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
