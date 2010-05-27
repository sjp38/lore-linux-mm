Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C1918600385
	for <linux-mm@kvack.org>; Thu, 27 May 2010 10:27:44 -0400 (EDT)
Date: Thu, 27 May 2010 09:24:28 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC V2 SLEB 00/14] The Enhanced(hopefully) Slab Allocator
In-Reply-To: <20100525153759.GA20853@laptop>
Message-ID: <alpine.DEB.2.00.1005270919510.5762@router.home>
References: <20100521211452.659982351@quilx.com> <20100524070309.GU2516@laptop> <alpine.DEB.2.00.1005240852580.5045@router.home> <20100525020629.GA5087@laptop> <alpine.DEB.2.00.1005250859050.28941@router.home> <20100525143409.GP5087@laptop>
 <alpine.DEB.2.00.1005250938300.29543@router.home> <20100525151129.GS5087@laptop> <alpine.DEB.2.00.1005251022220.30395@router.home> <20100525153759.GA20853@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 26 May 2010, Nick Piggin wrote:

> > > > The reason that the alien caches made it into SLAB were performance
> > > > numbers that showed that the design "must" be this way. I prefer a clear
> > > > maintainable design over some numbers (that invariably show the bias of
> > > > the tester for certain loads).
> > >
> > > I don't really agree. There are a number of other possible ways to
> > > improve it, including fewer remote freeing queues.
> >
> > You disagree with the history of the allocator?
>
> I don't agree with you saying that it "must" be that way. There are
> other ways to improve things there.

People told me that it "must" be this way. Could not convince them
otherwise at the time. I never wanted it to be that way and have been
looking for other ways ever since. SLUB is a result of trying something
different.

> then we can go ahead and throw out SLUB and make incremental
> improvements from there instead.

I am just amazed at the tosses and turns by you. Didnt you write SLQB on
the basis of SLUB? And then it was abandoned? If you really believe ths
and want to get this done then please invest some time in SLAB to get it
cleaned up. I have some doubt that you are aware of the difficulties that
you will encounter.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
