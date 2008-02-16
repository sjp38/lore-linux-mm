Message-ID: <47B6A7EB.8060005@cs.helsinki.fi>
Date: Sat, 16 Feb 2008 11:07:55 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [patch 6/8] slub: Drop fallback to page allocator method
References: <20080215230811.635628223@sgi.com> <20080215230854.391263372@sgi.com>
In-Reply-To: <20080215230854.391263372@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> Since there is now a in slub method of falling back to an order 0 slab we no
> longer need the fallback to the page allocator.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>

> @@ -2614,7 +2585,7 @@ static struct kmem_cache *create_kmalloc
>  
>  	down_write(&slub_lock);
>  	if (!kmem_cache_open(s, gfp_flags, name, size, ARCH_KMALLOC_MINALIGN,
> -			flags | __KMALLOC_CACHE, NULL))
> +								flags, NULL))

Did you fell asleep on the tab key? The indentation looks pretty crazy 
right here ;-)-

Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
