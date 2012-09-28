Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id B907F6B0068
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 04:45:58 -0400 (EDT)
Message-ID: <506562F9.6010707@parallels.com>
Date: Fri, 28 Sep 2012 12:42:33 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: CK1 [09/13] slab: rename nodelists to node
References: <20120926200005.911809821@linux.com> <0000013a0430a882-06cc02cd-4623-41f6-b4c9-702e0c37acb2-000000@email.amazonses.com>
In-Reply-To: <0000013a0430a882-06cc02cd-4623-41f6-b4c9-702e0c37acb2-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On 09/27/2012 12:07 AM, Christoph Lameter wrote:
> Have a common naming between both slab caches for future changes.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> Index: linux/include/linux/slab_def.h
> ===================================================================
> --- linux.orig/include/linux/slab_def.h	2012-09-19 09:21:35.811415438 -0500
> +++ linux/include/linux/slab_def.h	2012-09-19 09:21:37.499450510 -0500
> @@ -88,16 +88,13 @@ struct kmem_cache {
>  	 * We still use [NR_CPUS] and not [1] or [0] because cache_cache
>  	 * is statically defined, so we reserve the max number of cpus.
>  	 */
> -	struct kmem_cache_node **nodelists;
> +	struct kmem_cache_node **node;
>  	struct array_cache *array[NR_CPUS + MAX_NUMNODES];
>  	/*
>  	 * Do not add fields after array[]
>  	 */
>  };
>  
> -extern struct kmem_cache *cs_cachep[PAGE_SHIFT + MAX_ORDER];
> -extern struct kmem_cache *cs_dmacachep[PAGE_SHIFT + MAX_ORDER];
> -
>
>  void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
>  void *__kmalloc(size_t size, gfp_t flags);
>  
> @@ -132,10 +129,10 @@ static __always_inline void *kmalloc(siz
>  
>  #ifdef CONFIG_ZONE_DMA
>  		if (flags & GFP_DMA)
> -			cachep = cs_dmacachep[i];
> +			cachep = kmalloc_dma_caches[i];
>  		else
You had just changed this to those new names in patch 7. Why don't you
change it directly to kmalloc_{,dma}_caches ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
