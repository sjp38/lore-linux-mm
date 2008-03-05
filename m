Date: Tue, 4 Mar 2008 16:04:41 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 0/8] slub: Fallback to order 0 and variable order slab
 support
In-Reply-To: <20080304190126.GM10223@waste.org>
Message-ID: <Pine.LNX.4.64.0803041601520.21992@schroedinger.engr.sgi.com>
References: <20080229044803.482012397@sgi.com> <20080304122008.GB19606@csn.ul.ie>
 <20080304190126.GM10223@waste.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 4 Mar 2008, Matt Mackall wrote:

> Thanks for looking at this, Mel. Could you try testing.. umm...
> slub_max_order=1? That's never going to get us more than one more
> object per slab, but if we can go from 1 per page to 1.5 per page, it
> might be worth it. Task structs are roughly in that size domain.

Note that you would also have decrease the number of objects per slab.

good combinations:

slub_max_order=3 slub_min_objects=8

(Was the config used for mm with the earlier version of higher order alloc w/o fallback)


slub_max_order=1 slub_min_objects=4

(upstream config w/o fallback)


The default in mm is right now

slub_max_order=4 slub_min_objects=60

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
