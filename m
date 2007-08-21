Date: Tue, 21 Aug 2007 16:27:10 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [RFC][PATCH 6/9] pagemap: give -1's a name
Message-ID: <20070821212710.GK30556@waste.org>
References: <20070821204248.0F506A29@kernel> <20070821204254.E248E22C@kernel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070821204254.E248E22C@kernel>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 21, 2007 at 01:42:54PM -0700, Dave Hansen wrote:
> 
> -1 is a magic number in /proc/$pid/pagemap.  It means that
> there was no pte present for a particular page.  We're
> going to be refining that a bit shortly, so give this a
> real name for now.
> 
> Signed-off-by: Dave Hansen <haveblue@us.ibm.com>

Acked-by: Matt Mackall <mpm@selenic.com>

> ---
> 
>  lxc-dave/fs/proc/task_mmu.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff -puN fs/proc/task_mmu.c~give_-1s_a_name fs/proc/task_mmu.c
> --- lxc/fs/proc/task_mmu.c~give_-1s_a_name	2007-08-21 13:30:53.000000000 -0700
> +++ lxc-dave/fs/proc/task_mmu.c	2007-08-21 13:30:53.000000000 -0700
> @@ -509,6 +509,7 @@ struct pagemapread {
>  };
>  
>  #define PM_ENTRY_BYTES sizeof(unsigned long)
> +#define PM_NOT_PRESENT ((unsigned long)-1)
>  
>  static int add_to_pagemap(unsigned long addr, unsigned long pfn,
>  			  struct pagemapread *pm)
> @@ -533,7 +534,7 @@ static int pagemap_pte_range(pmd_t *pmd,
>  		if (addr < pm->next)
>  			continue;
>  		if (!pte_present(*pte))
> -			err = add_to_pagemap(addr, -1, pm);
> +			err = add_to_pagemap(addr, PM_NOT_PRESENT, pm);
>  		else
>  			err = add_to_pagemap(addr, pte_pfn(*pte), pm);
>  		if (err)
> _

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
