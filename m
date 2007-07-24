Subject: Re: [PATCH] add __GFP_ZERO to GFP_LEVEL_MASK
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0707240007100.3128@schroedinger.engr.sgi.com>
References: <1185185020.8197.11.camel@twins>
	 <20070723112143.GB19437@skynet.ie> <1185190711.8197.15.camel@twins>
	 <Pine.LNX.4.64.0707231615310.427@schroedinger.engr.sgi.com>
	 <1185256869.8197.27.camel@twins>
	 <Pine.LNX.4.64.0707240007100.3128@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 24 Jul 2007 09:24:54 +0200
Message-Id: <1185261894.8197.33.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@skynet.ie>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Daniel Phillips <phillips@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-07-24 at 00:09 -0700, Christoph Lameter wrote:
> On Tue, 24 Jul 2007, Peter Zijlstra wrote:
> 
> > Then we can either fixup the slab allocators to mask out __GFP_ZERO, or
> > do something like the below.
> > 
> > Personally I like the consistency of adding __GFP_ZERO here (removes
> > this odd exception) and just masking it in the sl[aou]b thingies.
> 
> There is another exception for __GFP_DMA.

non of the zone specifiers are

> > Anybody else got a preference?
> 
> >  #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
> >  
> > -/* if you forget to add the bitmask here kernel will crash, period */
> > +/*
> > + * If you forget to add the bitmask here kernel will crash, period!
> > + *
> > + * GFP_LEVEL_MASK is used to filter out the flags that are to be passed to the
> > + * page allocator.
> > + *
> 
> GFP_LEVEL_MASK is also used in mm/vmalloc.c. We need a definition that 
> goes beyond slab allocators.

Right, bugger.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
