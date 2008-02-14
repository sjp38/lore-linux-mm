Date: Thu, 14 Feb 2008 11:10:06 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/5] slub: Fallback to kmalloc_large for failing higher
 order allocs
In-Reply-To: <20080214140614.GE17641@csn.ul.ie>
Message-ID: <Pine.LNX.4.64.0802141108530.32613@schroedinger.engr.sgi.com>
References: <20080214040245.915842795@sgi.com> <20080214040313.616551392@sgi.com>
 <20080214140614.GE17641@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 14 Feb 2008, Mel Gorman wrote:

> comments with a grain of salt. But, if a kmalloc slab allocation fails and
> it ultimately uses the page allocator, I do not see how calling the page
> allocator directly makes a difference.

The kmalloc slab allocation will use order 3. The allocation for an 
individual object via the page allocator only uses order 0. The order 0 
alloc will succeed even if memory is extremely fragmented. Its a safety 
valve that Nick probably finds important.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
