Date: Sat, 16 Feb 2008 14:09:54 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 7/8] slub: Adjust order boundaries and minimum objects
 per slab.
In-Reply-To: <1203193259.6324.12.camel@cinder.waste.org>
Message-ID: <Pine.LNX.4.64.0802161408440.26968@schroedinger.engr.sgi.com>
References: <20080215230811.635628223@sgi.com>  <20080215230854.643455255@sgi.com>
 <47B6A928.7000309@cs.helsinki.fi>  <Pine.LNX.4.64.0802161059420.25573@schroedinger.engr.sgi.com>
 <1203193259.6324.12.camel@cinder.waste.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 16 Feb 2008, Matt Mackall wrote:

> Why are 4k objects even going through SLUB?

Because the page allocator is slower by factor 8.

> What happens if we have 8k free and try to allocate one 4k object
> through SLUB?

We allocate one page and return it.
 
> Using an order greater than 0 is generally frowned upon. Kernels can and
> do get into situations where they can't find two contiguous pages, which
> is why we've gone to so much trouble on x86 to fit into a single page of
> stack.

All allocations can fall back to order 0 allocs with the patchset we are 
discussing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
