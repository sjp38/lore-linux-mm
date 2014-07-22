Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id D85FD6B0036
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 17:57:58 -0400 (EDT)
Received: by mail-ie0-f174.google.com with SMTP id rp18so253369iec.5
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 14:57:58 -0700 (PDT)
Received: from mail-ig0-x231.google.com (mail-ig0-x231.google.com [2607:f8b0:4001:c05::231])
        by mx.google.com with ESMTPS id r9si844936icw.27.2014.07.22.14.57.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Jul 2014 14:57:58 -0700 (PDT)
Received: by mail-ig0-f177.google.com with SMTP id hn18so749509igb.16
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 14:57:57 -0700 (PDT)
Date: Tue, 22 Jul 2014 14:57:55 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: trivial comment cleanup in slab.c
In-Reply-To: <53CE11C1.1030306@gmail.com>
Message-ID: <alpine.DEB.2.02.1407221457010.5814@chino.kir.corp.google.com>
References: <53CE11C1.1030306@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Sheng-Hui <shhuiw@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue, 22 Jul 2014, Wang Sheng-Hui wrote:

> 
> Current struct kmem_cache has no 'lock' field, and slab page is
> managed by struct kmem_cache_node, which has 'list_lock' field.
> 
> Clean up the related comment.
> 

I think this is fine, but not sure if the s/slab/slab page/ change makes 
anything clearer and is unmentioned in the changelog.

> Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
> ---
>  mm/slab.c | 9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/slab.c b/mm/slab.c
> index 3070b92..8f7170f 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -1724,7 +1724,8 @@ slab_out_of_memory(struct kmem_cache *cachep, gfp_t gfpflags, int nodeid)
>  }
> 
>  /*
> - * Interface to system's page allocator. No need to hold the cache-lock.
> + * Interface to system's page allocator. No need to hold the
> + * kmem_cache_node ->list_lock.
>   *
>   * If we requested dmaable memory, we will get it. Even if we
>   * did not request dmaable memory, we might get it, but that
> @@ -2026,9 +2027,9 @@ static void slab_destroy_debugcheck(struct kmem_cache *cachep,
>   * @cachep: cache pointer being destroyed
>   * @page: page pointer being destroyed
>   *
> - * Destroy all the objs in a slab, and release the mem back to the system.
> - * Before calling the slab must have been unlinked from the cache.  The
> - * cache-lock is not held/needed.
> + * Destroy all the objs in a slab page, and release the mem back to the system.
> + * Before calling the slab page must have been unlinked from the cache. The
> + * kmem_cache_node ->list_lock is not held/needed.
>   */
>  static void slab_destroy(struct kmem_cache *cachep, struct page *page)
>  {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
