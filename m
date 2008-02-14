Message-ID: <47B49520.4070201@cs.helsinki.fi>
Date: Thu, 14 Feb 2008 21:23:12 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [patch 2/5] slub: Fallback to kmalloc_large for failing higher
 order allocs
References: <20080214040245.915842795@sgi.com> <20080214040313.616551392@sgi.com> <20080214140614.GE17641@csn.ul.ie> <Pine.LNX.4.64.0802141108530.32613@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0802141108530.32613@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> The kmalloc slab allocation will use order 3. The allocation for an 
> individual object via the page allocator only uses order 0. The order 0 
> alloc will succeed even if memory is extremely fragmented. Its a safety 
> valve that Nick probably finds important.

Hmm, shouldn't we then fix just fix calculate_order() to not try so hard 
to find better fitting higher orders?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
