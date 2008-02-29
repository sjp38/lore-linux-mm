Date: Fri, 29 Feb 2008 11:37:35 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 7/8] slub: Make the order configurable for each slab
 cache
In-Reply-To: <47C7BEA8.4040906@cs.helsinki.fi>
Message-ID: <Pine.LNX.4.64.0802291137140.11084@schroedinger.engr.sgi.com>
References: <20080229044803.482012397@sgi.com> <20080229044820.044485187@sgi.com>
 <47C7BEA8.4040906@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Mel Gorman <mel@csn.ul.ie>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 29 Feb 2008, Pekka Enberg wrote:

> I think we either want to check that the order is big enough to hold one
> object for the given cache or add a comment explaining why it can never happen
> (page allocator pass-through).

Calculate_sizes() will violate max_order if the object does not fit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
