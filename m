Date: Sun, 4 Aug 2002 15:47:36 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: how not to write a search algorithm
Message-ID: <20020804224736.GI4010@holomorphy.com>
References: <3D4CE74A.A827C9BC@zip.com.au> <Pine.LNX.4.44L.0208041015350.23404-100000@imladris.surriel.com> <3D4D87CE.25198C28@zip.com.au> <20020804203804.GD4010@holomorphy.com> <3D4D9802.D1F208F0@zip.com.au> <20020804220218.GF4010@holomorphy.com> <3D4DAE2C.F45BC9D4@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <3D4DAE2C.F45BC9D4@zip.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, Aug 04, 2002 at 03:43:56PM -0700, Andrew Morton wrote:
> Getting the kernel back to the level of performance and stability
> which it had before the rmap patch has to be the first step.
> 1) 50% increase in system load on fork/exec/exit workloads
> 2) Will oops on pte_chain oom
> 3) pte_highmem is bust
> 4) tripled ZONE_NORMAL consumption
> 5) pte chains go wrong with ntpd
> The first three or four here are fatal to the retention of the
> reverse map, IMO.  Futzing around fixing them is taking time
> and is holding up other work.
> I may have a handle on 1).  Still working it.

(2) only needs the reservation bits from the preceding post if it's
	just dealing with kmem_cache_alloc() returning NULL.
(3) I ground out the half-assed quick & dirty "fish the pfn out of the
	kmap pte" a.k.a. virt_to_fix() and use physaddrs in pte_chains
	thingie and handed it off to others to debug/clean up/push.
(4) is part of the known tradeoff AFAIK, but phillips may have something
	taking it down to only double or so

Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
