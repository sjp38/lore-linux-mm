Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8E7A46B004D
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 13:25:11 -0500 (EST)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e6.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id nAOIUqu1029398
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 13:30:52 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nAOIP7GQ122186
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 13:25:07 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nAOIP66u031477
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 13:25:07 -0500
Date: Tue, 24 Nov 2009 10:25:06 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: lockdep complaints in slab allocator
Message-ID: <20091124182506.GG6831@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1258714328.11284.522.camel@laptop> <4B067816.6070304@cs.helsinki.fi> <1258729748.4104.223.camel@laptop> <1259002800.5630.1.camel@penberg-laptop> <1259003425.17871.328.camel@calx> <4B0ADEF5.9040001@cs.helsinki.fi> <1259080406.4531.1645.camel@laptop> <20091124170032.GC6831@linux.vnet.ibm.com> <1259082756.17871.607.camel@calx> <1259086459.4531.1752.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1259086459.4531.1752.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Matt Mackall <mpm@selenic.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, cl@linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 24, 2009 at 07:14:19PM +0100, Peter Zijlstra wrote:
> On Tue, 2009-11-24 at 11:12 -0600, Matt Mackall wrote:
> > On Tue, 2009-11-24 at 09:00 -0800, Paul E. McKenney wrote:
> > > On Tue, Nov 24, 2009 at 05:33:26PM +0100, Peter Zijlstra wrote:
> > > > On Mon, 2009-11-23 at 21:13 +0200, Pekka Enberg wrote:
> > > > > Matt Mackall wrote:
> > > > > > This seems like a lot of work to paper over a lockdep false positive in
> > > > > > code that should be firmly in the maintenance end of its lifecycle? I'd
> > > > > > rather the fix or papering over happen in lockdep.
> > > > > 
> > > > > True that. Is __raw_spin_lock() out of question, Peter?-) Passing the 
> > > > > state is pretty invasive because of the kmem_cache_free() call in 
> > > > > slab_destroy(). We re-enter the slab allocator from the outer edges 
> > > > > which makes spin_lock_nested() very inconvenient.
> > > > 
> > > > I'm perfectly fine with letting the thing be as it is, its apparently
> > > > not something that triggers very often, and since slab will be killed
> > > > off soon, who cares.
> > > 
> > > Which of the alternatives to slab should I be testing with, then?
> > 
> > I'm guessing your system is in the minority that has more than $10 worth
> > of RAM, which means you should probably be evaluating SLUB.
> 
> Well, I was rather hoping that'd die too ;-)
> 
> Weren't we going to go with SLQB?

Well, I suppose I could make my scripts randomly choose the memory
allocator, but I would rather not.  ;-)

More seriously, I do have a number of configurations that I test, and I
suppose I can chose different allocators for the different configurations.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
