Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2D5086B002D
	for <linux-mm@kvack.org>; Thu,  3 Nov 2011 17:40:41 -0400 (EDT)
Received: by ywa17 with SMTP id 17so2319242ywa.14
        for <linux-mm@kvack.org>; Thu, 03 Nov 2011 14:40:38 -0700 (PDT)
Date: Thu, 3 Nov 2011 14:40:34 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] slab: rename slab_break_gfp_order to
 slab_max_order
In-Reply-To: <alpine.DEB.2.00.1110182207500.5907@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1111031440130.31612@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1110182207500.5907@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <cl@gentwo.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 18 Oct 2011, David Rientjes wrote:

> slab_break_gfp_order is more appropriately named slab_max_order since it
> enforces the maximum order size of slabs as long as a single object will
> still fit.
> 
> Also rename BREAK_GFP_ORDER_{LO,HI} accordingly.
> 

Ping on these two patches?  I don't see them in slab/next.

> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/slab.c |   10 +++++-----
>  1 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/slab.c b/mm/slab.c
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -481,9 +481,9 @@ EXPORT_SYMBOL(slab_buffer_size);
>  /*
>   * Do not go above this order unless 0 objects fit into the slab.
>   */
> -#define	BREAK_GFP_ORDER_HI	1
> -#define	BREAK_GFP_ORDER_LO	0
> -static int slab_break_gfp_order = BREAK_GFP_ORDER_LO;
> +#define	SLAB_MAX_ORDER_HI	1
> +#define	SLAB_MAX_ORDER_LO	0
> +static int slab_max_order = SLAB_MAX_ORDER_LO;
>  
>  /*
>   * Functions for storing/retrieving the cachep and or slab from the page
> @@ -1502,7 +1502,7 @@ void __init kmem_cache_init(void)
>  	 * page orders on machines with more than 32MB of memory.
>  	 */
>  	if (totalram_pages > (32 << 20) >> PAGE_SHIFT)
> -		slab_break_gfp_order = BREAK_GFP_ORDER_HI;
> +		slab_max_order = SLAB_MAX_ORDER_HI;
>  
>  	/* Bootstrap is tricky, because several objects are allocated
>  	 * from caches that do not exist yet:
> @@ -2112,7 +2112,7 @@ static size_t calculate_slab_order(struct kmem_cache *cachep,
>  		 * Large number of objects is good, but very large slabs are
>  		 * currently bad for the gfp()s.
>  		 */
> -		if (gfporder >= slab_break_gfp_order)
> +		if (gfporder >= slab_max_order)
>  			break;
>  
>  		/*
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
