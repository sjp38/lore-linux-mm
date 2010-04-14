Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 391AE6B01EF
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 13:50:10 -0400 (EDT)
Message-ID: <4BC6004A.9020403@cs.helsinki.fi>
Date: Wed, 14 Apr 2010 20:50:02 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH v2] change alloc function in alloc_slab_page
References: <1271257119-30117-1-git-send-email-minchan.kim@gmail.com> <1271257119-30117-3-git-send-email-minchan.kim@gmail.com>
In-Reply-To: <1271257119-30117-3-git-send-email-minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Minchan Kim wrote:
> V2
> * change changelog
> * Add some reviewed-by 
> 
> alloc_slab_page always checks nid == -1, so alloc_page_node can't be
> called with -1. 
> It means node's validity check in alloc_pages_node is unnecessary. 
> So we can use alloc_pages_exact_node instead of alloc_pages_node. 
> It could avoid comparison and branch as 6484eb3e2a81807722 tried.
> 
> Cc: Pekka Enberg <penberg@cs.helsinki.fi>
> Cc: Christoph Lameter <cl@linux-foundation.org>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Reviewed-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  mm/slub.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index b364844..9984165 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1084,7 +1084,7 @@ static inline struct page *alloc_slab_page(gfp_t flags, int node,
>  	if (node == -1)
>  		return alloc_pages(flags, order);
>  	else
> -		return alloc_pages_node(node, flags, order);
> +		return alloc_pages_exact_node(node, flags, order);
>  }
>  
>  static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
