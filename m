Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id BD5E56B0031
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 11:27:58 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id y10so1085548pdj.11
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 08:27:58 -0700 (PDT)
Date: Wed, 16 Oct 2013 15:27:54 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 01/15] slab: correct pfmemalloc check
In-Reply-To: <1381913052-23875-2-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <00000141c1e16001-26ccfd98-51ee-4ca6-8ddf-61abd491dea8-000000@email.amazonses.com>
References: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com> <1381913052-23875-2-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>

On Wed, 16 Oct 2013, Joonsoo Kim wrote:

> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -930,7 +930,8 @@ static void *__ac_put_obj(struct kmem_cache *cachep, struct array_cache *ac,
>  {
>  	if (unlikely(pfmemalloc_active)) {
>  		/* Some pfmemalloc slabs exist, check if this is one */
> -		struct page *page = virt_to_head_page(objp);
> +		struct slab *slabp = virt_to_slab(objp);
> +		struct page *page = virt_to_head_page(slabp->s_mem);
>  		if (PageSlabPfmemalloc(page))

I hope the compiler optimizes this code correctly because virt_to_slab
already does one virt_to_head_page()?

Otherwise this looks fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
