Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A048D6B004D
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 11:39:09 -0400 (EDT)
Date: Thu, 30 Jul 2009 17:36:58 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/5] mm: Add kmalloc NULL tests
Message-ID: <20090730153658.GA22986@cmpxchg.org>
References: <Pine.LNX.4.64.0907301608350.8734@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0907301608350.8734@ask.diku.dk>
Sender: owner-linux-mm@kvack.org
To: Julia Lawall <julia@diku.dk>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hello Julia,

On Thu, Jul 30, 2009 at 04:10:22PM +0200, Julia Lawall wrote:

> diff --git a/mm/slab.c b/mm/slab.c
> index 7b5d4de..972e427 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -1502,6 +1502,7 @@ void __init kmem_cache_init(void)
>  
>  		ptr = kmalloc(sizeof(struct arraycache_init), GFP_NOWAIT);
>  
> +		BUG_ON(!ptr);
>  		BUG_ON(cpu_cache_get(&cache_cache) != &initarray_cache.cache);
>  		memcpy(ptr, cpu_cache_get(&cache_cache),
>  		       sizeof(struct arraycache_init));

This does not change the end result when the allocation fails: you get
a stacktrace and a kernel panic.  Leaving it as is saves a line of
code.

> @@ -1514,6 +1515,7 @@ void __init kmem_cache_init(void)
>  
>  		ptr = kmalloc(sizeof(struct arraycache_init), GFP_NOWAIT);
>  
> +		BUG_ON(!ptr);
>  		BUG_ON(cpu_cache_get(malloc_sizes[INDEX_AC].cs_cachep)
>  		       != &initarray_generic.cache);
>  		memcpy(ptr, cpu_cache_get(malloc_sizes[INDEX_AC].cs_cachep),

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
