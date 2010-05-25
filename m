Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C28AF620202
	for <linux-mm@kvack.org>; Tue, 25 May 2010 10:40:43 -0400 (EDT)
Date: Wed, 26 May 2010 00:40:37 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC V2 SLEB 00/14] The Enhanced(hopefully) Slab Allocator
Message-ID: <20100525144037.GQ5087@laptop>
References: <20100521211452.659982351@quilx.com>
 <20100524070309.GU2516@laptop>
 <alpine.DEB.2.00.1005240852580.5045@router.home>
 <20100525020629.GA5087@laptop>
 <alpine.DEB.2.00.1005250859050.28941@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1005250859050.28941@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 25, 2010 at 09:13:37AM -0500, Christoph Lameter wrote:
> On Tue, 25 May 2010, Nick Piggin wrote:
> 
> > On Mon, May 24, 2010 at 10:06:08AM -0500, Christoph Lameter wrote:
> > > On Mon, 24 May 2010, Nick Piggin wrote:
> > >
> > > > Well I'm glad you've conceded that queues are useful for high
> > > > performance computing, and that higher order allocations are not
> > > > a free and unlimited resource.
> > >
> > > Ahem. I have never made any such claim and would never make them. And
> > > "conceding" something ???
> >
> > Well, you were quite vocal about the subject.
> 
> I was always vocal about the huge amounts of queues and the complexity
> coming with alien caches etc. The alien caches were introduced against my
> objections on the development team that did the NUMA slab. But even SLUB
> has "queues" as many have repeatedly pointed out. The queuing is
> different though in order to minimize excessive NUMA queueing. IMHO the
> NUMA design of SLAB has fundamental problems because it implements its own
> "NUMAness" aside from the page allocator.

And by the way I disagreed completely that this is a problem. And you
never demonstrated that it is a problem.

It's totally unproductive to say things like it implements its own
"NUMAness" aside from the page allocator. I can say SLUB implements its
own "numaness" because it is checking for objects matching NUMA
requirements too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
