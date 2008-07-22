Subject: Re: [RFC PATCH 4/4] kmemtrace: SLOB hooks.
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <1216751808-14428-5-git-send-email-eduard.munteanu@linux360.ro>
References: <1216751808-14428-1-git-send-email-eduard.munteanu@linux360.ro>
	 <1216751808-14428-2-git-send-email-eduard.munteanu@linux360.ro>
	 <1216751808-14428-3-git-send-email-eduard.munteanu@linux360.ro>
	 <1216751808-14428-4-git-send-email-eduard.munteanu@linux360.ro>
	 <1216751808-14428-5-git-send-email-eduard.munteanu@linux360.ro>
Content-Type: text/plain
Date: Tue, 22 Jul 2008 15:53:55 -0500
Message-Id: <1216760035.15519.113.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Cc: penberg@cs.helsinki.fi, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rdunlap@xenotime.net
List-ID: <linux-mm.kvack.org>

On Tue, 2008-07-22 at 21:36 +0300, Eduard - Gabriel Munteanu wrote:
> This adds hooks for the SLOB allocator, to allow tracing with kmemtrace.
> 
> Signed-off-by: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
> ---
>  include/linux/slob_def.h |    9 +++++----
>  mm/slob.c                |   37 +++++++++++++++++++++++++++++++------
>  2 files changed, 36 insertions(+), 10 deletions(-)
> 
> diff --git a/include/linux/slob_def.h b/include/linux/slob_def.h
> index 59a3fa4..0ec00b3 100644
> --- a/include/linux/slob_def.h
> +++ b/include/linux/slob_def.h
> @@ -3,14 +3,15 @@
>  
>  void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
>  
> -static inline void *kmem_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
> +static __always_inline void *kmem_cache_alloc(struct kmem_cache *cachep,
> +					      gfp_t flags)
>  {
>  	return kmem_cache_alloc_node(cachep, flags, -1);
>  }

Why is this needed? builtin_return?

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
