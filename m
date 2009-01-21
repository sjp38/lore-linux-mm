Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A2DEA6B0044
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 03:01:24 -0500 (EST)
Received: by ti-out-0910.google.com with SMTP id j3so2743279tid.8
        for <linux-mm@kvack.org>; Wed, 21 Jan 2009 00:01:21 -0800 (PST)
Date: Wed, 21 Jan 2009 17:00:39 +0900
From: MinChan Kim <minchan.kim@gmail.com>
Subject: Re: [patch][rfc] lockdep: annotate reclaim context (__GFP_NOFS)
Message-ID: <20090121080039.GB17969@barrios-desktop>
References: <20090120083906.GA19505@wotan.suse.de> <1232447354.4886.47.camel@laptop> <20090121071239.GL24891@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090121071239.GL24891@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, mingo@redhat.com
List-ID: <linux-mm.kvack.org>

Hi, Nick.

> Index: linux-2.6/mm/slob.c
> ===================================================================
> --- linux-2.6.orig/mm/slob.c
> +++ linux-2.6/mm/slob.c
> @@ -464,6 +464,8 @@ void *__kmalloc_node(size_t size, gfp_t
>  	unsigned int *m;
>  	int align = max(ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
>  
> +	lockdep_trace_alloc(flags);
> +
>  	if (size < PAGE_SIZE - align) {
>  		if (!size)
>  			return ZERO_SIZE_PTR;
> @@ -569,6 +571,8 @@ void *kmem_cache_alloc_node(struct kmem_
>  {
>  	void *b;
>  
> +	lockdep_trace_alloc(flags);
> +
>  	if (c->size < PAGE_SIZE)
>  		b = slob_alloc(c->size, flags, c->align, node);
>  	else
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c
> +++ linux-2.6/mm/slub.c
> @@ -1596,6 +1596,7 @@ static __always_inline void *slab_alloc(
>  	unsigned long flags;
>  	unsigned int objsize;
>  
> +	lockdep_trace_alloc(flags);

Probably, not flags but gfpflags ?


>  	might_sleep_if(gfpflags & __GFP_WAIT);
>  
>  	if (should_failslab(s->objsize, gfpflags))
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
Kinds Regards,
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
