Subject: Re: [PATCH] Separate global/perzone inactive/free shortage
Message-ID: <OF11D0664E.20E72543-ON85256A8B.004B248D@pok.ibm.com>
From: "Bulent Abali" <abali@us.ibm.com>
Date: Mon, 16 Jul 2001 09:56:58 -0400
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Mike Galbraith <mikeg@wen-online.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, Rik van Riel <riel@conectiva.com.br>, Dirk Wetter <dirkw@rentec.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



>> On Sat, 14 Jul 2001, Marcelo Tosatti wrote:
>
>> On highmem machines, wouldn't it save a LOT of time to prevent
allocation
>> of ZONE_DMA as VM pages?  Or, if we really need to, get those pages into
>> the swapcache instantly?  Crawling through nearly 4 gig of VM looking
for
>> 16 MB of ram has got to be very expensive.  Besides, those pages are
just
>> too precious to allow some user task to sit on them.
>
>Can't we balance that automatically?
>
>Why not just round-robin between the eligible zones when allocating,
>biasing each zone based on size?  On a 4GB box you'd basically end up
>doing 3 times as many allocations from the highmem zone as the normal
>zone and only very occasionally would you try to dig into the dma
>zone.
>Cheers,
> Stephen

If I understood page_alloc.c:build_zonelists() correctly
ZONE_HIGHMEM includes ZONE_NORMAL which includes ZONE_DMA.
Memory allocators (other than ZONE_DMA) will dip in to the dma zone
only when there are no highmem and/or normal zone pages available.
So, the current method is more conservative (better) than round-robin
it seems to me.

I think Marcello is proposing to make ZONE_DMA exclusive in large
memory machines, which might make it better for allocators
needing ZONE_DMA pages...
Bulent


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
