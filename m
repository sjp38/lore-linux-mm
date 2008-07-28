Subject: Re: [2.6 patch] unexport ksize
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <20080722172116.GW14846@cs181140183.pp.htv.fi>
References: <20080722172116.GW14846@cs181140183.pp.htv.fi>
Date: Mon, 28 Jul 2008 12:33:26 +0300
Message-Id: <1217237607.7813.6.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adrian Bunk <bunk@kernel.org>
Cc: cl@linux-foundation.org, mpm@selenic.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2008-07-22 at 20:21 +0300, Adrian Bunk wrote:
> This patch removes the obsolete and no longer used exports of ksize.

Looks good to me.

Christoph, Matt, ACK/NAK?

> Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
> ---
> 
>  mm/slab.c |    1 -
>  mm/slob.c |    1 -
>  mm/slub.c |    1 -
>  3 files changed, 3 deletions(-)
> 
> 1e0e054cd28415dd8d1ed5443085469fcc6633ac 
> diff --git a/mm/slab.c b/mm/slab.c
> index 052e7d6..06bc560 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -4473,4 +4473,3 @@ size_t ksize(const void *objp)
>  
>  	return obj_size(virt_to_cache(objp));
>  }
> -EXPORT_SYMBOL(ksize);
> diff --git a/mm/slob.c b/mm/slob.c
> index a3ad667..0e22be9 100644
> --- a/mm/slob.c
> +++ b/mm/slob.c
> @@ -519,7 +519,6 @@ size_t ksize(const void *block)
>  	else
>  		return sp->page.private;
>  }
> -EXPORT_SYMBOL(ksize);
>  
>  struct kmem_cache {
>  	unsigned int size, align;
> diff --git a/mm/slub.c b/mm/slub.c
> index 6d4a49c..8a2cb94 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2746,7 +2746,6 @@ size_t ksize(const void *object)
>  	 */
>  	return s->size;
>  }
> -EXPORT_SYMBOL(ksize);
>  
>  void kfree(const void *x)
>  {
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
