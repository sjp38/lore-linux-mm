Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id C92626B0068
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 15:49:27 -0400 (EDT)
Date: Mon, 2 Jul 2012 14:49:23 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: Fix signal SIGFPE in slabinfo.c.
In-Reply-To: <201206260930282811070@gmail.com>
Message-ID: <alpine.DEB.2.00.1207021448340.31690@router.home>
References: <201206260930282811070@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: "fengguang.wu" <fengguang.wu@intel.com>, majianpeng <majianpeng@gmail.com>, linux-mm@kvack.org

Acked-by: Christoph Lameter <cl@linux.com>

On Tue, 26 Jun 2012, majianpeng wrote:

> In function slab_stats(), if total_free is equal zero, it will error.
> So fix it.
> Signed-off-by: majianpeng <majianpeng@gmail.com>
> ---
>  tools/vm/slabinfo.c |   14 +++++++-------
>  1 files changed, 7 insertions(+), 7 deletions(-)
>
> diff --git a/tools/vm/slabinfo.c b/tools/vm/slabinfo.c
> index 164cbcf..808d5a9 100644
> --- a/tools/vm/slabinfo.c
> +++ b/tools/vm/slabinfo.c
> @@ -437,34 +437,34 @@ static void slab_stats(struct slabinfo *s)
>  	printf("Fastpath             %8lu %8lu %3lu %3lu\n",
>  		s->alloc_fastpath, s->free_fastpath,
>  		s->alloc_fastpath * 100 / total_alloc,
> -		s->free_fastpath * 100 / total_free);
> +		total_free ? s->free_fastpath * 100 / total_free : 0);
>  	printf("Slowpath             %8lu %8lu %3lu %3lu\n",
>  		total_alloc - s->alloc_fastpath, s->free_slowpath,
>  		(total_alloc - s->alloc_fastpath) * 100 / total_alloc,
> -		s->free_slowpath * 100 / total_free);
> +		total_free ? s->free_slowpath * 100 / total_free : 0);
>  	printf("Page Alloc           %8lu %8lu %3lu %3lu\n",
>  		s->alloc_slab, s->free_slab,
>  		s->alloc_slab * 100 / total_alloc,
> -		s->free_slab * 100 / total_free);
> +		total_free ? s->free_slab * 100 / total_free : 0);
>  	printf("Add partial          %8lu %8lu %3lu %3lu\n",
>  		s->deactivate_to_head + s->deactivate_to_tail,
>  		s->free_add_partial,
>  		(s->deactivate_to_head + s->deactivate_to_tail) * 100 / total_alloc,
> -		s->free_add_partial * 100 / total_free);
> +		total_free ? s->free_add_partial * 100 / total_free : 0);
>  	printf("Remove partial       %8lu %8lu %3lu %3lu\n",
>  		s->alloc_from_partial, s->free_remove_partial,
>  		s->alloc_from_partial * 100 / total_alloc,
> -		s->free_remove_partial * 100 / total_free);
> +		total_free ? s->free_remove_partial * 100 / total_free : 0);
>
>  	printf("Cpu partial list     %8lu %8lu %3lu %3lu\n",
>  		s->cpu_partial_alloc, s->cpu_partial_free,
>  		s->cpu_partial_alloc * 100 / total_alloc,
> -		s->cpu_partial_free * 100 / total_free);
> +		total_free ? s->cpu_partial_free * 100 / total_free : 0);
>
>  	printf("RemoteObj/SlabFrozen %8lu %8lu %3lu %3lu\n",
>  		s->deactivate_remote_frees, s->free_frozen,
>  		s->deactivate_remote_frees * 100 / total_alloc,
> -		s->free_frozen * 100 / total_free);
> +		total_free ? s->free_frozen * 100 / total_free : 0);
>
>  	printf("Total                %8lu %8lu\n\n", total_alloc, total_free);
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
