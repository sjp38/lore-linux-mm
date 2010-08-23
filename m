Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3C0706B0387
	for <linux-mm@kvack.org>; Sun, 22 Aug 2010 20:51:12 -0400 (EDT)
Date: Sun, 22 Aug 2010 19:51:07 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch] slob: fix gfp flags for order-0 page allocations
In-Reply-To: <alpine.DEB.2.00.1008221615350.29062@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1008221950070.24422@router.home>
References: <alpine.DEB.2.00.1008221615350.29062@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> diff --git a/mm/slob.c b/mm/slob.c
> --- a/mm/slob.c
> +++ b/mm/slob.c
> @@ -500,7 +500,9 @@ void *__kmalloc_node(size_t size, gfp_t gfp, int node)
>  	} else {
>  		unsigned int order = get_order(size);
>
> -		ret = slob_new_pages(gfp | __GFP_COMP, get_order(size), node);
> +		if (likely(order))
> +			gfp |= __GFP_COMP;
> +		ret = slob_new_pages(gfp, order, node);
>  		if (ret) {
>  			struct page *page;

Also gets rid of the double get_order().

Reviewed-by: Christoph Lameter <cl@linux.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
