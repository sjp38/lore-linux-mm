Date: Fri, 21 Nov 2008 10:46:02 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/7] mm: remove GFP_HIGHUSER_PAGECACHE
Message-ID: <20081121104601.GA27744@csn.ul.ie>
References: <Pine.LNX.4.64.0811200108230.19216@blonde.site> <Pine.LNX.4.64.0811200115050.19216@blonde.site> <20081120164304.GA9777@csn.ul.ie> <Pine.LNX.4.64.0811201821170.31078@blonde.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0811201821170.31078@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 20, 2008 at 06:58:49PM +0000, Hugh Dickins wrote:
> On Thu, 20 Nov 2008, Mel Gorman wrote:
> > On Thu, Nov 20, 2008 at 01:16:16AM +0000, Hugh Dickins wrote:
> > > GFP_HIGHUSER_PAGECACHE is just an alias for GFP_HIGHUSER_MOVABLE,
> > > making that harder to track down: remove it, and its out-of-work
> > > brothers GFP_NOFS_PAGECACHE and GFP_USER_PAGECACHE.
> > 
> > The use of GFP_HIGHUSER_PAGECACHE instead of GFP_HIGHUSER_MOVABLE was a
> > deliberate decision at the time. I do not have an exact patch to point
> 
> I realize it didn't happen by accident!
> 
> > you at but the intention behind GFP_HIGHUSER_PAGECACHE was that it be
> > self-documenting. i.e. one could easily find what GFP placement decisions
> > have been made for page-cache allocations.
> 
> I see it as self-obscuring, not self-documenting: of course pagecache
> pages will normally be allocated with the GFP mask for pagecache pages,
> but what is that?  Ah, it's GFP_HIGHUSER_MOVABLE.
> 
> Please let's not go down the road, I mean, let's retrace our steps
> up the road, of assigning a unique GFP name for every use of pages.
> 

Hmm.... Ok. Whatever sense it made when there was NOFS and USER
variants, it doesn't help as much when there is only one variant now and
used in two fairly-obvious callsites.

> > So, I'm happy with GFP_NOFS_PAGECACHE and GFP_USER_PAGECACHE going away and
> > it makes perfect sense. GFP_HIGHUSER_PAGECACHE I'm not as keen on backing
> > out. I like it's self-documenting aspect but aliases sometimes make peoples
> > teeth itch.
> 
> (No, what made my teeth itch was "is this safe?" in memory.c ;)
> 
> > If it's really hated, then could a comment to the affect of
> > "Marked movable for a page cache allocation" be placed near the call-sites
> > instead?
> 
> I'd prefer not.
> 
> The only places where GFP_HIGHUSER_PAGECACHE appeared
> were the mapping_set_gfp_mask when initializing an inode, and
> hotremove_migrate_alloc().  The latter allocating for anonymous
> pages also, like most places where GFP_HIGHUSER_MOVABLE is specified.
> 
> But I'd better not complain that it's not obvious to me which
> should be marked with your comment and which not: you'll point to
> that as evidence that we're missing out on the self-documentation!
> 
> Perhaps the problem is that nobody else has been following your lead.
> 

You've convinced me. Thanks.

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
