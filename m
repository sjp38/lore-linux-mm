Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3E1AB620202
	for <linux-mm@kvack.org>; Tue, 25 May 2010 11:31:26 -0400 (EDT)
Date: Tue, 25 May 2010 10:28:11 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC V2 SLEB 00/14] The Enhanced(hopefully) Slab Allocator
In-Reply-To: <20100525151129.GS5087@laptop>
Message-ID: <alpine.DEB.2.00.1005251022220.30395@router.home>
References: <20100521211452.659982351@quilx.com> <20100524070309.GU2516@laptop> <alpine.DEB.2.00.1005240852580.5045@router.home> <20100525020629.GA5087@laptop> <alpine.DEB.2.00.1005250859050.28941@router.home> <20100525143409.GP5087@laptop>
 <alpine.DEB.2.00.1005250938300.29543@router.home> <20100525151129.GS5087@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 26 May 2010, Nick Piggin wrote:

> You do not understand. There is nothing *preventing* other designs of
> allocators from using higher order allocations. The problem is that
> SLUB is *forced* to use them due to it's limited queueing capabilities.

SLUBs use of higher order allocation is *optional*. The limited queuing is
advantageous within the framework of SLUB because NUMA locality checks are
simplified and locking is localized to a single page increasing
concurrency.

> You keep spinning this as a good thing for SLUB design when it is not.

It is a good design decision. You have an irrational fear of higher order
allocations.

> > The reason that the alien caches made it into SLAB were performance
> > numbers that showed that the design "must" be this way. I prefer a clear
> > maintainable design over some numbers (that invariably show the bias of
> > the tester for certain loads).
>
> I don't really agree. There are a number of other possible ways to
> improve it, including fewer remote freeing queues.

You disagree with the history of the allocator?

> How is it possibly better to instead start from the known suboptimal
> code and make changes to it? What exactly is your concern with
> making incremental changes to SLAB?

I am not sure why you want me to repeat what I already said. Guess we
should stop this conversation since it is deteriorating.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
