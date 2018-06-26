Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id C5B6B6B0005
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 07:03:04 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id d6-v6so9915657plo.15
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 04:03:04 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 1-v6si1336547plw.519.2018.06.26.04.03.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Jun 2018 04:03:03 -0700 (PDT)
Date: Tue, 26 Jun 2018 13:03:00 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm:mempool:fixed coding style errors and warnings.
Message-ID: <20180626110300.GC29102@dhcp22.suse.cz>
References: <1529946737-7693-1-git-send-email-thisisathi@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1529946737-7693-1-git-send-email-thisisathi@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Athira-Selvan <thisisathi@gmail.com>
Cc: akpm@linux-foundation.org, jthumshirn@suse.de, tglx@linutronix.de, kent.overstreet@gmail.com, linux-mm@kvack.org

On Mon 25-06-18 22:42:17, Athira-Selvan wrote:
> This patch fixes checkpatch.pl:
> WARNING: Missing a blank line after declarations
> ERROR: missing space brfore ','

I am not really sure this improves readability enough to add the churn
into the code. mempool is not the heaviest modified file but still,
making style changes without any further changes in the area are usually
quite weak to justify. They are just adding an additional hop in git
blame tracking without a good reason. Sure sometimes the end code is so
much easier to read that the change is worthwhile but I do not see it
here.

Others might think differently though.

> Signed-off-by: Athira Selvam <thisisathi@gmail.com>
> ---
>  mm/mempool.c | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/mempool.c b/mm/mempool.c
> index b54f2c2..c3a7b7b 100644
> --- a/mm/mempool.c
> +++ b/mm/mempool.c
> @@ -152,6 +152,7 @@ void mempool_exit(mempool_t *pool)
>  {
>  	while (pool->curr_nr) {
>  		void *element = remove_element(pool, GFP_KERNEL);
> +
>  		pool->free(element, pool->pool_data);
>  	}
>  	kfree(pool->elements);
> @@ -248,7 +249,7 @@ EXPORT_SYMBOL(mempool_init);
>  mempool_t *mempool_create(int min_nr, mempool_alloc_t *alloc_fn,
>  				mempool_free_t *free_fn, void *pool_data)
>  {
> -	return mempool_create_node(min_nr,alloc_fn,free_fn, pool_data,
> +	return mempool_create_node(min_nr, alloc_fn, free_fn, pool_data,
>  				   GFP_KERNEL, NUMA_NO_NODE);
>  }
>  EXPORT_SYMBOL(mempool_create);
> @@ -500,6 +501,7 @@ EXPORT_SYMBOL(mempool_free);
>  void *mempool_alloc_slab(gfp_t gfp_mask, void *pool_data)
>  {
>  	struct kmem_cache *mem = pool_data;
> +
>  	VM_BUG_ON(mem->ctor);
>  	return kmem_cache_alloc(mem, gfp_mask);
>  }
> @@ -508,6 +510,7 @@ EXPORT_SYMBOL(mempool_alloc_slab);
>  void mempool_free_slab(void *element, void *pool_data)
>  {
>  	struct kmem_cache *mem = pool_data;
> +
>  	kmem_cache_free(mem, element);
>  }
>  EXPORT_SYMBOL(mempool_free_slab);
> @@ -519,6 +522,7 @@ EXPORT_SYMBOL(mempool_free_slab);
>  void *mempool_kmalloc(gfp_t gfp_mask, void *pool_data)
>  {
>  	size_t size = (size_t)pool_data;
> +
>  	return kmalloc(size, gfp_mask);
>  }
>  EXPORT_SYMBOL(mempool_kmalloc);
> @@ -536,6 +540,7 @@ EXPORT_SYMBOL(mempool_kfree);
>  void *mempool_alloc_pages(gfp_t gfp_mask, void *pool_data)
>  {
>  	int order = (int)(long)pool_data;
> +
>  	return alloc_pages(gfp_mask, order);
>  }
>  EXPORT_SYMBOL(mempool_alloc_pages);
> @@ -543,6 +548,7 @@ EXPORT_SYMBOL(mempool_alloc_pages);
>  void mempool_free_pages(void *element, void *pool_data)
>  {
>  	int order = (int)(long)pool_data;
> +
>  	__free_pages(element, order);
>  }
>  EXPORT_SYMBOL(mempool_free_pages);
> -- 
> 2.7.4

-- 
Michal Hocko
SUSE Labs
