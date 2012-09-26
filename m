Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 6DFEC6B005D
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 06:04:47 -0400 (EDT)
Received: by ied10 with SMTP id 10so1186075ied.14
        for <linux-mm@kvack.org>; Wed, 26 Sep 2012 03:04:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1348571229-844-2-git-send-email-elezegarcia@gmail.com>
References: <1348571229-844-1-git-send-email-elezegarcia@gmail.com>
	<1348571229-844-2-git-send-email-elezegarcia@gmail.com>
Date: Wed, 26 Sep 2012 07:04:46 -0300
Message-ID: <CALF0-+W2sCo7FONp_w2fcP1J7vWoKRtgeZX0=uzat-5xaH8TTA@mail.gmail.com>
Subject: Re: [PATCH] mm/slab: Fix kmem_cache_alloc_node_trace() declaration
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>, kernel-janitors@vger.kernel.org, linux-mm@kvack.org
Cc: fengguang.wu@intel.com, David Rientjes <rientjes@google.com>

Pekka,

On Tue, Sep 25, 2012 at 8:07 AM, Ezequiel Garcia <elezegarcia@gmail.com> wrote:
> The bug was introduced in commit 4052147c0afa
> "mm, slab: Match SLAB and SLUB kmem_cache_alloc_xxx_trace() prototype".
>
> Cc: Pekka Enberg <penberg@kernel.org>
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Ezequiel Garcia <elezegarcia@gmail.com>
> ---
>  mm/slab.c |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/mm/slab.c b/mm/slab.c
> index ca3849f..3409ead 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -3862,10 +3862,10 @@ void *kmem_cache_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid)
>  EXPORT_SYMBOL(kmem_cache_alloc_node);
>
>  #ifdef CONFIG_TRACING
> -void *kmem_cache_alloc_node_trace(struct kmem_cache *cachep,
> +void *kmem_cache_alloc_node_trace(size_t size,
> +                                 struct kmem_cache *cachep,
>                                   gfp_t flags,
> -                                 int nodeid,
> -                                 size_t size)
> +                                 int nodeid)
>  {
>         void *ret;
>
> @@ -3887,7 +3887,7 @@ __do_kmalloc_node(size_t size, gfp_t flags, int node, unsigned long caller)
>         cachep = kmem_find_general_cachep(size, flags);
>         if (unlikely(ZERO_OR_NULL_PTR(cachep)))
>                 return cachep;
> -       return kmem_cache_alloc_node_trace(cachep, flags, node, size);
> +       return kmem_cache_alloc_node_trace(size, cachep, flags, node);
>  }
>
>  #if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_TRACING)
> --

Please revert this patch. This fix is wrong, I'll send a proper one.

Sorry for the mess,
Ezequiel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
