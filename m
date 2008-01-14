Date: Mon, 14 Jan 2008 11:29:12 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Remove set_migrateflags()
In-Reply-To: <20080114115503.GB32446@csn.ul.ie>
Message-ID: <Pine.LNX.4.64.0801141127330.7891@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0801101841570.23644@schroedinger.engr.sgi.com>
 <20080114115503.GB32446@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 14 Jan 2008, Mel Gorman wrote:

> Grouping the radix nodes into the same TLB entries as the inode and dcaches
> does appear to help performance a small amount on kernbench at least. Applying
> this patch showed a performance difference on elapsed time between -4.45%
> and 0.23% and between -0.36% and 0.28% on total CPU time which appears to
> support that position.

Ahh... Okay.

> > And thus setting __GFP_RECLAIMABLE
> > is a bit strange. We could set SLAB_RECLAIM_ACCOUNT on radix tree slab
> > creation if we want those to be placed in the reclaimable section.
> > Then we are sure that the radix tree slabs are consistently placed in the
> > reclaimable section and then the radix tree slabs will also be accounted as
> > such.
> > 
> 
> What is there right now places the pages appropriately but should they really
> be accounted for as such too? I know that marking them like that will
> cause SLUB to treat them differently and I don't fully understand the
> implications of that.

Marking them makes the slab allocators set GFP_RECLAIMABLE on all page 
allocator allocations for the radix tree and it will also cause the 
statistics to be update correspondingly. No other differences.

> NAK for now. I'm still of the opinion that radix nodes should be marked
> reclaimable because they are often cleaned up at the same time as slabs that
> are really reclaimable.

Do another version of this patch setting SLAB_RECLAIM_ACCOUNT for the 
radix tree?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
