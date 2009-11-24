Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B798F6B0093
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 16:22:18 -0500 (EST)
Received: from zps76.corp.google.com (zps76.corp.google.com [172.25.146.76])
	by smtp-out.google.com with ESMTP id nAOLMEWV001107
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 21:22:15 GMT
Received: from pzk6 (pzk6.prod.google.com [10.243.19.134])
	by zps76.corp.google.com with ESMTP id nAOLLNpO007576
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 13:22:10 -0800
Received: by pzk6 with SMTP id 6so4843099pzk.29
        for <linux-mm@kvack.org>; Tue, 24 Nov 2009 13:22:10 -0800 (PST)
Date: Tue, 24 Nov 2009 13:22:08 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: lockdep complaints in slab allocator
In-Reply-To: <1259097150.4531.1822.camel@laptop>
Message-ID: <alpine.DEB.2.00.0911241313220.12339@chino.kir.corp.google.com>
References: <84144f020911192249l6c7fa495t1a05294c8f5b6ac8@mail.gmail.com> <1258709153.11284.429.camel@laptop> <84144f020911200238w3d3ecb38k92ca595beee31de5@mail.gmail.com> <1258714328.11284.522.camel@laptop> <4B067816.6070304@cs.helsinki.fi>
 <1258729748.4104.223.camel@laptop> <1259002800.5630.1.camel@penberg-laptop> <1259003425.17871.328.camel@calx> <4B0ADEF5.9040001@cs.helsinki.fi> <1259080406.4531.1645.camel@laptop> <20091124170032.GC6831@linux.vnet.ibm.com> <1259082756.17871.607.camel@calx>
 <1259086459.4531.1752.camel@laptop> <1259090615.17871.696.camel@calx>  <1259095580.4531.1788.camel@laptop> <1259096004.17871.716.camel@calx> <1259096519.4531.1809.camel@laptop> <alpine.DEB.2.00.0911241302370.6593@chino.kir.corp.google.com>
 <1259097150.4531.1822.camel@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Matt Mackall <mpm@selenic.com>, paulmck@linux.vnet.ibm.com, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Nov 2009, Peter Zijlstra wrote:

> > slqb still has a 5-10% performance regression compared to slab for 
> > benchmarks such as netperf TCP_RR on machines with high cpu counts, 
> > forcing that type of regression isn't acceptable.
> 
> Having _4_ slab allocators is equally unacceptable.
> 

So you just advocated to merging slqb so that it gets more testing and 
development, and then use its inclusion in a statistic to say we should 
remove others solely because the space is too cluttered?

We use slab partially because the regression in slub was too severe for 
some of our benchmarks, and while CONFIG_SLUB may be the kernel default 
there are still distros that use slab as the default as well.  We cannot 
simply remove an allocator that is superior to others because it is old or 
has increased complexity.

I'd suggest looking at how widely used slob is and whether it has a 
significant advantage over slub.  We'd then have two allocators for 
specialized workloads (and slub is much better for diagnostics) and one in 
development.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
