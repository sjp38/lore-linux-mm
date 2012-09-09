Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 8D70F6B0044
	for <linux-mm@kvack.org>; Sun,  9 Sep 2012 02:21:11 -0400 (EDT)
References: <alpine.LSU.2.00.1209082032100.2213@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1209082032100.2213@eggly.anvils>
Mime-Version: 1.0 (1.0)
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii
Message-Id: <00000139a9b058c0-db3f25c9-0800-4a8e-b6d7-32e299e8c897-000000@email.amazonses.com>
From: Christoph <cl@linux.com>
Subject: Re: [PATCH mmotm] slub: zero page to fix boot crashes
Date: Sun, 9 Sep 2012 06:21:10 +0000
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, Glauber Costa <glommer@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, "mm-commits@vger.kernel.org" <mm-commits@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>

Yes that fix was already sent by me.



On Sep 8, 2012, at 22:42, Hugh Dickins <hughd@google.com> wrote:

> Latest mmotm rarely boots if SLUB is enabled: earlyprintk=vga shows
> it crashing with various backtraces.  The memset has now been removed
> from kmem_cache_open(), so kmem_cache_init() needs to zero its page.
> This gets SLUB booting reliably again.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
> 
> mm/slub.c |    2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- mmotm/mm/slub.c    2012-09-07 12:39:38.136019730 -0700
> +++ fixed/mm/slub.c    2012-09-08 19:37:38.608993123 -0700
> @@ -3712,7 +3712,7 @@ void __init kmem_cache_init(void)
>    /* Allocate two kmem_caches from the page allocator */
>    kmalloc_size = ALIGN(kmem_size, cache_line_size());
>    order = get_order(2 * kmalloc_size);
> -    kmem_cache = (void *)__get_free_pages(GFP_NOWAIT, order);
> +    kmem_cache = (void *)__get_free_pages(GFP_NOWAIT | __GFP_ZERO, order);
> 
>    /*
>     * Must first have the slab cache available for the allocations of the

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
