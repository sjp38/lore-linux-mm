Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 3C5E36B0081
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 07:05:39 -0400 (EDT)
Date: Wed, 20 Jun 2012 13:05:13 +0200
From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: Re: [PATCH 01/17] mm: sl[au]b: Add knowledge of PFMEMALLOC reserve
 pages
Message-ID: <20120620110512.GA4208@breakpoint.cc>
References: <1340184920-22288-1-git-send-email-mgorman@suse.de>
 <1340184920-22288-2-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340184920-22288-2-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>

On Wed, Jun 20, 2012 at 10:35:04AM +0100, Mel Gorman wrote:
> [a.p.zijlstra@chello.nl: Original implementation]
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
> diff --git a/mm/slab.c b/mm/slab.c
> index e901a36..b190cac 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -1851,6 +1984,7 @@ static void kmem_freepages(struct kmem_cache *cachep, void *addr)
>  	while (i--) {
>  		BUG_ON(!PageSlab(page));
>  		__ClearPageSlab(page);
> +		__ClearPageSlabPfmemalloc(page);
>  		page++;
>  	}
>  	if (current->reclaim_state)
> @@ -3120,16 +3254,19 @@ bad:
> diff --git a/mm/slub.c b/mm/slub.c
> index 8c691fa..43738c9 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1414,6 +1418,7 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
>  		-pages);
>  
>  	__ClearPageSlab(page);
> +	__ClearPageSlabPfmemalloc(page);
>  	reset_page_mapcount(page);
>  	if (current->reclaim_state)
>  		current->reclaim_state->reclaimed_slab += pages;

So you mention a change here in v11's changelog but I don't see it.

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
