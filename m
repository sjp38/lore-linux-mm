Date: Sat, 2 Oct 2004 00:08:57 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [RFC] memory defragmentation to satisfy high order allocations
Message-ID: <20041002030857.GB4635@logos.cnet>
References: <20041001182221.GA3191@logos.cnet> <415E12A9.7000507@cyberone.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <415E12A9.7000507@cyberone.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: linux-mm@kvack.org, akpm@osdl.org, arjanv@redhat.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, Oct 02, 2004 at 12:30:01PM +1000, Nick Piggin wrote:
> 
> 
> Marcelo Tosatti wrote:
> 
> >
> >With such a thing in place we can build a mechanism for kswapd 
> >(or a separate kernel thread, if needed) to notice when we are low on 
> >high order pages, and use the coalescing algorithm instead blindly 
> >freeing unique pages from LRU in the hope to build large physically 
> >contiguous memory areas.
> >
> >Comments appreciated.
> >
> >
> 
> Hi Marcelo,
> Seems like a good idea... even with regular dumb kswapd "merging",
> you may easily get stuck for example on systems without swap...
> 
> Anyway, I'd like to get those beat kswapd patches in first. Then
> your mechanism just becomes something like:
> 
>    if order-0 pages are low {
>        try to free memory
>    }
>    else if order-1 or higher pages are low {
>         try to coalesce_memory
>         if that fails, try to free memory
>    }

Hi Nick!

I understand that kswapd is broken, and it needs to go into the page reclaim path 
to free pages when we are out of high order pages (what your 
"beat kswapd" patches do and fix high-order failures by doing so), but 
Linus's argument against it seems to be that "it potentially frees too much pages" 
causing harm to the system. He also says this has been tried in the past, 
with not nice results.

And that is why its has not been merged into mainline.

Is my interpretation correct?

But right, kswapd needs to get fixed to honour high order
pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
