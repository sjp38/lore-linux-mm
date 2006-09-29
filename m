Date: Fri, 29 Sep 2006 09:10:55 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC/PATCH] slab: clean up allocation
In-Reply-To: <Pine.LNX.4.58.0609291353060.30021@sbz-30.cs.Helsinki.FI>
Message-ID: <Pine.LNX.4.64.0609290906350.23840@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.58.0609291353060.30021@sbz-30.cs.Helsinki.FI>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Cc: manfred@colorfullife.com, christoph@lameter.com, pj@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 29 Sep 2006, Pekka J Enberg wrote:

> + * When allocating from current node.
> + */
> +#define SLAB_CURRENT_NODE (-1)
> +

If we want a constant here then we would better define a global one and 
use it throughout the kernel.

Something like

#define LOCAL_NODE (-1)

Maybe in include/*/topology.h ?


>  #endif
>  
> -static inline void *____cache_alloc(struct kmem_cache *cachep, gfp_t flags)
> +static inline void *cache_alloc_local(struct kmem_cache *cachep, gfp_t flags)
>  {
>  	void *objp;
>  	struct array_cache *ac;
> @@ -3059,35 +3064,6 @@ static inline void *____cache_alloc(stru
>  	return objp;
>  }

This is not really local in the sense of node local but its processor 
local. The speciality here is that we allocate from the per processor
list of objects. cache_alloc_cpu?

The rest looks fine on first glance.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
