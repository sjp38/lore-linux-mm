Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5571B600385
	for <linux-mm@kvack.org>; Thu, 27 May 2010 10:37:59 -0400 (EDT)
Date: Fri, 28 May 2010 00:37:54 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC V2 SLEB 00/14] The Enhanced(hopefully) Slab Allocator
Message-ID: <20100527143754.GR22536@laptop>
References: <20100524070309.GU2516@laptop>
 <alpine.DEB.2.00.1005240852580.5045@router.home>
 <20100525020629.GA5087@laptop>
 <alpine.DEB.2.00.1005250859050.28941@router.home>
 <20100525143409.GP5087@laptop>
 <alpine.DEB.2.00.1005250938300.29543@router.home>
 <20100525151129.GS5087@laptop>
 <alpine.DEB.2.00.1005251022220.30395@router.home>
 <20100525153759.GA20853@laptop>
 <alpine.DEB.2.00.1005270919510.5762@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1005270919510.5762@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, May 27, 2010 at 09:24:28AM -0500, Christoph Lameter wrote:
> On Wed, 26 May 2010, Nick Piggin wrote:
> 
> > > > > The reason that the alien caches made it into SLAB were performance
> > > > > numbers that showed that the design "must" be this way. I prefer a clear
> > > > > maintainable design over some numbers (that invariably show the bias of
> > > > > the tester for certain loads).
> > > >
> > > > I don't really agree. There are a number of other possible ways to
> > > > improve it, including fewer remote freeing queues.
> > >
> > > You disagree with the history of the allocator?
> >
> > I don't agree with you saying that it "must" be that way. There are
> > other ways to improve things there.
> 
> People told me that it "must" be this way. Could not convince them
> otherwise at the time.

So again there was no numbers just handwaving?


> I never wanted it to be that way and have been
> looking for other ways ever since. SLUB is a result of trying something
> different.
> 
> > then we can go ahead and throw out SLUB and make incremental
> > improvements from there instead.
> 
> I am just amazed at the tosses and turns by you. Didnt you write SLQB on
> the basis of SLUB? And then it was abandoned? If you really believe ths

Sure I hoped it would be able to conclusively beat SLAB, and I'd
thought it might be a good idea. I stopped pushing it because I
realized that incremental improvements to SLAB would likely be a
far better idea.


> and want to get this done then please invest some time in SLAB to get it
> cleaned up. I have some doubt that you are aware of the difficulties that
> you will encounter.

I am working on it. We'll see.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
