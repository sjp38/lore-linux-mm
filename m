Date: Tue, 8 May 2007 14:15:42 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: SLUB: Reduce antifrag max order
In-Reply-To: <Pine.LNX.4.64.0705050925350.27136@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0705081411440.20563@skynet.skynet.ie>
References: <Pine.LNX.4.64.0705050925350.27136@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 5 May 2007, Christoph Lameter wrote:

> My test systems fails to obtain order 4 allocs after prolonged use.
> So the Antifragmentation patches are unable to guarantee order 4
> blocks after a while (straight compile, edit load).
>

Anti-frag still depends on reclaim to take place and I imagine you have 
not altered min_free_kbytes to keep pages free. Also, I don't think kswapd 
is currently making any effort to keep blocks free at a known desired 
order although I'm cc'ing Andy Whitcroft to confirm. As the kernel gives 
up easily when order > PAGE_ALLOC_COSTLY_ORDER, prehaps you should be 
using PAGE_ALLOC_COSTLY_ORDER instead of DEFAULT_ANTIFRAG_MAX_ORDER for 
SLUB.

> Reduce the the max order if antifrag measures are detected to 3.
>
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
>
> ---
> mm/slub.c |    2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
> Index: slub/mm/slub.c
> ===================================================================
> --- slub.orig/mm/slub.c	2007-05-05 09:19:32.000000000 -0700
> +++ slub/mm/slub.c	2007-05-05 09:22:00.000000000 -0700
> @@ -129,7 +129,7 @@
>  * If antifragmentation methods are in effect then increase the
>  * slab sizes to increase performance
>  */
> -#define DEFAULT_ANTIFRAG_MAX_ORDER 4
> +#define DEFAULT_ANTIFRAG_MAX_ORDER 3
> #define DEFAULT_ANTIFRAG_MIN_OBJECTS 16
>
> /*
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
