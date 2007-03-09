Date: Fri, 9 Mar 2007 14:00:05 +0000 (GMT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [SLUB 0/3] SLUB: The unqueued slab allocator V4
In-Reply-To: <Pine.LNX.4.64.0703081135280.3130@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0703091355520.16052@skynet.skynet.ie>
References: <20070307023502.19658.39217.sendpatchset@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0703081022040.1615@skynet.skynet.ie>
 <Pine.LNX.4.64.0703080836300.27191@schroedinger.engr.sgi.com>
 <20070308174004.GB12958@skynet.ie> <Pine.LNX.4.64.0703081135280.3130@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, Marcelo Tosatti <marcelo@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, mpm@selenic.com, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

On Thu, 8 Mar 2007, Christoph Lameter wrote:

> Note that I am amazed that the kernbench even worked. On small machine

How small? The machines I am testing on aren't "big" but they aren't 
misterable either.

> I
> seem to be getting into trouble with order 1 allocations.

That in itself is pretty incredible. From what I see, allocations up to 3 
generally work unless they are atomic even with the vanilla kernel. That 
said, it could be because slab is holding onto the high order pages for 
itself.

> SLAB seems to be
> able to avoid the situation by keeping higher order pages on a freelist
> and reduce the alloc/frees of higher order pages that the page allocator
> has to deal with. Maybe we need per order queues in the page allocator?
>

I'm not sure what you mean by per-order queues. The buddy allocator 
already has per-order lists.

> There must be something fundamentally wrong in the page allocator if the
> SLAB queues fix this issue. I was able to fix the issue in V5 by forcing
> SLUB to keep a mininum number of objects around regardless of the fit to
> a page order page. Pass through is deadly since the crappy page allocator
> cannot handle it.
>
> Higher order page allocation failures can be avoided by using kmalloc.
> Yuck! Hopefully your patches fix that fundamental problem.
>

One way to find out for sure.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
