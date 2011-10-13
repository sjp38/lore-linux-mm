Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2AE296B002F
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 09:15:45 -0400 (EDT)
Date: Thu, 13 Oct 2011 15:15:40 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm/huge_memory: Clean up typo when updating mmu cache
Message-ID: <20111013131540.GA3328@redhat.com>
References: <CAJd=RBALaNJ680JzCP8KUaDO80dM+9_AK5yW9SSVoUD0G1Cxzw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBALaNJ680JzCP8KUaDO80dM+9_AK5yW9SSVoUD0G1Cxzw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, Oct 13, 2011 at 08:52:22PM +0800, Hillf Danton wrote:
> Hi Andrea
> 
> There are three cases of update_mmu_cache() in the file, and the case in
> function collapse_huge_page() has a typo, namely the last parameter used,
> which is corrected based on the other two cases.
> 
> Due to the define of update_mmu_cache by X86, the only arch that implements
> THP currently, the change here has no really crystal point, but one or two
> minutes of efforts could be saved for those archs that are likely to support
> THP in future.

Yes, like the previous one, they make no runtime difference today, but
they may save some debug time to who's porting THP to some other arch
in the future, so it's good to clean this up, thanks.

> Signed-off-by: Hillf Danton <dhillf@gmail.com>
> ---
> 
> --- a/mm/huge_memory.c	Sat Aug 13 11:45:14 2011
> +++ b/mm/huge_memory.c	Thu Oct 13 20:07:29 2011
> @@ -1906,7 +1906,7 @@ static void collapse_huge_page(struct mm
>  	BUG_ON(!pmd_none(*pmd));
>  	page_add_new_anon_rmap(new_page, vma, address);
>  	set_pmd_at(mm, address, pmd, _pmd);
> -	update_mmu_cache(vma, address, entry);
> +	update_mmu_cache(vma, address, _pmd);
>  	prepare_pmd_huge_pte(pgtable, mm);
>  	mm->nr_ptes--;
>  	spin_unlock(&mm->page_table_lock);

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
