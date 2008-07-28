Date: Mon, 28 Jul 2008 21:40:00 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: + mm-remove-find_max_pfn_with_active_regions.patch added to -mm tree
Message-ID: <20080728203959.GA29548@csn.ul.ie>
References: <200807280313.m6S3DHDk017400@imap1.linux-foundation.org> <20080728091655.GC7965@csn.ul.ie> <86802c440807280415j5605822brb8836412a5c95825@mail.gmail.com> <20080728113836.GE7965@csn.ul.ie> <86802c440807281125g7d424f17v4b7c512929f45367@mail.gmail.com> <20080728191518.GA5352@csn.ul.ie> <86802c440807281238u63770318s8e665754f666c602@mail.gmail.com> <20080728200054.GB5352@csn.ul.ie> <86802c440807281314k56752cdcqcac542b6f1564036@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <86802c440807281314k56752cdcqcac542b6f1564036@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (28/07/08 13:14), Yinghai Lu didst pronounce:
> > <SNIP>
> >
> > I'm not seeing what different a rename of the parameter will do. Even if
> > the parameter was renamed, it does not mean current trace information during
> > memory initialisation needs to be outputted as KERN_INFO which is what this
> > patch is doing. I am still failing to understand why you want this information
> > to be generally available.
> 
> how about KERN_DEBUG?
> 
> please check
> 

Still NAK due to the noise. Admittedly, I introduced the noise
in the first place but it was complained about then as well. See
http://lkml.org/lkml/2006/11/27/124 and later this
http://lkml.org/lkml/2006/11/27/134 . 

At the risk of repeating myself, I am still failing to understand why you want
this information to be generally available at any loglevel. My expectation is
that the information is only of relevance when debugging memory initialisation
problems in which case mminit_loglevel can be used.

> Index: linux-2.6/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.orig/mm/page_alloc.c
> +++ linux-2.6/mm/page_alloc.c
> @@ -3418,8 +3418,7 @@ static void __paginginit free_area_init_
>                         PAGE_ALIGN(size * sizeof(struct page)) >> PAGE_SHIFT;
>                 if (realsize >= memmap_pages) {
>                         realsize -= memmap_pages;
> -                       mminit_dprintk(MMINIT_TRACE, "memmap_init",
> -                               "%s zone: %lu pages used for memmap\n",
> +                       printk(KERN_DEBUG "%s zone: %lu pages used for
> memmap\n",
>                                 zone_names[j], memmap_pages);
>                 } else
>                         printk(KERN_WARNING
> @@ -3429,8 +3428,7 @@ static void __paginginit free_area_init_
>                 /* Account for reserved pages */
>                 if (j == 0 && realsize > dma_reserve) {
>                         realsize -= dma_reserve;
> -                       mminit_dprintk(MMINIT_TRACE, "memmap_init",
> -                                       "%s zone: %lu pages reserved\n",
> +                       printk(KERN_DEBUG "%s zone: %lu pages reserved\n",
>                                         zone_names[0], dma_reserve);
>                 }
> 
> @@ -3572,8 +3570,7 @@ void __init add_active_range(unsigned in
>  {
>         int i;
> 
> -       mminit_dprintk(MMINIT_TRACE, "memory_register",
> -                       "Entering add_active_range(%d, %#lx, %#lx) "
> +       printk(KERN_DEBUG "Adding active range (%d, %#lx, %#lx) "
>                         "%d entries of %d used\n",
>                         nid, start_pfn, end_pfn,
>                         nr_nodemap_entries, MAX_ACTIVE_REGIONS);
> @@ -3635,7 +3632,7 @@ void __init remove_active_range(unsigned
>         int i, j;
>         int removed = 0;
> 
> -       printk(KERN_DEBUG "remove_active_range (%d, %lu, %lu)\n",
> +       printk(KERN_DEBUG "Removing active range (%d, %#lx, %#lx)\n",
>                           nid, start_pfn, end_pfn);
> 
>         /* Find the old active region end and shrink */
> 
> 
> YH
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
