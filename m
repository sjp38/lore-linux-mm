Date: Mon, 3 Mar 2008 09:49:46 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 7/8] slub: Make the order configurable for each slab
 cache
In-Reply-To: <84144f020803010147y489b06fdx479ed0af931de08b@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0803030947300.6010@schroedinger.engr.sgi.com>
References: <20080229044803.482012397@sgi.com>  <20080229044820.044485187@sgi.com>
 <47C7BEA8.4040906@cs.helsinki.fi>  <Pine.LNX.4.64.0802291137140.11084@schroedinger.engr.sgi.com>
 <84144f020803010147y489b06fdx479ed0af931de08b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Mel Gorman <mel@csn.ul.ie>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 1 Mar 2008, Pekka Enberg wrote:

> I am not sure I understand what you mean here. For example, for a
> cache that requires minimum order of 1 to fit any objects (which
> doesn't happen now because of page allocator pass-through), the
> order_store() function can call calculate_sizes() with forced_order

It does happen because the page allocator pass through is only possible 
for kmalloc allocations.

> set to zero after which the cache becomes useless. That deserves a
> code comment, I think.

If the object does not fit into a page then calculate_sizes will violate 
max_order (if necessary) in order to make sure that an allocation is 
possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
