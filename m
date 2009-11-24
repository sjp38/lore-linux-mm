Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C90ED6B0044
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 12:58:34 -0500 (EST)
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e9.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id nAOHqkMZ023439
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 12:52:46 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nAOHwLHv1294538
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 12:58:21 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nAOHwKH2015806
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 12:58:20 -0500
Date: Tue, 24 Nov 2009 09:58:20 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: lockdep complaints in slab allocator
Message-ID: <20091124175820.GE6831@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <84144f020911200238w3d3ecb38k92ca595beee31de5@mail.gmail.com> <1258714328.11284.522.camel@laptop> <4B067816.6070304@cs.helsinki.fi> <1258729748.4104.223.camel@laptop> <1259002800.5630.1.camel@penberg-laptop> <1259003425.17871.328.camel@calx> <4B0ADEF5.9040001@cs.helsinki.fi> <1259080406.4531.1645.camel@laptop> <20091124170032.GC6831@linux.vnet.ibm.com> <1259082756.17871.607.camel@calx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1259082756.17871.607.camel@calx>
Sender: owner-linux-mm@kvack.org
To: Matt Mackall <mpm@selenic.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, cl@linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 24, 2009 at 11:12:36AM -0600, Matt Mackall wrote:
> On Tue, 2009-11-24 at 09:00 -0800, Paul E. McKenney wrote:
> > On Tue, Nov 24, 2009 at 05:33:26PM +0100, Peter Zijlstra wrote:
> > > On Mon, 2009-11-23 at 21:13 +0200, Pekka Enberg wrote:
> > > > Matt Mackall wrote:
> > > > > This seems like a lot of work to paper over a lockdep false positive in
> > > > > code that should be firmly in the maintenance end of its lifecycle? I'd
> > > > > rather the fix or papering over happen in lockdep.
> > > > 
> > > > True that. Is __raw_spin_lock() out of question, Peter?-) Passing the 
> > > > state is pretty invasive because of the kmem_cache_free() call in 
> > > > slab_destroy(). We re-enter the slab allocator from the outer edges 
> > > > which makes spin_lock_nested() very inconvenient.
> > > 
> > > I'm perfectly fine with letting the thing be as it is, its apparently
> > > not something that triggers very often, and since slab will be killed
> > > off soon, who cares.
> > 
> > Which of the alternatives to slab should I be testing with, then?
> 
> I'm guessing your system is in the minority that has more than $10 worth
> of RAM, which means you should probably be evaluating SLUB.

I have one nomination for SLUB.  I have started a short test run.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
