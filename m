Message-ID: <417F589E.3050003@yahoo.com.au>
Date: Wed, 27 Oct 2004 18:13:18 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] teach kswapd about higher order areas
References: <417F5584.2070400@yahoo.com.au> <417F55B9.7090306@yahoo.com.au> <417F5604.3000908@yahoo.com.au> <417F5623.4040005@yahoo.com.au>
In-Reply-To: <417F5623.4040005@yahoo.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> 3/3
> 
> 
> ------------------------------------------------------------------------
> 
> 
> 
> Teach kswapd to free memory on behalf of higher order allocators. This could
> be important for higher order atomic allocations because they otherwise have
> no means to free the memory themselves.
> 
> Signed-off-by: Nick Piggin <nickpiggin@yahoo.com.au>
> 
> 
> ---
> 
>  linux-2.6-npiggin/include/linux/mmzone.h |    5 +--
>  linux-2.6-npiggin/mm/page_alloc.c        |    3 +
>  linux-2.6-npiggin/mm/vmscan.c            |   48 ++++++++++++++++++-------------
>  3 files changed, 34 insertions(+), 22 deletions(-)
> 
> diff -puN mm/vmscan.c~vm-kswapd-heed-order-watermarks mm/vmscan.c
> --- linux-2.6/mm/vmscan.c~vm-kswapd-heed-order-watermarks	2004-10-27 17:57:28.000000000 +1000
> +++ linux-2.6-npiggin/mm/vmscan.c	2004-10-27 17:57:28.000000000 +1000
> @@ -851,9 +851,6 @@ shrink_caches(struct zone **zones, struc
>  	for (i = 0; zones[i] != NULL; i++) {
>  		struct zone *zone = zones[i];
>  
> -		if (zone->present_pages == 0)
> -			continue;
> -

Sorry, slight mismerge - this gets rid of thse new fangled checks
(which it shouldn't). Other than that it looks ok though.

Let me know if you want a fixed up patch.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
