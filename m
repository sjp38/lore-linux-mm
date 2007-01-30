Subject: Re: [PATCH 0/8] Create ZONE_MOVABLE to partition memory between
	movable and non-movable pages
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070129160921.7b362c8d.akpm@osdl.org>
References: <20070125234458.28809.5412.sendpatchset@skynet.skynet.ie>
	 <20070126030753.03529e7a.akpm@osdl.org>
	 <Pine.LNX.4.64.0701260751230.6141@schroedinger.engr.sgi.com>
	 <20070126114615.5aa9e213.akpm@osdl.org>
	 <Pine.LNX.4.64.0701261147300.15394@schroedinger.engr.sgi.com>
	 <20070126122747.dde74c97.akpm@osdl.org>
	 <Pine.LNX.4.64.0701291349450.548@schroedinger.engr.sgi.com>
	 <20070129143654.27fcd4a4.akpm@osdl.org>
	 <Pine.LNX.4.64.0701291441260.1102@schroedinger.engr.sgi.com>
	 <20070129225000.GG6602@flint.arm.linux.org.uk>
	 <Pine.LNX.4.64.0701291533500.1169@schroedinger.engr.sgi.com>
	 <20070129160921.7b362c8d.akpm@osdl.org>
Content-Type: text/plain
Date: Tue, 30 Jan 2007 10:53:43 +0100
Message-Id: <1170150823.6189.203.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, Russell King <rmk+lkml@arm.linux.org.uk>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <clameter@engr.sgi.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-01-29 at 16:09 -0800, Andrew Morton wrote:
> On Mon, 29 Jan 2007 15:37:29 -0800 (PST)
> Christoph Lameter <clameter@sgi.com> wrote:
> 
> > With a alloc_pages_range() one would be able to specify upper and lower 
> > boundaries.
> 
> Is there a proposal anywhere regarding how this would be implemented?

I'm guessing this will involve page migration.

Still, would we need to place bounds on non movable pages, or will it be
a best effort? It seems the current zone approach is a best effort too,
although it does try to keep allocations away from the lower zones as
much as possible.

But I guess we could make a single zone allocator prefer high addresses
too.

So then we'd end up with a single zone, and each allocation would give a
range. Try and pick a free page with as high an address as possible in
the given range. If no pages available in the given range try and move
some movable pages out of it.

This does of course involve finding free pages in a given range, and
identifying pages as movable.

And a gazillion trivial but tedious things I've forgotten. Christoph, is
this what you were getting at?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
