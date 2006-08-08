Date: Tue, 8 Aug 2006 10:01:14 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [1/3] Add __GFP_THISNODE to avoid fallback to other nodes and
 ignore cpuset/memory policy restrictions.
In-Reply-To: <44D8C24F.8010808@shadowen.org>
Message-ID: <Pine.LNX.4.64.0608080959210.27866@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0608080930380.27620@schroedinger.engr.sgi.com>
 <44D8C24F.8010808@shadowen.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: akpm@osdl.org, linux-mm@kvack.org, pj@sgi.com, jes@sgi.com
List-ID: <linux-mm.kvack.org>

On Tue, 8 Aug 2006, Andy Whitcroft wrote:

> > +		if (unlikely((gfp_mask & __GFP_THISNODE) &&
> > +			(*z)->zone_pgdat != zonelist->zones[0]->zone_pgdat))
> > +				break;
> >  		if ((alloc_flags & ALLOC_CPUSET) &&
> >  				!cpuset_zone_allowed(*z, gfp_mask))
> >  			continue;
> 
> Would this not be a very good example of an overlapping GFP_foo bits?. If this
> bit were just passed through with the GFP_DMA etc then we could build lists
> per-node which only include the node, then put those in the
> zonelist[GFP_THISNODE|GFP_DMA] etc?

__GFP_THISNODE is needed for memory policies and cpuset constraints. In 
that case the zonelists do not help.

The gfp_mask is a local parameter and can be checked with minimal effort 
here.

cpuset already do extensive filtering of zonelists. We are down this road 
already.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
