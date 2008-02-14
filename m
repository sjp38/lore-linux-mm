Message-ID: <47B49ADD.9010001@cs.helsinki.fi>
Date: Thu, 14 Feb 2008 21:47:41 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [patch 2/5] slub: Fallback to kmalloc_large for failing higher
 order allocs
References: <20080214040245.915842795@sgi.com> <20080214040313.616551392@sgi.com> <20080214140614.GE17641@csn.ul.ie> <Pine.LNX.4.64.0802141108530.32613@schroedinger.engr.sgi.com> <47B49520.4070201@cs.helsinki.fi> <Pine.LNX.4.64.0802141128430.375@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0802141128430.375@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> That would mean reducing the number of objects that can be allocated from 
> the fastpath before we have to go to the page allocator again. Increasing 
> the number of fastpath uses vs slowpath increases the overall performance 
> of a slab.
> 
> If we would use order 0 slab allocs for 4k slabs then every call to 
> slab_alloc would lead to a corresponding call to the page allocator. The 
> regression would not be fixed. We just add slab_alloc overhead to an 
> already bad page allocator call.

Aah, I see. I wonder if we can fix up allocate_slab() to try with a 
smaller order as long as the size allows that? The only problem I can 
see is s->objects but I think we can just move that to be a per-slab 
variable. So sort of variable-order slabs kind of a thing.

What do you think?

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
