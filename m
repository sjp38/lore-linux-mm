Message-ID: <3D73D666.9F3A8B0B@zip.com.au>
Date: Mon, 02 Sep 2002 14:21:42 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: About the free page pool
References: <3D73CB28.D2F7C7B0@zip.com.au> <Pine.LNX.4.44L.0209021747250.1857-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Scott Kaplan <sfkaplan@cs.amherst.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Mon, 2 Sep 2002, Andrew Morton wrote:
> 
> > > How important is it to maintain a list of free pages?  That is, how
> > > critical is it that there be some pool of free pages from which the only
> > > bookkeeping required is the removal of that page from the free list.
> >
> > There are several reasons, all messy.
> 
> [snip]
> 
> > It's feasible.  It'd take some work.  Probably it would best be implemented
> > via a third list.  That list would be protected by an IRQ-safe lock,
> 
> I don't think we need to bother with the IRQ-safe part.
> 
> It's much simpler if we just do:
> 
> 1) have a normal free list, but have it smaller ...
>    say, between zone->pages_min and zone->pages_low
> 
> 2) if the free pages drop below the low water mark,
>    have either a normal allocator or a kernel thread
>    refill it to the high water mark, from the clean
>    pages list
> 
> 3) have the free+clean target set to something higher,
>    say zone->pages_high ... we could even tune this
>    automatically, if we run out of free+clean pages too
>    often kswapd should probably try to keep more pages
>    clean
> 
> What do you think, would this work?

Well, I'm at a bit of a loss to understand what the objective
of all this is.  Is it so that we can effectively increase the
cache size, by not "wasting" all that free memory?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
