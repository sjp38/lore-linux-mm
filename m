Message-ID: <413AA915.9060407@yahoo.com.au>
Date: Sun, 05 Sep 2004 15:50:13 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 2/3] alloc-order watermarks
References: <413AA7B2.4000907@yahoo.com.au> <413AA7F8.3050706@yahoo.com.au> <413AA841.1040003@yahoo.com.au>
In-Reply-To: <413AA841.1040003@yahoo.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
Cc: Linux Memory Management <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> 2/3
> 
> 
> ------------------------------------------------------------------------
> 
> 
> 
> Move the watermark checking code into a single function. Extend it to account
> for the order of the allocation and the number of free pages that could satisfy
> such a request.
> 
> Signed-off-by: Nick Piggin <nickpiggin@yahoo.com.au>
> 
> 
> ---
> 
>  linux-2.6-npiggin/include/linux/mmzone.h |    2 +
>  linux-2.6-npiggin/mm/page_alloc.c        |   57 ++++++++++++++++++++-----------
>  2 files changed, 40 insertions(+), 19 deletions(-)
> 
> diff -puN mm/page_alloc.c~vm-alloc-order-watermarks mm/page_alloc.c
> --- linux-2.6/mm/page_alloc.c~vm-alloc-order-watermarks	2004-09-05 14:55:46.000000000 +1000
> +++ linux-2.6-npiggin/mm/page_alloc.c	2004-09-05 15:10:07.000000000 +1000
> @@ -676,6 +676,36 @@ buffered_rmqueue(struct zone *zone, int 
>  }
>  
>  /*
> + * Return the number of pages available for order 'order' allocations.
> + */

Sorry, stale comment. It actually returns 1 if free pages are above the
watermark, 0 otherwise.

> +int zone_watermark_ok(struct zone *z, int order, unsigned long mark,
> +		int alloc_type, int can_try_harder, int gfp_high)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
