Date: Mon, 16 Jul 2001 14:19:15 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [PATCH] Separate global/perzone inactive/free shortage
Message-ID: <20010716141915.C28023@redhat.com>
References: <Pine.LNX.4.21.0107140204110.4153-100000@freak.distro.conectiva> <Pine.LNX.4.33.0107141023440.283-100000@mikeg.weiden.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.33.0107141023440.283-100000@mikeg.weiden.de>; from mikeg@wen-online.de on Sat, Jul 14, 2001 at 10:34:39AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <mikeg@wen-online.de>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, Rik van Riel <riel@conectiva.com.br>, Dirk Wetter <dirkw@rentec.com>, "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

> On Sat, 14 Jul 2001, Marcelo Tosatti wrote:
 
> On highmem machines, wouldn't it save a LOT of time to prevent allocation
> of ZONE_DMA as VM pages?  Or, if we really need to, get those pages into
> the swapcache instantly?  Crawling through nearly 4 gig of VM looking for
> 16 MB of ram has got to be very expensive.  Besides, those pages are just
> too precious to allow some user task to sit on them.

Can't we balance that automatically?

Why not just round-robin between the eligible zones when allocating,
biasing each zone based on size?  On a 4GB box you'd basically end up
doing 3 times as many allocations from the highmem zone as the normal
zone and only very occasionally would you try to dig into the dma
zone.  But on a 32MB box you would automatically spread allocations
50/50 between normal and dma, and on a 20MB box you would be biased in
favour of allocating dma pages.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
