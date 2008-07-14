Subject: Re: [PATCH] kmemtrace: SLAB hooks.
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <1215889471-5734-1-git-send-email-eduard.munteanu@linux360.ro>
References: <84144f020807110149v4806404fjdb9c3e4af3cfdb70@mail.gmail.com>
	 <1215889471-5734-1-git-send-email-eduard.munteanu@linux360.ro>
Content-Type: text/plain; charset=UTF-8
Date: Mon, 14 Jul 2008 19:28:13 +0300
Message-Id: <1216052893.6762.3.camel@penberg-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Hi Eduard-Gabriel,

On Sat, 2008-07-12 at 22:04 +0300, Eduard - Gabriel Munteanu wrote:
> This adds hooks for the SLAB allocator, to allow tracing with kmemtrace.
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
> +	return __kmem_cache_alloc(cachep, flags);

Looks as if the function calls itself i>>?recursively?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
