Date: Thu, 8 Nov 2007 20:10:47 +0000
Subject: Re: [patch 02/23] SLUB: Rename NUMA defrag_ratio to remote_node_defrag_ratio
Message-ID: <20071108201047.GE23882@skynet.ie>
References: <20071107011130.382244340@sgi.com> <20071107011226.844437184@sgi.com> <20071108145044.GB2591@skynet.ie> <Pine.LNX.4.64.0711081053250.8954@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0711081053250.8954@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundatin.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (08/11/07 10:56), Christoph Lameter didst pronounce:
> On Thu, 8 Nov 2007, Mel Gorman wrote:
> 
> > On (06/11/07 17:11), Christoph Lameter didst pronounce:
> > > We need the defrag ratio for the non NUMA situation now. The NUMA defrag works
> > > by allocating objects from partial slabs on remote nodes. Rename it to
> > > 
> > > 	remote_node_defrag_ratio
> > > 
> > 
> > I'm not too keen on the defrag name here largely because I cannot tell what
> > it has to do with defragmention or ratios. It's really about working out
> > when it is better to pack objects into a remote slab than reclaim objects
> > from a local slab, right? It's also not clear what it is a ratio of what to
> > what. I thought it might be clock cycles but that isn't very clear either.
> > If we are renaming this can it be something like remote_packing_cost_limit ?
> 
> In a NUMA situation we have a choice between 
> 
> 1. Allocating a page from the local node (which consumes more memory and 
> is advantageous performance wise.
> 
> 2. Not allocating from the local node but see if any other node has 
>    available partially allocated slabs. If we allocate from them then
>    we save memory and reduce the amount of partial slabs on the remote 
>    node. Thus the fragmentation ratio is reduced.
>  

Ok, I get the logic somewhat now, thanks.

> > How about
> > 
> > /*
> >  * When packing objects into slabs, it may become necessary to
> >  * reclaim objects on a local slab or allocate from a remote node.
> >  * The remote_packing_cost_limit is the maximum cost of remote
> >  * accesses that should be paid before it becomes worthwhile to
> >  * reclaim instead
> >  */
> > int remote_packing_cost_limit;
> > 
> > ?
> 
> That is not what this is about. And the functionality has been in SLUB 
> since the beginning.
> 

Yeah, my understanding of SLUB is crap. Sorry for the noise.

-- 
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
