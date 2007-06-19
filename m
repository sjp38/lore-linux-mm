Date: Tue, 19 Jun 2007 12:52:30 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH] slob: poor man's NUMA, take 5.
Message-ID: <20070619035230.GA23631@linux-sh.org>
References: <20070615033412.GA28687@linux-sh.org> <20070615064445.GM11115@waste.org> <20070615082237.GA29917@linux-sh.org> <Pine.LNX.4.64.0706150737190.7471@schroedinger.engr.sgi.com> <20070618023956.GA30969@linux-sh.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070618023956.GA30969@linux-sh.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>, Matt Mackall <mpm@selenic.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 18, 2007 at 11:39:56AM +0900, Paul Mundt wrote:
> On Fri, Jun 15, 2007 at 07:39:54AM -0700, Christoph Lameter wrote:
> > On Fri, 15 Jun 2007, Paul Mundt wrote:
> > 
> > > + * %GFP_DMA - Allocation suitable for DMA.
> > > + *
> > > + * %GFP_DMA32 - Large allocation suitable for DMA (depending on platform).
> > 
> > GFP_DMA32 is not supported in the slab allocators.
> > 
> > GFP_DMA should only be used for kmalloc caches. Otherwise use a slab 
> > created with SLAB_DMA.
> > 
> > > + *
> > > + * %__GFP_ZERO - Zero the allocation on success.
> > > + *
> > 
> > __GFP_ZERO is not support for slab allocations.
> > 
> Thanks, updated.
> 
Christoph, does your previous Acked-by still apply to this version?

Matt, any other concerns?

If there's nothing else, I'll post a final version with the appropriate
sign-offs/acks, and hopefully this is ready to go in to -mm if Andrew is
taking patches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
