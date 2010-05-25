Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9565A6002CC
	for <linux-mm@kvack.org>; Tue, 25 May 2010 03:07:40 -0400 (EDT)
Date: Tue, 25 May 2010 17:07:34 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC V2 SLEB 00/14] The Enhanced(hopefully) Slab Allocator
Message-ID: <20100525070734.GC5087@laptop>
References: <20100521211452.659982351@quilx.com>
 <20100524070309.GU2516@laptop>
 <alpine.DEB.2.00.1005240852580.5045@router.home>
 <20100525020629.GA5087@laptop>
 <AANLkTik2O-_Fbh-dq0sSLFJyLU7PZi4DHm85lCo4sugS@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTik2O-_Fbh-dq0sSLFJyLU7PZi4DHm85lCo4sugS@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <cl@linux-foundation.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 25, 2010 at 09:55:28AM +0300, Pekka Enberg wrote:
> On Tue, May 25, 2010 at 5:06 AM, Nick Piggin <npiggin@suse.de> wrote:
> >> If can find criteria that are universally agreed upon then yes but that is
> >> doubtful.
> >
> > I think we can agree that perfect is the enemy of good, and that no
> > allocator will do the perfect thing for everybody. I think we have to
> > come up with a way to a single allocator.
> 
> Yes. The interesting most interesting bit about SLEB for me is the
> freelist handling as bitmaps, not necessarily the "queuing" part. If
> the latter also helps some workloads, it's a bonus for sure.

Agreed it is all interesting, but I think we have to have a rational
path toward having just one.

There is nothing to stop incremental changes or tweaks on top of that
allocator, even to the point of completely changing the allocation
scheme. It is inevitable that with changes in workloads, SMP/NUMA, and
cache/memory costs and hierarchies, the best slab allocation schemes
will change over time.

I think it is more important to have one allocator than trying to get
the absolute most perfect one for everybody. That way changes are
carefully and slowly reviewed and merged, with results to justify the
change. This way everybody is testing the same thing, and bisection will
work. The situation with SLUB is already a nightmare because now each
allocator has half the testing and half the work put into it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
