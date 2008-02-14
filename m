Date: Thu, 14 Feb 2008 11:07:26 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/5] slub: Fallback to kmalloc_large for failing higher
 order allocs
In-Reply-To: <84144f020802140056i6706f135s77473534e0b6fc0b@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0802141106390.32613@schroedinger.engr.sgi.com>
References: <20080214040245.915842795@sgi.com>  <20080214040313.616551392@sgi.com>
 <84144f020802140056i6706f135s77473534e0b6fc0b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 14 Feb 2008, Pekka Enberg wrote:

> >  We can use that handoff to avoid failing if a higher order kmalloc slab
> >  allocation cannot be satisfied by the page allocator. If we reach the
> >  out of memory path then simply try a kmalloc_large(). kfree() can
> >  already handle the case of an object that was allocated via the page
> >  allocator and so this will work just fine (apart from object
> >  accounting...).
> 
> Sorry, I didn't follow the discussion close enough. Why are we doing
> this? Is it fixing some real bug I am not aware of?

It addresses Nick's concern about higher order allocations. It allows 
fallback to an order 0 alloc should memory become so fragmented that order 
3 allocs can no longer be satisfied.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
