Date: Mon, 3 Mar 2008 14:36:52 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 6/8] slub: Adjust order boundaries and minimum objects
 per slab.
In-Reply-To: <20080303213412.GD10223@waste.org>
Message-ID: <Pine.LNX.4.64.0803031434510.5149@schroedinger.engr.sgi.com>
References: <20080229044803.482012397@sgi.com> <20080229044819.800974712@sgi.com>
 <47C7BFFA.9010402@cs.helsinki.fi> <Pine.LNX.4.64.0802291139560.11084@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0803011148320.19118@sbz-30.cs.Helsinki.FI>
 <Pine.LNX.4.64.0803030950010.6010@schroedinger.engr.sgi.com>
 <20080303213412.GD10223@waste.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Pekka J Enberg <penberg@cs.helsinki.fi>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 3 Mar 2008, Matt Mackall wrote:

> On the other hand, a single object can now pin 64k in memory rather
> than 4k. So when we collapse some cache under memory pressure, we're
> not likely to free as much.

Right.

> I know you've put a lot of effort into dealing with the dcache and
> icache instances of this, but this could very well offset most of that.

I developed and tested the icache and dcache stuff with order 3 allocs 
(when mm still had the initial higher order page use without fallbacks).

> Also, we might consider only allocating an order-1 slab if we've
> filled an order-0, and so on. When we hit pressure, we kick our
> order counter back to 0.

Hmmmm... Interesting idea. Is doable now since the size of the individual 
slab is no longer fixed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
