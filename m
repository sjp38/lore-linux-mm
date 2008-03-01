Date: Sat, 1 Mar 2008 11:58:46 +0200 (EET)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [patch 6/8] slub: Adjust order boundaries and minimum objects
 per slab.
In-Reply-To: <Pine.LNX.4.64.0802291139560.11084@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0803011148320.19118@sbz-30.cs.Helsinki.FI>
References: <20080229044803.482012397@sgi.com> <20080229044819.800974712@sgi.com>
 <47C7BFFA.9010402@cs.helsinki.fi> <Pine.LNX.4.64.0802291139560.11084@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Christoph,

On Fri, 29 Feb 2008, Pekka Enberg wrote:
> > I can see why you want to change the defaults for big iron but why not keep
> > the existing PAGE_SHIFT check which leaves embedded and regular desktop
> > unchanged?
 
On Fri, 29 Feb 2008, Christoph Lameter wrote:
> The defaults for slab are also 60 objects per slab. The PAGE_SHIFT says 
> nothing about the big iron. Our new big irons have a page shift of 12 and 
> are x86_64.

Where is that objects per slab limit? I only see calculate_slab_order() 
trying out bunch of page orders until we hit "acceptable" internal 
fragmentation. Also keep in mind how badly SLAB compares to SLUB and SLOB 
in terms of memory efficiency.

Maybe we can use total amount of memory as some sort of heuristic to 
determine the defaults? That way boxes with lots of memory get to use 
larger orders for better performance whereas smaller boxes are more 
memory efficient.

On Fri, 29 Feb 2008, Christoph Lameter wrote:
> We could drop the limit if CONFIG_EMBEDDED is set but then this may waste 
> space. A higher order allows slub to reach a higher object density (in 
> particular for objects 500-2000 bytes size).

I am more worried about memory allocated for objects that are not used 
rather than memory wasted due to bad fitting.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
