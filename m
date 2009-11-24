Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 730B46B009C
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 16:48:19 -0500 (EST)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e8.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id nAOHhvbV008483
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 12:43:57 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nAOLmFll089806
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 16:48:15 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nAOLmEaL010078
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 16:48:15 -0500
Date: Tue, 24 Nov 2009 13:48:14 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: lockdep complaints in slab allocator
Message-ID: <20091124214814.GK6831@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1259080406.4531.1645.camel@laptop> <20091124170032.GC6831@linux.vnet.ibm.com> <1259082756.17871.607.camel@calx> <1259086459.4531.1752.camel@laptop> <1259090615.17871.696.camel@calx> <1259095580.4531.1788.camel@laptop> <1259096004.17871.716.camel@calx> <1259096519.4531.1809.camel@laptop> <alpine.DEB.2.00.0911241302370.6593@chino.kir.corp.google.com> <1259097150.4531.1822.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1259097150.4531.1822.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 24, 2009 at 10:12:30PM +0100, Peter Zijlstra wrote:
> On Tue, 2009-11-24 at 13:03 -0800, David Rientjes wrote:
> > On Tue, 24 Nov 2009, Peter Zijlstra wrote:
> > 
> > > Merge SLQB and rm mm/sl[ua]b.c include/linux/sl[ua]b.h for .33-rc1
> > > 
> > 
> > slqb still has a 5-10% performance regression compared to slab for 
> > benchmarks such as netperf TCP_RR on machines with high cpu counts, 
> > forcing that type of regression isn't acceptable.
> 
> Having _4_ slab allocators is equally unacceptable.

I completely agree.  We need at least ten.  ;-)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
