Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id F0C866B01E3
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 12:02:48 -0400 (EDT)
Date: Tue, 13 Apr 2010 17:02:28 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 5/6] change alloc function in __vmalloc_area_node
Message-ID: <20100413160227.GF25756@csn.ul.ie>
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com> <2cb77846a9523201588c5dbf94b23d6ea737ce65.1271171877.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <2cb77846a9523201588c5dbf94b23d6ea737ce65.1271171877.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 14, 2010 at 12:25:02AM +0900, Minchan Kim wrote:
> __vmalloc_area_node never pass -1 to alloc_pages_node.
> It means node's validity check is unnecessary.
> So we can use alloc_pages_exact_node instead of alloc_pages_node.
> It could avoid comparison and branch as 6484eb3e2a81807722 tried.
> 

Seems fine, the check for node id being negative has already been made.

Reviewed-by: Mel Gorman <mel@csn.ul.ie>

> Cc: Nick Piggin <npiggin@suse.de>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> ---
>  mm/vmalloc.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index ae00746..7abf423 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1499,7 +1499,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
>  		if (node < 0)
>  			page = alloc_page(gfp_mask);
>  		else
> -			page = alloc_pages_node(node, gfp_mask, 0);
> +			page = alloc_pages_exact_node(node, gfp_mask, 0);
>  
>  		if (unlikely(!page)) {
>  			/* Successfully allocated i pages, free them in __vunmap() */
> -- 
> 1.7.0.5
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
