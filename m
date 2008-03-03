Date: Mon, 3 Mar 2008 09:52:55 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 6/8] slub: Adjust order boundaries and minimum objects
 per slab.
In-Reply-To: <Pine.LNX.4.64.0803011148320.19118@sbz-30.cs.Helsinki.FI>
Message-ID: <Pine.LNX.4.64.0803030950010.6010@schroedinger.engr.sgi.com>
References: <20080229044803.482012397@sgi.com> <20080229044819.800974712@sgi.com>
 <47C7BFFA.9010402@cs.helsinki.fi> <Pine.LNX.4.64.0802291139560.11084@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0803011148320.19118@sbz-30.cs.Helsinki.FI>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Cc: Mel Gorman <mel@csn.ul.ie>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 1 Mar 2008, Pekka J Enberg wrote:

> On Fri, 29 Feb 2008, Christoph Lameter wrote:
> > The defaults for slab are also 60 objects per slab. The PAGE_SHIFT says 
> > nothing about the big iron. Our new big irons have a page shift of 12 and 
> > are x86_64.
> 
> Where is that objects per slab limit? I only see calculate_slab_order() 
> trying out bunch of page orders until we hit "acceptable" internal 
> fragmentation. Also keep in mind how badly SLAB compares to SLUB and SLOB 
> in terms of memory efficiency.

slub_min_objects sets that limit.
 
> On Fri, 29 Feb 2008, Christoph Lameter wrote:
> > We could drop the limit if CONFIG_EMBEDDED is set but then this may waste 
> > space. A higher order allows slub to reach a higher object density (in 
> > particular for objects 500-2000 bytes size).
> 
> I am more worried about memory allocated for objects that are not used 
> rather than memory wasted due to bad fitting.

Is there any way to quantify this? This is likely only an effect that 
mostly matters for rarely used slabs (the merging reduces that effect). 
F.e. fitting more inodes or dentries into a single slab increases object 
density.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
