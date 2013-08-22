Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id D39D06B0032
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 14:00:57 -0400 (EDT)
Date: Thu, 22 Aug 2013 18:00:56 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 09/16] slab: use __GFP_COMP flag for allocating slab
 pages
In-Reply-To: <1377161065-30552-10-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <00000140a72fb556-3269e81c-8829-4c26-a57f-c1bb7e40977b-000000@email.amazonses.com>
References: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com> <1377161065-30552-10-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 22 Aug 2013, Joonsoo Kim wrote:

> If we use 'struct page' of first page as 'struct slab', there is no
> advantage not to use __GFP_COMP. So use __GFP_COMP flag for all the cases.

Ok that brings it in line with SLUB and SLOB.

> @@ -2717,17 +2701,8 @@ static void slab_put_obj(struct kmem_cache *cachep, struct slab *slabp,
>  static void slab_map_pages(struct kmem_cache *cache, struct slab *slab,
>  			   struct page *page)
>  {
> -	int nr_pages;
> -
> -	nr_pages = 1;
> -	if (likely(!PageCompound(page)))
> -		nr_pages <<= cache->gfporder;
> -
> -	do {
> -		page->slab_cache = cache;
> -		page->slab_page = slab;
> -		page++;
> -	} while (--nr_pages);
> +	page->slab_cache = cache;
> +	page->slab_page = slab;
>  }

And saves some processing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
