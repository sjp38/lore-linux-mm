Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 4086B6B0083
	for <linux-mm@kvack.org>; Fri, 18 May 2012 05:32:01 -0400 (EDT)
Received: by lahi5 with SMTP id i5so3220304lah.14
        for <linux-mm@kvack.org>; Fri, 18 May 2012 02:31:59 -0700 (PDT)
Date: Fri, 18 May 2012 12:31:49 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH 3/4] slub: use __SetPageSlab function to set PG_slab
 flag
In-Reply-To: <1337269668-4619-4-git-send-email-js1304@gmail.com>
Message-ID: <alpine.LFD.2.02.1205181231440.3899@tux.localdomain>
References: <1337269668-4619-1-git-send-email-js1304@gmail.com> <1337269668-4619-4-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 18 May 2012, Joonsoo Kim wrote:

> To set page-flag, using SetPageXXXX() and __SetPageXXXX() is more
> understandable and maintainable. So change it.
> 
> Signed-off-by: Joonsoo Kim <js1304@gmail.com>
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index c38efce..69342fd 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1369,7 +1369,7 @@ static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
>  
>  	inc_slabs_node(s, page_to_nid(page), page->objects);
>  	page->slab = s;
> -	page->flags |= 1 << PG_slab;
> +	__SetPageSlab(page);
>  
>  	start = page_address(page);

Applied

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
