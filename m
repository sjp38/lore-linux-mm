Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 73B786B01BD
	for <linux-mm@kvack.org>; Fri, 28 May 2010 04:39:13 -0400 (EDT)
Date: Fri, 28 May 2010 18:39:06 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC V2 SLEB 00/14] The Enhanced(hopefully) Slab Allocator
Message-ID: <20100528083906.GB22536@laptop>
References: <20100525143409.GP5087@laptop>
 <alpine.DEB.2.00.1005250938300.29543@router.home>
 <20100525151129.GS5087@laptop>
 <alpine.DEB.2.00.1005251022220.30395@router.home>
 <20100525153759.GA20853@laptop>
 <alpine.DEB.2.00.1005270919510.5762@router.home>
 <20100527143754.GR22536@laptop>
 <alpine.DEB.2.00.1005271037060.7221@router.home>
 <20100527160728.GT22536@laptop>
 <alpine.DEB.2.00.1005271149480.7221@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1005271149480.7221@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, May 27, 2010 at 11:57:54AM -0500, Christoph Lameter wrote:
> On Fri, 28 May 2010, Nick Piggin wrote:
> 
> > > > realized that incremental improvements to SLAB would likely be a
> > > > far better idea.
> > >
> > > It looked to me as if there was a major conceptual issue with the linked
> > > lists used for objects that impacted performance
> >
> > With SLQB's linked list? No. Single threaded cache hot performance was
> > the same (+/- a couple of cycles IIRC) as SLUB on your microbenchmark.
> > On Intel's OLTP workload it was as good as SLAB.
> >
> > The linked lists were similar to SLOB/SLUB IIRC.
> 
> Yes that is the problem. So it did not address the cache cold
> regressions in SLUB. SLQB mostly addressed the slow path frequency on
> free.

This is going a bit off topic considering that I'm not pushing SLQB
or any concept from SLQB (just yet at least). As far as I know there
were no cache cold regressions in SLQB.


> The design of SLAB is superior for cache cold objects since SLAB does
> not touch the objects on alloc and free (if one requires similar
> cache cold performance from other slab allocators) thats why I cleaned
> up the per cpu queueing concept in SLAB (easy now with the percpu
> allocator and operations) and came up with SLEB. At the same time this
> also addresses the slowpath issues on free. I am not entirely sure how to
> deal with the NUMAness but I want to focus more on machines with low node
> counts.
> 
> The problem with SLAB was that so far the "incremental improvements" have
> lead to more deteriorations in the maintainability of the code. There are
> multiple people who have tried going this route that you propose.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
