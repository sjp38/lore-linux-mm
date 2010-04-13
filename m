Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1E5FF6B01E3
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 11:33:02 -0400 (EDT)
Date: Tue, 13 Apr 2010 16:32:23 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/6] Remove node's validity check in alloc_pages
Message-ID: <20100413153223.GB25756@csn.ul.ie>
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 14, 2010 at 12:24:58AM +0900, Minchan Kim wrote:
> alloc_pages calls alloc_pages_node with numa_node_id().
> alloc_pages_node can't see nid < 0.
> 
> So we can use alloc_pages_exact_node instead of alloc_pages_node.
> It could avoid comparison and branch as 6484eb3e2a81807722 tried.
> 
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

Makes sense.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>

> ---
>  include/linux/gfp.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 4c6d413..b65f003 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -308,7 +308,7 @@ extern struct page *alloc_page_vma(gfp_t gfp_mask,
>  			struct vm_area_struct *vma, unsigned long addr);
>  #else
>  #define alloc_pages(gfp_mask, order) \
> -		alloc_pages_node(numa_node_id(), gfp_mask, order)
> +		alloc_pages_exact_node(numa_node_id(), gfp_mask, order)
>  #define alloc_page_vma(gfp_mask, vma, addr) alloc_pages(gfp_mask, 0)
>  #endif
>  #define alloc_page(gfp_mask) alloc_pages(gfp_mask, 0)
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
