Date: Mon, 11 Feb 2008 15:42:34 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB tbench regression due to page allocator deficiency
In-Reply-To: <20080211234029.GB14980@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0802111540550.28729@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0802091332450.12965@schroedinger.engr.sgi.com>
 <20080209143518.ced71a48.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0802091549120.13328@schroedinger.engr.sgi.com>
 <20080210024517.GA32721@wotan.suse.de> <Pine.LNX.4.64.0802091938160.14089@schroedinger.engr.sgi.com>
 <20080211071828.GD8717@wotan.suse.de> <Pine.LNX.4.64.0802111117440.24379@schroedinger.engr.sgi.com>
 <20080211234029.GB14980@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Pekka J Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Tue, 12 Feb 2008, Nick Piggin wrote:

> It might be possible but would take quite a bit of rework (eg. have a
> look at pcp->count and the horrible anti fragmentation loops).

Yeah. May influece the way we have to handle freelists. Sigh.

> > The fastpath use will be reduced to 50% since every other 
> > allocation will have to go to the page allocator. Maybe we can do that 
> > if the page allocator performance is up to snuff.
> 
> The page allocator has to do quite a lot more than the slab allocator
> does. It has to check watermarks and all the NUMA and zone and anti
> fragmentation stuff, and does quite a lot of branches and stores to
> tes tand set up the struct page.
> 
> So it's never going to be as fast as a simple slab allocation.

Well but does it have to do all of that on *each* allocation? The slab 
allocators also do quite a number of things including NUMA handling but 
all of that is in the slow path and its not done for every single 
allocation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
