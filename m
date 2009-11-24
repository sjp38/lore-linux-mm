Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7B8106B0044
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 15:46:26 -0500 (EST)
Subject: Re: lockdep complaints in slab allocator
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1259090615.17871.696.camel@calx>
References: <84144f020911192249l6c7fa495t1a05294c8f5b6ac8@mail.gmail.com>
	 <1258709153.11284.429.camel@laptop>
	 <84144f020911200238w3d3ecb38k92ca595beee31de5@mail.gmail.com>
	 <1258714328.11284.522.camel@laptop> <4B067816.6070304@cs.helsinki.fi>
	 <1258729748.4104.223.camel@laptop> <1259002800.5630.1.camel@penberg-laptop>
	 <1259003425.17871.328.camel@calx> <4B0ADEF5.9040001@cs.helsinki.fi>
	 <1259080406.4531.1645.camel@laptop>
	 <20091124170032.GC6831@linux.vnet.ibm.com>
	 <1259082756.17871.607.camel@calx>  <1259086459.4531.1752.camel@laptop>
	 <1259090615.17871.696.camel@calx>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 24 Nov 2009 21:46:20 +0100
Message-ID: <1259095580.4531.1788.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Matt Mackall <mpm@selenic.com>
Cc: paulmck@linux.vnet.ibm.com, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, cl@linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-11-24 at 13:23 -0600, Matt Mackall wrote:

> My understanding of the current state of play is:
> 
> SLUB: default allocator
> SLAB: deep maintenance, will be removed if SLUB ever covers remaining
> performance regressions
> SLOB: useful for low-end (but high-volume!) embedded 
> SLQB: sitting in slab.git#for-next for months, has some ground to cover
> 
> SLQB and SLUB have pretty similar target audiences, so I agree we should
> eventually have only one of them. But I strongly expect performance
> results to be mixed, just as they have been comparing SLUB/SLAB.
> Similarly, SLQB still has of room for tuning left compared to SLUB, as
> SLUB did compared to SLAB when it first emerged. It might be a while
> before a clear winner emerges.

And as long as we drag out this madness nothing will change I suspect.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
