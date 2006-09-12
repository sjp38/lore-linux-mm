Date: Tue, 12 Sep 2006 10:53:56 -0700 (PDT)
From: Christoph Lameter <christoph@engr.sgi.com>
Subject: Re: [PATCH 0/8] Optional ZONE_DMA V1
In-Reply-To: <4506F2B9.5020600@google.com>
Message-ID: <Pine.LNX.4.64.0609121049280.11481@schroedinger.engr.sgi.com>
References: <20060911222729.4849.69497.sendpatchset@schroedinger.engr.sgi.com>
 <20060912133457.GC10689@sgi.com> <Pine.LNX.4.64.0609121032310.11278@schroedinger.engr.sgi.com>
 <4506F2B9.5020600@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Bligh <mbligh@google.com>
Cc: Jack Steiner <steiner@sgi.com>, Linux Memory Management <linux-mm@kvack.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Hellwig <hch@infradead.org>, linux-ia64@vger.kernel.org, Marcelo Tosatti <marcelo@kvack.org>, Arjan van de Ven <arjan@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 12 Sep 2006, Martin Bligh wrote:

> > This is wrong. All memory should be in ZONE_NORMAL since we have no DMA
> > restrictions on Altix.
> 
> PPC64 works the same way, I believe. All memory is DMA'able, therefore
> it all fits in ZONE_DMA.

ZONE_DMA is for broken/limited DMA controllers not for DMA controllers 
that can reach all of memory.
 
> The real problem is that there's no consistent definition of what the
> zones actually mean.

ZONE_DMA 	Special memory area for DMA controllers that can only
			do dma to a restricted memory area.

ZONE_DMA32	Second special memory area for DMA controllers that
		can only do dma to a restricted memory area that
		is different from ZONE_DMA

ZONE_NORMAL	Regular memory

ZONE_HIGHEM	Memory requires being mapped into kernel address space.


> 1. Is it DMA'able (this is stupid, as it doesn't say 'for what device'

That is *not* what ZONE_DMA means. We have always supported DMA to 
regular  memory.

> What is really needed is to pass a physical address limit from the
> caller, together with a flag that says whether the memory needs to be
> mapped into the permanent kernel address space or not. The allocator
> then finds the set of zones that will fulfill this criteria.
> But I suspect this level of change will cause too many people to squeak
> loudly.

Actually we could do this with the proposed change of passing an 
allocation_control struct instead of gfpflags to the allocator functions. 
See the discussion on linux-mm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
