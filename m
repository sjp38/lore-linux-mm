Message-ID: <415E12A9.7000507@cyberone.com.au>
Date: Sat, 02 Oct 2004 12:30:01 +1000
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] memory defragmentation to satisfy high order allocations
References: <20041001182221.GA3191@logos.cnet>
In-Reply-To: <20041001182221.GA3191@logos.cnet>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: linux-mm@kvack.org, akpm@osdl.org, arjanv@redhat.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


Marcelo Tosatti wrote:

>
>With such a thing in place we can build a mechanism for kswapd 
>(or a separate kernel thread, if needed) to notice when we are low on 
>high order pages, and use the coalescing algorithm instead blindly 
>freeing unique pages from LRU in the hope to build large physically 
>contiguous memory areas.
>
>Comments appreciated.
>
>

Hi Marcelo,
Seems like a good idea... even with regular dumb kswapd "merging",
you may easily get stuck for example on systems without swap...

Anyway, I'd like to get those beat kswapd patches in first. Then
your mechanism just becomes something like:

    if order-0 pages are low {
        try to free memory
    }
    else if order-1 or higher pages are low {
         try to coalesce_memory
         if that fails, try to free memory
    }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
