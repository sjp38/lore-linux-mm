Date: Wed, 10 Nov 2004 14:23:11 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH 2/3] higher order watermarks
Message-ID: <20041110162311.GA12696@logos.cnet>
References: <417F5584.2070400@yahoo.com.au> <417F55B9.7090306@yahoo.com.au> <417F5604.3000908@yahoo.com.au> <20041104085745.GA7186@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041104085745.GA7186@logos.cnet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 04, 2004 at 06:57:45AM -0200, Marcelo Tosatti wrote:

> The original code didnt had the can_try_harder/gfp_high decrease 
> which is now on zone_watermark_ok. 
> 
> Means that those allocations will now be successful earlier, instead
> of going to the next zonelist iteration. kswapd will not be awake
> when it used to be.
> 
> Hopefully it doesnt matter that much. You did this by intention?

Another thing Nick is that now balance_pgdat uses zone_watermark_ok, 
and that sums "z->protection[alloc_type]".

        if (free_pages <= min + z->protection[alloc_type])
                return 0;

Since balance_pgdat calls with alloc_type=0, the code will sum ZONE_DMA
(alloc_type = 0) protection, and it should not.

kswapd should be working on the bare min/low/high watermarks AFAICT, 
without the protections.

Comments?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
