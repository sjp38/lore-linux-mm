Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 7A10F6B0032
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 13:51:59 -0400 (EDT)
Date: Thu, 22 Aug 2013 17:51:58 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 04/16] slab: remove nodeid in struct slab
In-Reply-To: <1377161065-30552-5-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <00000140a7277e81-d259fd75-0dcb-4bef-9e32-d615800201a6-000000@email.amazonses.com>
References: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com> <1377161065-30552-5-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 22 Aug 2013, Joonsoo Kim wrote:

> @@ -1099,8 +1098,7 @@ static void drain_alien_cache(struct kmem_cache *cachep,
>
>  static inline int cache_free_alien(struct kmem_cache *cachep, void *objp)
>  {
> -	struct slab *slabp = virt_to_slab(objp);
> -	int nodeid = slabp->nodeid;
> +	int nodeid = page_to_nid(virt_to_page(objp));
>  	struct kmem_cache_node *n;
>  	struct array_cache *alien = NULL;
>  	int node;

virt_to_page is a relatively expensive operation. How does this affect
performance?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
