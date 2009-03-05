Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 05C356B00AB
	for <linux-mm@kvack.org>; Wed,  4 Mar 2009 21:38:02 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN; charset=US-ASCII
Received: from xanadu.home ([66.131.194.97]) by VL-MH-MR002.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3 2007; 32bit))
 with ESMTP id <0KG0008SKHYVG760@VL-MH-MR002.ip.videotron.ca> for
 linux-mm@kvack.org; Wed, 04 Mar 2009 21:37:45 -0500 (EST)
Date: Wed, 04 Mar 2009 21:37:43 -0500 (EST)
From: Nicolas Pitre <nico@cam.org>
Subject: Re: [RFC] atomic highmem kmap page pinning
In-reply-to: <20090305080717.f7832c63.minchan.kim@barrios-desktop>
Message-id: <alpine.LFD.2.00.0903042129140.5511@xanadu.home>
References: <alpine.LFD.2.00.0903040014140.5511@xanadu.home>
 <20090304171429.c013013c.minchan.kim@barrios-desktop>
 <alpine.LFD.2.00.0903041101170.5511@xanadu.home>
 <20090305080717.f7832c63.minchan.kim@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Russell King - ARM Linux <linux@arm.linux.org.uk>
List-ID: <linux-mm.kvack.org>

On Thu, 5 Mar 2009, Minchan Kim wrote:

> I thought kmap and dma_map_page usage was following.
> 
> kmap(page);
> ...
> dma_map_page(...)
>   invalidate_cache_line
> 
> kunmap(page);
> 
> In this case, how do pkmap_count value for the page passed to dma_map_page become 1 ?
> The caller have to make sure to complete dma_map_page before kunmap.


The caller doesn't have to call kmap() on pages it intends to use for 
DMA.

> Do I miss something ?

See above.

> > > As far as I understand, To make irq_disable to prevent this problem is 
> > > rather big cost.
> > 
> > How big?  Could you please elaborate on the significance of this cost?
> 
> I don't have a number. It depends on you for submitting this patch. 

My assertion is that the cost is negligible.  This is why I'm asking you 
why you think this is a big cost.


Nicolas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
