Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id B52966B0083
	for <linux-mm@kvack.org>; Tue,  8 May 2012 01:32:21 -0400 (EDT)
Received: by lahi5 with SMTP id i5so368448lah.14
        for <linux-mm@kvack.org>; Mon, 07 May 2012 22:32:19 -0700 (PDT)
Date: Tue, 8 May 2012 08:32:11 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH] slub: fix incorrect return type of get_any_partial()
In-Reply-To: <1327651943-28225-1-git-send-email-js1304@gmail.com>
Message-ID: <alpine.LFD.2.02.1205080831580.4372@tux.localdomain>
References: <1327651943-28225-1-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@linux-foundation.org

On Fri, 27 Jan 2012, Joonsoo Kim wrote:

> Commit 497b66f2ecc97844493e6a147fd5a7e73f73f408 ('slub: return object pointer
> from get_partial() / new_slab().') changed return type of some functions.
> This updates missing part.
> 
> Signed-off-by: Joonsoo Kim <js1304@gmail.com>
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index ffe13fd..18bf13e 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1579,7 +1579,7 @@ static void *get_partial_node(struct kmem_cache *s,
>  /*
>   * Get a page from somewhere. Search in increasing NUMA distances.
>   */
> -static struct page *get_any_partial(struct kmem_cache *s, gfp_t flags,
> +static void *get_any_partial(struct kmem_cache *s, gfp_t flags,
>  		struct kmem_cache_cpu *c)
>  {
>  #ifdef CONFIG_NUMA
> -- 
> 1.7.0.4

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
