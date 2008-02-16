Message-ID: <47B6A787.6020502@cs.helsinki.fi>
Date: Sat, 16 Feb 2008 11:06:15 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [patch 5/8] slub: Fallback to order 0 during slab page allocation
References: <20080215230811.635628223@sgi.com> <20080215230854.132617990@sgi.com>
In-Reply-To: <20080215230854.132617990@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> If any higher order allocation fails then fall back to an order 0 allocation
> if the object is smaller than PAGE_SIZE.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> ---
>  include/linux/slub_def.h |    2 +
>  mm/slub.c                |   54 ++++++++++++++++++++++++++++++++++++++---------
>  2 files changed, 46 insertions(+), 10 deletions(-)
> 
> Index: linux-2.6/include/linux/slub_def.h
> ===================================================================
> --- linux-2.6.orig/include/linux/slub_def.h	2008-02-15 13:58:28.705371769 -0800
> +++ linux-2.6/include/linux/slub_def.h	2008-02-15 13:59:48.918454617 -0800
> @@ -29,6 +29,7 @@ enum stat_item {
>  	DEACTIVATE_TO_HEAD,	/* Cpu slab was moved to the head of partials */
>  	DEACTIVATE_TO_TAIL,	/* Cpu slab was moved to the tail of partials */
>  	DEACTIVATE_REMOTE_FREES,/* Slab contained remotely freed objects */
> +	ORDER_FALLBACK,	/* Allocation that fell back to order 0 */
>  	NR_SLUB_STAT_ITEMS };
>  
>  struct kmem_cache_cpu {
> @@ -72,6 +73,7 @@ struct kmem_cache {
>  
>  	/* Allocation and freeing of slabs */
>  	int objects;		/* Number of objects in a slab of maximum size */
> +	int objects0;		/* Number of object in an order 0 size slab */

As I mentioned in a previous mail, I think the should be "max_objects" 
and "objects", respectively. Other than that, looks good.

Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
