Date: Mon, 16 Jul 2001 14:42:19 -0400 (EDT)
From: Dirk Wetter <dirkw@rentec.com>
Subject: Re: [PATCH] Separate global/perzone inactive/free shortage
In-Reply-To: <20010716141915.C28023@redhat.com>
Message-ID: <Pine.LNX.4.33.0107161434110.26302-100000@monster000.rentec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Mike Galbraith <mikeg@wen-online.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 16 Jul 2001, Stephen C. Tweedie wrote:

> Hi,
>
> > On Sat, 14 Jul 2001, Marcelo Tosatti wrote:
>
> > On highmem machines, wouldn't it save a LOT of time to prevent allocation
> > of ZONE_DMA as VM pages?  Or, if we really need to, get those pages into
> > the swapcache instantly?  Crawling through nearly 4 gig of VM looking for
> > 16 MB of ram has got to be very expensive.  Besides, those pages are just
> > too precious to allow some user task to sit on them.
>
> Can't we balance that automatically?
>
> Why not just round-robin between the eligible zones when allocating,
> biasing each zone based on size?  On a 4GB box you'd basically end up
> doing 3 times as many allocations from the highmem zone as the normal
> zone and only very occasionally would you try to dig into the dma
> zone.  But on a 32MB box you would automatically spread allocations
> 50/50 between normal and dma, and on a 20MB box you would be biased in
> favour of allocating dma pages.

how good would be the one-size-fits-all approach?  certainly i would
like to have the best memory performance for my 4GB boxes, so does the
guy with the 20MB or 32MB box.  why not having yet another kernel config
option ;-) ?


cheers,
	~dirkw




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
