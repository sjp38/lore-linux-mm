Subject: Re: [RESEND PATCH] kmemtrace: SLAB hooks.
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <1216057334-27239-1-git-send-email-eduard.munteanu@linux360.ro>
References: <487B7F99.4060004@linux-foundation.org>
	 <1216057334-27239-1-git-send-email-eduard.munteanu@linux360.ro>
Date: Mon, 14 Jul 2008 21:19:48 +0300
Message-Id: <1216059588.6762.20.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Cc: cl@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Eduard-Gabriel,

On Mon, 2008-07-14 at 20:42 +0300, Eduard - Gabriel Munteanu wrote:
> This adds hooks for the SLAB allocator, to allow tracing with
> kmemtrace.
> 
> Signed-off-by: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
> @@ -28,8 +29,20 @@ extern struct cache_sizes malloc_sizes[];
>  void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
>  void *__kmalloc(size_t size, gfp_t flags);
>  
> +#ifdef CONFIG_KMEMTRACE
> +extern void *__kmem_cache_alloc(struct kmem_cache *cachep, gfp_t flags);
> +#else
> +static inline void *__kmem_cache_alloc(struct kmem_cache *cachep,
> +				       gfp_t flags)
> +{
> +	return kmem_cache_alloc(cachep, flags);
> +}
> +#endif
> +

I'm okay with this approach but then you need to do
s/__kmem_cache_alloc/kmem_cache_alloc_trace/ or similar. In the kernel,
it's always the *upper* level function that doesn't have the
underscores.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
