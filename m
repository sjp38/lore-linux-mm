Message-ID: <47B3626C.2080604@cs.helsinki.fi>
Date: Wed, 13 Feb 2008 23:34:36 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [2.6 patch] make slub.c:slab_address() static
References: <20080213213032.GH3383@cs181133002.pp.htv.fi>
In-Reply-To: <20080213213032.GH3383@cs181133002.pp.htv.fi>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adrian Bunk <bunk@kernel.org>
Cc: clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Adrian Bunk wrote:
> slab_address() can become static.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
> ---
> fdd710f00d8bed8413c160685bc5229ec15b4d9f diff --git a/mm/slub.c b/mm/slub.c
> index e2989ae..af83daf 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -308,7 +308,7 @@ static inline int is_end(void *addr)
>  	return (unsigned long)addr & PAGE_MAPPING_ANON;
>  }
>  
> -void *slab_address(struct page *page)
> +static void *slab_address(struct page *page)
>  {
>  	return page->end - PAGE_MAPPING_ANON;
>  }
> 

Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
