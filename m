Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 377786B0201
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 16:31:27 -0400 (EDT)
Message-ID: <4C757D5E.1040307@oracle.com>
Date: Wed, 25 Aug 2010 13:30:22 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
MIME-Version: 1.0
Subject: Re: linux-next: Tree for August 25 (mm/slub)
References: <20100825132057.c8416bef.sfr@canb.auug.org.au> <20100825094559.bc652afe.randy.dunlap@oracle.com> <alpine.DEB.2.00.1008251405590.22117@router.home>
In-Reply-To: <alpine.DEB.2.00.1008251405590.22117@router.home>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm@kvack.org, linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On 08/25/10 12:07, Christoph Lameter wrote:
> On Wed, 25 Aug 2010, Randy Dunlap wrote:
> 
>> mm/slub.c:1732: error: implicit declaration of function 'slab_pre_alloc_hook'
>> mm/slub.c:1751: error: implicit declaration of function 'slab_post_alloc_hook'
>> mm/slub.c:1881: error: implicit declaration of function 'slab_free_hook'
>> mm/slub.c:1886: error: implicit declaration of function 'slab_free_hook_irq'
> 
> Empty functions are missing if the runtime debuggability option is
> compiled
> out.
> 
> 
> Subject: slub: Add dummy functions for the !SLUB_DEBUG case
> 
> Provide the fall back functions to empty hooks if SLUB_DEBUG is not set.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Acked-by: Randy Dunlap <randy.dunlap@oracle.com>

Thanks.

> ---
>  mm/slub.c |   12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2010-08-25 14:02:43.000000000 -0500
> +++ linux-2.6/mm/slub.c	2010-08-25 14:04:23.000000000 -0500
> @@ -1098,6 +1098,18 @@ static inline void inc_slabs_node(struct
>  							int objects) {}
>  static inline void dec_slabs_node(struct kmem_cache *s, int node,
>  							int objects) {}
> +
> +static inline int slab_pre_alloc_hook(struct kmem_cache *s, gfp_t flags)
> +							{ return 0; }
> +
> +static inline void slab_post_alloc_hook(struct kmem_cache *s, gfp_t flags,
> +		void *object) {}
> +
> +static inline void slab_free_hook(struct kmem_cache *s, void *x) {}
> +
> +static inline void slab_free_hook_irq(struct kmem_cache *s,
> +		void *object) {}
> +
>  #endif
> 
>  /*


-- 
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
