Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C31A5620202
	for <linux-mm@kvack.org>; Tue, 25 May 2010 11:11:36 -0400 (EDT)
Date: Wed, 26 May 2010 01:11:29 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC V2 SLEB 00/14] The Enhanced(hopefully) Slab Allocator
Message-ID: <20100525151129.GS5087@laptop>
References: <20100521211452.659982351@quilx.com>
 <20100524070309.GU2516@laptop>
 <alpine.DEB.2.00.1005240852580.5045@router.home>
 <20100525020629.GA5087@laptop>
 <alpine.DEB.2.00.1005250859050.28941@router.home>
 <20100525143409.GP5087@laptop>
 <alpine.DEB.2.00.1005250938300.29543@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1005250938300.29543@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 25, 2010 at 09:48:01AM -0500, Christoph Lameter wrote:
> On Wed, 26 May 2010, Nick Piggin wrote:
> 
> > > The initial test that showed the improvements was on IA64 (16K page size)
> > > and that was the measurement that was accepted for the initial merge. Mel
> > > was able to verify those numbers.
> >
> > And there is nothing to prevent a SLAB type allocator from using higher
> > order allocations, except for the fact that it usually wouldn't because
> > far more often than not it is a bad idea.
> 
> 16K is the base page size on IA64. Higher order allocations are a pressing
> issue for the kernel given growing memory sizes and we are slowly but
> surely making progress with defrag etc.

You do not understand. There is nothing *preventing* other designs of
allocators from using higher order allocations. The problem is that
SLUB is *forced* to use them due to it's limited queueing capabilities.

You keep spinning this as a good thing for SLUB design when it is not.

 
> > > Fundamentally it is still the case that memory sizes are increasing and
> > > that management overhead of 4K pages will therefore increasingly become an
> > > issue. Support for larger page sizes and huge pages is critical for all
> > > kernel components to compete in the future.
> >
> > Numbers haven't really shown that SLUB is better because of higher order
> > allocations. Besides, as I said, higher order allocations can be used
> > by others.
> 
> Boot with huge page support (slub_min_order=9) and you will see a
> performance increase on many loads.

Pretty ridiculous.

 
> > Also, there were no numbers or test cases, simply handwaving. I don't
> > disagree it might be a problem, but the way to solve problems is to
> > provide a test case or numbers.
> 
> The reason that the alien caches made it into SLAB were performance
> numbers that showed that the design "must" be this way. I prefer a clear
> maintainable design over some numbers (that invariably show the bias of
> the tester for certain loads).

I don't really agree. There are a number of other possible ways to
improve it, including fewer remote freeing queues.

For the slab allocator, if anything, I'm pretty sure that numbers
actually is the most important criteria. A few thousand lines of
self contained code that services almost all the rest of the kernel
we are talking about.

 
> > Given that information, how can you still say that SLUB+more big changes
> > is the right way to proceed?
> 
> Have you looked at the SLAB code?

Of course. Have you had a look at the SLUB numbers and reports of
failures?

 
> Also please stop exaggerating. There are no immediate plans to replace
> SLAB. We are exploring a possible solution.

Good, because it cannot be replaced, I am proposing to replace SLUB in
fact. I have heard no good reasons why not.

 
> If the SLEB idea pans out and we can replicate SLAB (and SLUB) performance
> then we will have to think about replacing SLAB / SLUB at some point. So
> far this is just a riggedy thing that barely works where there is some
> hope that the SLAB - SLUB conumdrum may be solved by the approach.
 
SLUB has gone back to the drawing board because its original design
cannot support high enough performance to replace SLAB. This gives
us the opportunity to do what we should have done from the start, and
incrementally improve SLAB code.

I repeat for the Nth time that there is nothing stopping you from
adding SLUB ideas into SLAB. This is how it should have been done
from the start.

How is it possibly better to instead start from the known suboptimal
code and make changes to it? What exactly is your concern with
making incremental changes to SLAB?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
