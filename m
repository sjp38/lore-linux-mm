From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200004261736.KAA85620@google.engr.sgi.com>
Subject: Re: 2.3.x mem balancing
Date: Wed, 26 Apr 2000 10:36:48 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.21.0004261823290.1687-100000@alpha.random> from "Andrea Arcangeli" at Apr 26, 2000 07:06:57 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Mark_H_Johnson.RTS@raytheon.com, linux-mm@kvack.org, riel@nl.linux.org, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

> 
> On NUMA hardware you have only one zone per node since nobody uses ISA-DMA
> on such machines and you have PCI64 or you can use the PCI-DMA sg for
> PCI32. So on NUMA hardware you are going to have only one zone per node
> (at least this was the setup of the NUMA machine I was playing with). So
> you don't mind at all about classzone/zone. Classzone and zone are the
> same thing in such a setup, they both are the plain ZONE_DMA zone_t.
> Finished. Said that you don't care anymore about the changes of how the
> overlapped zones are handled since you don't have overlapped zones in
> first place.

Andrea, are you talking about the SGI Origin platform, or are you 
using some other NUMA platform? In any case, the SGI platform in fact
does not support ISA-DMA, but unfortunately, I don't think just because
it has PCI mapping registers, you can assume that all memory is DMAable.
For us to be able to consider all memory as dmaable, before each dma
operation starts, we need to have a pci-dma type hook to program the
mapping registers. As far as I know, such a hook is not used on all
drivers (in 2.4 timeframe), so very unfortunately, I think we need
to keep the option open about each node having more than just ZONE_DMA.
Finally, I am not sure how things will work, we are still busy trying
to get the Origin/Linux port going.

FWIW, I think the IBM/Sequent NUMA machines in fact have nodes that 
have only nondmaable memory.

> 
> If you move the NUMA balancing and node selection into the higher layer
> as I was proposing, instead you can do clever things.
>

For an example and a (old) patch for this, look at 

	http://oss.sgi.com/projects/numa/download/numa.gen.42b
	http://oss.sgi.com/projects/numa/download/numa.plat.42b

Kanoj 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
