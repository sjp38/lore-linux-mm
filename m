Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DDCD66B01E3
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 17:38:06 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [10.3.21.3])
	by smtp-out.google.com with ESMTP id o3DLbxNl018298
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 14:38:00 -0700
Received: from pzk5 (pzk5.prod.google.com [10.243.19.133])
	by hpaq3.eem.corp.google.com with ESMTP id o3DLbuMA020107
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 23:37:58 +0200
Received: by pzk5 with SMTP id 5so4662874pzk.14
        for <linux-mm@kvack.org>; Tue, 13 Apr 2010 14:37:56 -0700 (PDT)
Date: Tue, 13 Apr 2010 14:37:52 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/6] change alloc function in alloc_slab_page
In-Reply-To: <8b348d9cc1ea4960488b193b7e8378876918c0d4.1271171877.git.minchan.kim@gmail.com>
Message-ID: <alpine.DEB.2.00.1004131437140.8617@chino.kir.corp.google.com>
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com> <8b348d9cc1ea4960488b193b7e8378876918c0d4.1271171877.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Wed, 14 Apr 2010, Minchan Kim wrote:

> alloc_slab_page never calls alloc_pages_node with -1.
> It means node's validity check is unnecessary.
> So we can use alloc_pages_exact_node instead of alloc_pages_node.
> It could avoid comparison and branch as 6484eb3e2a81807722 tried.
> 
> Cc: Christoph Lameter <cl@linux-foundation.org>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
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

Slub changes need to go through its maintainer, Pekka Enberg 
<penberg@cs.helsinki.fi>.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
