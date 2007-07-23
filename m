Date: Mon, 23 Jul 2007 12:21:43 +0100
Subject: Re: [PATCH] add __GFP_ZERP to GFP_LEVEL_MASK
Message-ID: <20070723112143.GB19437@skynet.ie>
References: <1185185020.8197.11.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1185185020.8197.11.camel@twins>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Christoph Lameter <clameter@sgi.com>, Daniel Phillips <phillips@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On (23/07/07 12:03), Peter Zijlstra didst pronounce:
> 
> Daniel recently spotted that __GFP_ZERO is not (and has never been)
> part of GFP_LEVEL_MASK. I could not find a reason for this in the
> original patch: 3977971c7f09ce08ed1b8d7a67b2098eb732e4cd in the -bk
> tree.
> 
> This of course is in stark contradiction with the comment accompanying
> GFP_LEVEL_MASK.

This probably never showed up as a problem because slab is not using
__GFP_ZERO. If a flag is used with slab that is not in the level mask,
it goes *bang* as described in the comment.

Does this patch compile though?

> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

> ---
>  include/linux/gfp.h |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: linux-2.6-2/include/linux/gfp.h
> ===================================================================
> --- linux-2.6-2.orig/include/linux/gfp.h
> +++ linux-2.6-2/include/linux/gfp.h
> @@ -56,7 +56,7 @@ struct vm_area_struct;
>  /* if you forget to add the bitmask here kernel will crash, period */
>  #define GFP_LEVEL_MASK (__GFP_WAIT|__GFP_HIGH|__GFP_IO|__GFP_FS| \
>  			__GFP_COLD|__GFP_NOWARN|__GFP_REPEAT| \
> -			__GFP_NOFAIL|__GFP_NORETRY|__GFP_COMP| \
> +			__GFP_NOFAIL|__GFP_NORETRY|__GFP_COMP|__GFP_ZERO \

Should there be a | at the end there?

>  			__GFP_NOMEMALLOC|__GFP_HARDWALL|__GFP_THISNODE| \
>  			__GFP_MOVABLE)
>  
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
