Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 70F276B01B0
	for <linux-mm@kvack.org>; Tue, 25 May 2010 02:40:01 -0400 (EDT)
Date: Tue, 25 May 2010 12:06:30 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC V2 SLEB 00/14] The Enhanced(hopefully) Slab Allocator
Message-ID: <20100525020629.GA5087@laptop>
References: <20100521211452.659982351@quilx.com>
 <20100524070309.GU2516@laptop>
 <alpine.DEB.2.00.1005240852580.5045@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1005240852580.5045@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 24, 2010 at 10:06:08AM -0500, Christoph Lameter wrote:
> On Mon, 24 May 2010, Nick Piggin wrote:
> 
> > Well I'm glad you've conceded that queues are useful for high
> > performance computing, and that higher order allocations are not
> > a free and unlimited resource.
> 
> Ahem. I have never made any such claim and would never make them. And
> "conceding" something ???

Well, you were quite vocal about the subject.

 
> The "unqueueing" was the result of excessive queue handling in SLAB due and
> the higher order allocations are a natural move in HPC to gain performance.

This is the kind of handwavings that need to be put into a testable
form. I repeatedly asked you for examples of where the jitter is
excessive or where the TLB improvements help, but you never provided
any testable case. I'm not saying they don't exist, but we have to be
reational about this.

 
> > I hope we can move forward now with some objective, testable
> > comparisons and criteria for selecting one main slab allocator.
> 
> If can find criteria that are universally agreed upon then yes but that is
> doubtful.

I think we can agree that perfect is the enemy of good, and that no
allocator will do the perfect thing for everybody. I think we have to
come up with a way to a single allocator.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
