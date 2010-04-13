Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E96AC6B01F2
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 12:13:47 -0400 (EDT)
Date: Tue, 13 Apr 2010 17:13:26 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 6/6] Add comment in alloc_pages_exact_node
Message-ID: <20100413161326.GG25756@csn.ul.ie>
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com> <d74305233536342dfeb1ca7ffe9e83495ce1f285.1271171877.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <d74305233536342dfeb1ca7ffe9e83495ce1f285.1271171877.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 14, 2010 at 12:25:03AM +0900, Minchan Kim wrote:
> alloc_pages_exact_node naming makes some people misleading.
> They considered it following as.
> "This function will allocate pages from node which I wanted
> exactly".
> But it can allocate pages from fallback list if page allocator
> can't find free page from node user wanted.
> 
> So let's comment this NOTE.
> 

It's a little tough to read. How about

/*
 * Use this instead of alloc_pages_node when the caller knows
 * exactly which node they need (as opposed to passing in -1
 * for current). Fallback to other nodes will still occur
 * unless __GFP_THISNODE is specified.
 */

That at least will tie in why "exact" is in the name?

> Actually I wanted to change naming with better.
> ex) alloc_pages_explict_node.

"Explicit" can also be taken to mean "this and only this node".

> But I changed my mind since the comment would be enough.
> 
> If anybody suggests better name, I will do with pleasure.
> 
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Bob Liu <lliubbo@gmail.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> ---
>  include/linux/gfp.h |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index b65f003..7539c17 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -288,6 +288,11 @@ static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
>  	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
>  }
>  
> +/*
> + * NOTE : Allow page from fallback if page allocator can't find free page
> + * in your nid. Only if you want to allocate page from your nid, use
> + * __GFP_THISNODE flags with gfp_mask.
> + */
>  static inline struct page *alloc_pages_exact_node(int nid, gfp_t gfp_mask,
>  						unsigned int order)
>  {
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
