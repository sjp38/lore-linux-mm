Message-ID: <413AAE92.3040208@yahoo.com.au>
Date: Sun, 05 Sep 2004 16:13:38 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/3] account free buddy areas
References: <413AA7B2.4000907@yahoo.com.au> <413AA7F8.3050706@yahoo.com.au>
In-Reply-To: <413AA7F8.3050706@yahoo.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, Linux Memory Management <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> 1/3
> 
> 
> ------------------------------------------------------------------------
> 
> 
> 
> Keep track of the number of free pages of each order in the buddy allocator.
> 
> Signed-off-by: Nick Piggin <nickpiggin@yahoo.com.au>
> 
> 
> ---
> 
>  linux-2.6-npiggin/include/linux/mmzone.h |    1 +
>  linux-2.6-npiggin/mm/page_alloc.c        |   22 ++++++++--------------
>  2 files changed, 9 insertions(+), 14 deletions(-)
> 
> diff -puN mm/page_alloc.c~vm-free-order-pages mm/page_alloc.c
> --- linux-2.6/mm/page_alloc.c~vm-free-order-pages	2004-09-05 14:53:53.000000000 +1000
> +++ linux-2.6-npiggin/mm/page_alloc.c	2004-09-05 14:53:53.000000000 +1000
> @@ -216,6 +216,7 @@ static inline void __free_pages_bulk (st
>  		page_idx &= mask;
>  	}
>  	list_add(&(base + page_idx)->lru, &area->free_list);
> +	area->nr_free++;
>  }
>  

Ahh, yes _that_ is why I got an offset in page_alloc.c

Obviously this function needs an area->nr_free-- in the loop somewhere around
list_del(&buddy1->lru);

I have actually tested the complete patchset with this addition, I just forgot
to update the patch.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
